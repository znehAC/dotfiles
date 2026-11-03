-- ============================================================
-- POPUPS DE EXTENSÃO DO NAVEGADOR — tamanho certo, sem "piscar"
--
-- O problema: efeitos estáticos (float, size, ...) são avaliados UMA única vez,
-- no mapeamento, e o `match.title` compara com o initial_title. Firefox/Zen só
-- definem "Extension: (Nome)" DEPOIS de mapear a janela, então uma window rule
-- comum nunca casa. Título real medido no Zen:
--   "Extension: (Bitwarden Password Manager) - Bitwarden — Zen Browser"
--
-- A solução tem duas partes:
--   1. windowrules.lua faz TODA janela do navegador nascer FLUTUANTE. É a
--      única forma de o app impor o tamanho que ele mesmo pediu: se a janela
--      nasce tileada, o Hyprland já trocou esse tamanho pelo do tile e não
--      existe API para recuperá-lo.
--   2. Este arquivo só mexe em duas coisas:
--        - janela PRINCIPAL (a primeira do navegador) -> tile + maximize
--          alguns ms depois do open;
--        - POPUP -> só centraliza; nunca mexe no float (ver aviso abaixo).
--      Toda outra janela do navegador (Ctrl+N, devtools, ...) fica FLUTUANTE
--      no tamanho que o app pediu — o tile é feito na mão quando você quiser.
--
-- ATENÇÃO: despachar `float` numa janela que JÁ está flutuante faz o Hyprland
-- tileá-la de volta, e o tamanho do app se perde. É por isso que o popup não é
-- tocado aqui.
-- ============================================================

local BROWSER = { zen = true, firefox = true }

-- padrões LUA (não RE2!) testados contra o título já pronto
local PATTERNS = { "^Extension: %(", "^Picture%-in%-Picture$" }

local MAIN_MS   = 300  -- maximize no window.open não "gruda"; alguns ms depois, sim
local SHRINK    = 100  -- só no caminho de recuperação (abaixo)
local SETTLE_MS = 250  -- tempo para o app reivindicar o tamanho dele
local TOLERANCE = 8
local FALLBACK  = { x = 500, y = 530 } -- só se o app não reivindicar tamanho nenhum

local function is_popup_title(t)
    for _, p in ipairs(PATTERNS) do
        if t:match(p) then return true end
    end
    return false
end

-- popup = janela EXTRA do navegador com título de popup; se for a única janela
-- daquela class, é a janela principal e não deve ser mexida
local function is_popup(w)
    return w ~= nil
        and BROWSER[w.class] == true
        and is_popup_title(w.title)
        and #hl.get_windows({ class = w.class }) > 1
end

local function tile(w)
    hl.dispatch(hl.dsp.window.float({ action = "unset", window = w }))
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set", window = w }))
end

local function tile_later(w, ms)
    local addr = w.address
    hl.timer(function()
        local cur = hl.get_window("address:" .. addr)
        if cur ~= nil then tile(cur) end
    end, { timeout = ms, type = "oneshot" })
end

hl.on("window.open", function(w)
    if w == nil or BROWSER[w.class] ~= true then return end

    -- primeira janela do navegador = principal -> tile + maximize.
    -- Qualquer OUTRA janela do navegador fica FLUTUANTE, no tamanho que o app
    -- pediu (popup de extensão, Ctrl+N, devtools, ...): o tile é manual.
    if #hl.get_windows({ class = w.class }) <= 1 then
        tile_later(w, MAIN_MS)
    end
end)

hl.on("window.title", function(w)
    if not is_popup(w) then return end

    if w.floating then
        -- veio flutuante pela regra: JÁ tem o tamanho que o app pediu.
        -- Não despachar float aqui! Só tira o maximize, se houver, e centraliza.
        if w.fullscreen ~= 0 then
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset", window = w }))
        end
        hl.dispatch(hl.dsp.window.center({ window = w }))
        return
    end

    -- rede de segurança: o popup chegou aqui JÁ tileado (algo o tileou antes do
    -- título aparecer), então o tamanho do app se perdeu. Encolhe e deixa o app
    -- reivindicar o tamanho natural/mínimo dele; se não reivindicar, FALLBACK.
    hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
    if w.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset", window = w }))
    end
    hl.dispatch(hl.dsp.window.resize({ x = SHRINK, y = SHRINK, relative = false, window = w }))
    hl.timer(function()
        local cur = hl.get_window("address:" .. w.address)
        if cur == nil then return end
        if cur.size.x <= SHRINK + TOLERANCE and cur.size.y <= SHRINK + TOLERANCE then
            hl.dispatch(hl.dsp.window.resize({ x = FALLBACK.x, y = FALLBACK.y, relative = false, window = cur }))
        end
        hl.dispatch(hl.dsp.window.center({ window = cur }))
    end, { timeout = SETTLE_MS, type = "oneshot" })
end)
