-- --- Diálogos flutuantes (por título) ---
hl.window_rule({
  match = { title = [[^(Open File|Save As|Enter name of file to save to|File Upload|Picture-in-Picture|Sign in|Authorize access|Authenticate)$]] },
  float = true,
})

-- --- Utilitários flutuantes ---
hl.window_rule({ match = { class = [[^(imv)$]] }, float = true })
hl.window_rule({ match = { class = [[^(xdg-desktop-portal-gtk)$]] }, float = true })
hl.window_rule({ match = { class = [[^(xdg-desktop-portal-gtk)$]] }, size = { 900, 650 } })
hl.window_rule({ match = { class = [[.*(pavucontrol|qpwgraph|helvum|blueman-manager|nm-connection-editor).*]] }, float = true })
hl.window_rule({ match = { class = [[.*(pavucontrol|qpwgraph|helvum|blueman-manager|nm-connection-editor).*]] }, size = { 800, 600 } })
hl.window_rule({ match = { class = [[^(org\.kde\.dolphin|dolphin)$]] }, float = true })
hl.window_rule({ match = { class = [[^(Rofi|rofi)$]] }, float = true })
hl.window_rule({ match = { class = [[^(Rofi|rofi)$]] }, border_size = 0 })
hl.window_rule({ match = { class = [[.*polkit.*]] }, float = true })
hl.window_rule({ match = { class = [[^(crx_.*|chrome-extension.*)$]] }, float = true })
hl.window_rule({ match = { title = [[^(Extension: \(.*\))$]] }, float = true })

-- --- ghostty ---
-- o btop sobe com class própria (com.mitchellh.ghostty.btop), então não casa aqui
hl.window_rule({ match = { class = [[^(com\.mitchellh\.ghostty)$]] }, float = true })
hl.window_rule({ match = { class = [[^(com\.mitchellh\.ghostty)$]] }, size = { 1150, 800 } })
hl.window_rule({ match = { class = [[^(com\.mitchellh\.ghostty\.btop)$]] }, workspace = "2 silent" })

-- Terminais são a ÚNICA exceção de opacidade: todo o resto fica em 1.0
-- (ver hyprland.lua, decoration.active_opacity) para o Hyprland poder usar o
-- caminho rápido, sem alpha blend por frame. O `.*` cobre também as classes
-- derivadas, como com.mitchellh.ghostty.btop, que não casam no regex anterior.
hl.window_rule({ match = { class = [[^com\.mitchellh\.ghostty.*$]] }, opacity = "0.9 0.9" })

-- --- Apps -> workspaces (silent: Hyprland não tem regra de foco) ---
-- Janelas do navegador nascem FLUTUANTES: só assim o app consegue impor o
-- tamanho que ele mesmo pediu (o tiling sobrescreveria o pedido).
-- O popups.lua tileia SÓ a janela principal; popups são apenas centralizados
-- e qualquer outra janela do navegador fica flutuante (tile manual).
-- NÃO remova o float: é o que faz o popup de extensão abrir no tamanho certo.
-- NÃO coloque `maximize = true` aqui: ela maximizaria o popup já no
-- mapeamento, e ele apareceria em tela cheia antes de encolher (o "pisca"
-- ao abrir o Bitwarden).
--
-- suppress_event: o Zen/firefox|Firefox, ao criar o popup, pede "maximizado" (herda o
-- sizemode da janela principal) e só depois se corrige — era isso que fazia o
-- popup piscar em tela cheia. Isto IGNORA esse pedido do cliente.
hl.window_rule({ match = { class = [[^((org\.mozilla\.)?firefox|Firefox|zen)$]] }, suppress_event = "maximize" })
hl.window_rule({ match = { class = [[^((org\.mozilla\.)?firefox|Firefox|zen)$]] }, float = true })
hl.window_rule({ match = { class = [[^((org\.mozilla\.)?firefox|Firefox|zen)$]] }, workspace = "1 silent" })
hl.window_rule({ match = { class = [[^((org\.mozilla\.)?firefox|Firefox|zen)$]] }, no_vrr = true }) -- niri: variable-refresh-rate false
hl.window_rule({ match = { class = [[^(spotify|Spotify)$]] }, workspace = "2 silent" })
hl.window_rule({ match = { class = [[^(vesktop|Vesktop)$]] }, workspace = "4 silent" })
hl.window_rule({ match = { class = [[^(slack|Slack)$]] }, workspace = "9 silent" })

-- --- steam/heroic/lutris -> ws5 (sem maximize: no dwindle já preenchem sozinhos) ---
hl.window_rule({ match = { class = [[^(steam|Steam|heroic|heroichl|lutris|Lutris)$]] }, workspace = "5 silent" })
hl.window_rule({ match = { title = [[^(Friends List|.* - Chat|Steam - News|Settings|.* - Properties)$]] }, float = true })

hl.window_rule({ match = { class = [[^(steam|Steam)$]], title = [[^$]] }, float = true })

-- --- Jogos: fullscreen + content game ---
hl.window_rule({
  match = { class = [[^(steam_app_\d+|gamescope|cs2|dota2|Cyberpunk2077|bg3\.exe|bg3_dx11\.exe|acs\.exe|assettocorsa\.exe|lutris-wrapper)$]] },
  fullscreen = true,
})
hl.window_rule({
  match = { class = [[^(steam_app_\d+|gamescope|cs2|dota2|Cyberpunk2077|bg3\.exe|bg3_dx11\.exe|acs\.exe|assettocorsa\.exe|heroic|lutris-wrapper)$]] },
  content = "game",
})

hl.window_rule({ match = { modal = true }, float = true })
hl.window_rule({ match = { class = [[^(A2tools-dps-meter)$]] }, float = true })
hl.window_rule({ match = { class = [[^(A2tools-dps-meter)$]] }, pin = true })
