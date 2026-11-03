#!/usr/bin/env bash
#
# Candy lighting applier for the local openrgb-server.service.
#
# 2026-10-31: this script no longer loads an OpenRGB *profile*.  It calls
# apply_candy.py, which talks to the SDK, paints, and reads the colours back.
# Two reasons, both measured:
#
#   1. `openrgb -p <name>` prints "Profile loaded successfully" and exits 0
#      *unconditionally* -- `openrgb -p no_such_profile_xyz` does the same.  So
#      every "Profile loaded successfully" line in this service's history was
#      worthless: success could never be detected.
#   2. After a cold boot the ASUS Aura board reports its three addressable
#      headers with ZERO LEDs.  A zero-LED zone accepts colour writes and
#      silently drops them, so the case light, the fans and the watercooler
#      stayed dark while the 24-LED DRAM (which reports its size correctly)
#      lit up fine.  Resizing the header before painting fixes it; a resize is
#      therefore part of every apply, not a one-off.
#
# Historical note (still true): never use `openrgb --client HOST -p PROFILE`
# here.  When OpenRGB can also reach an SDK server on the default address
# (127.0.0.1:6742) it opens the explicit --client connection *and* an
# automatic "local server" connection, so ResourceManager's controller list
# contains every device twice, and the duplicated entries clobber each other.
# Upstream: OpenRGB issues #5336, #4285, #1371, #807.
#
# Also: every `openrgb --client` probe sent a half-open TCP connection to the
# server, which is what produced the "recv_select failed receiving magic"
# spam.  The port is now probed directly instead.

# All tunables can be overridden from the unit file, e.g.
#   Environment=TARGET_COUNT=4 GRACE_SECONDS=300
APPLIER="${APPLIER:-/home/cesar/.local/share/openrgb/venv/bin/python}"
APPLIER_SCRIPT="${APPLIER_SCRIPT:-/home/cesar/.local/share/openrgb/apply_candy.py}"
CANDY_NAME="candy"

# The Logitech wireless devices sleep at boot and don't answer OpenRGB's
# detection scan, and a running server's controller list is frozen after its
# initial scan, so a server restart is the only way to get a fresh scan.
#
# 2 = DRAM + mainboard -- both are always present, so the apply never fails.
# OpenRGB 1.0 creates NO controller at all for the G715 keyboard (it has no
# G715 driver; the receiver is recognised but no RGB controller is built), so
# the keyboard can never be counted.  The wireless mouse is the only optional
# device and it is unreliable at boot, so it is handled by the grace window
# below rather than by blocking here.  If you ever gain a keyboard OpenRGB can
# drive, raise this to 3.
TARGET_COUNT="${TARGET_COUNT:-2}"

# How long to keep watching for an extra device (the mouse) after the first
# successful apply.  If a controller appears during this window the server is
# re-scanned and the profile re-applied.  0 disables the extra wait.
GRACE_SECONDS="${GRACE_SECONDS:-300}"
GRACE_POLL="${GRACE_POLL:-10}"

# Skip the grace window entirely once this many controllers are already
# configured (3 = DRAM + mainboard + mouse; the G715 never appears).
MAX_DEVICES="${MAX_DEVICES:-4}"

MAX_CYCLES="${MAX_CYCLES:-10}"
POLLS_PER_CYCLE="${POLLS_PER_CYCLE:-8}"
WAIT_BETWEEN_CYCLES="${WAIT_BETWEEN_CYCLES:-30}"
HOST="127.0.0.1"
PORT="6742"

sdk_port_open() {
    timeout 2 bash -c "exec 3<>/dev/tcp/${HOST}/${PORT}" 2>/dev/null
}

count_controllers() {
    # Bail out before invoking openrgb if the server is down: without a
    # reachable server `openrgb -l` falls back to full local device detection,
    # which is slow and grabs the hardware the server is already holding.
    sdk_port_open || return 1

    local output count
    output=$(timeout 30 openrgb -l 2>&1) || return 1

    # OpenRGB <= 0.9 printed "Received controller count from server: N" when
    # running as a client; 1.0 dropped that line (it is debug-level now), so
    # fall back to counting the numbered device list it prints either way.
    count=$(printf '%s\n' "$output" | grep -oP '(?<=Received controller count from server: )\d+' | sort -rn | head -n 1)

    if [ -z "$count" ]; then
        count=$(printf '%s\n' "$output" | grep -cP '^\s*[0-9]+:')
    fi

    printf '%s' "$count"
}

apply_profile() {
    sdk_port_open || { echo "Server went away before apply." >&2; return 1; }

    # Let the controller MCUs finish their handshake
    sleep 3

    # Apply over the SDK and read the colours back afterwards.
    #
    # NOT `openrgb -p PROFILE` any more (see the note at the top of the file):
    # that command prints "Profile loaded successfully" unconditionally - even
    # for a profile that does not exist - so it could never fail.  The applier
    # also resizes the Aura headers when the board reports them as 0 LEDs,
    # which is what happens after a cold boot and what made only the RAM light.
    "$APPLIER" "$APPLIER_SCRIPT" --verify
}

# Apply, then retry once: a controller that was asleep can miss the first push.
apply_with_retry() {
    apply_profile && return 0
    echo "Apply/verify failed, retrying once..." >&2
    sleep 2
    apply_profile
}

# Restart the server and poll until TARGET_COUNT controllers are visible.
# Sets COUNT.  Every restart drops the DRAM back to its red power-on default,
# so this is only done when a fresh scan is actually needed.
rescan_until_ready() {
    local cycle=$1 i
    echo "Cycle $cycle/$MAX_CYCLES: found ${COUNT:-0}/$TARGET_COUNT controllers, restarting server for a fresh scan..."
    systemctl --user restart openrgb-server.service || true

    for ((i=1; i<=POLLS_PER_CYCLE; i++)); do
        if ! COUNT=$(count_controllers); then
            echo "Cycle $cycle/$MAX_CYCLES, attempt $i: Server not ready yet..."
            sleep 2
            continue
        fi
        COUNT=${COUNT:-0}

        echo "Cycle $cycle/$MAX_CYCLES, attempt $i: Found $COUNT/$TARGET_COUNT controllers..."

        [ "$COUNT" -ge "$TARGET_COUNT" ] && return 0

        sleep 2
    done

    return 1
}

for ((cycle=1; cycle<=MAX_CYCLES; cycle++)); do
    COUNT=$(count_controllers) || COUNT=0
    COUNT=${COUNT:-0}

    if [ "$COUNT" -lt "$TARGET_COUNT" ]; then
        rescan_until_ready "$cycle" || true
    fi

    if [ "${COUNT:-0}" -ge "$TARGET_COUNT" ]; then
        if apply_with_retry; then
            echo "Candy design applied and verified on $COUNT controllers."

            # Grace window: give a late-waking wireless device one more chance.
            #
            # applied_count is re-read *after* painting, not taken from the
            # earlier probe: the probe can see 3 controllers while the applier
            # still saw 2 (a device that re-enumerated in between).  Comparing
            # against the probe count then hides the device that never got
            # painted - that is how the G715 stayed black on 2026-10-31.
            if [ "$GRACE_SECONDS" -gt 0 ] && [ "$COUNT" -lt "$MAX_DEVICES" ]; then
                applied_count=$(count_controllers) || applied_count=$COUNT
                applied_count=${applied_count:-$COUNT}
                deadline=$(( $(date +%s) + GRACE_SECONDS ))
                while [ "$(date +%s)" -lt "$deadline" ]; do
                    sleep "$GRACE_POLL"
                    EXTRA=$(count_controllers) || continue
                    if [ "${EXTRA:-0}" -gt "$applied_count" ]; then
                        echo "Extra controller appeared ($EXTRA > $applied_count), re-applying..."
                        # Re-apply first: the new controller is usually live
                        # already, and a plain repaint does not momentarily
                        # black out the RAM the way a server restart does.
                        if apply_with_retry; then
                            echo "Candy design re-applied ($EXTRA controllers)."
                        else
                            echo "Re-apply failed; restarting the server for a fresh scan..." >&2
                            COUNT=$EXTRA
                            if rescan_until_ready "$cycle"; then
                                apply_with_retry && echo "Candy design re-applied ($COUNT controllers)."
                            fi
                        fi
                        break
                    fi
                done
            fi

            exit 0
        fi
        echo "Apply failed, will retry..." >&2
    fi

    # Devices may still be asleep; wait a bit before re-scanning
    sleep "$WAIT_BETWEEN_CYCLES"
done

echo "Error: Timed out waiting for $TARGET_COUNT devices." >&2
exit 1
