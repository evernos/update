script_name('ONLINE RP HELPER')
script_author('evernos')
script_version('0.21.2-beta')
local ver = thisScript().version

local imgui = require('mimgui')
local ffi = require('ffi')
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local fa = require('fAwesome6_solid')
require('lib.moonloader')
local memory = require('memory')
local inicfg = require('inicfg')
local addons = require('ADDONS')
local ev = require('lib.samp.events')

local fini = 'settings_orphelper.ini'
local ini = inicfg.load({
    main = {
        si = true,
        fraction = false,
        alogin = false,
        passwordalogin = false
    }
}, fini)
inicfg.save(ini, fini)

writeMemory(0x571784, 4, 0x57C7FFF, false)
writeMemory(0x57179C, 4, 0x57C7FFF, false) -- https://www.blast.hk/threads/13380/post-1069199 thnk

function update()
    local raw = 'https://raw.githubusercontent.com/evernos/update/refs/heads/main/update.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                print(u8:decode'Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    print(u8:decode'Скрипт обновлен, перезагрузка...')
                end
            end)
        else
            print(u8:decode'Ошибка, невозможно установить обновление, код: '..response.status_code)
        end
    end
    return f
end

local window = imgui.new.bool()
local settings = imgui.new.bool()
local prochee = imgui.new.bool()
local si = imgui.new.bool(ini.main.si)
local alogin = imgui.new.bool(ini.main.alogin)
local passwordalogin = imgui.new.char[128](ini.main.passwordalogin)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

local buttonwindow = imgui.ImVec2(-1, 0)

function main()
    repeat wait(0) until isSampAvailable()
    local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
        print(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить.. ('..ver..' -> '..lastver..')')
        update():download()
    else
        print(u8:decode'[Сборка] Обновлений не найдено')
        sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Загрузились. Автор - evernos', 0x0055ffff)
        sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Настройки скрипта - /oh', 0x0055ffff)
        sampAddChatMessage(u8:decode'[orp helper] не вижу смысл использовать скрипт, после обновы будет уже что-то', -1)
    end
    sampRegisterChatCommand('oh', function() window[0] = not window[0] end)
    sampRegisterChatCommand('case', case)
    sampRegisterChatCommand('cases', case)
    sampRegisterChatCommand('cc', cchat)
    wait(0)
end

function case()
    sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Такая команда доступна только для игроков с телефона!', 0x0055ffff)
end

function cchat()
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

imgui.OnFrame(
    function() return window[0] end,
    function(this)
        local size, res = imgui.ImVec2(500, 500), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Online RolePlay Helper / Автор evernos / Версия '..ver, window, imgui.WindowFlags.NoResize)
        if imgui.Button('Настройки скрипта', buttonwindow) then
            settings[0] = not settings[0]
        end
        if imgui.CollapsingHeader('Биндер') then
            
        end
        if imgui.CollapsingHeader('Командный биндер') then
            
        end
        if imgui.CollapsingHeader('Команды скрипта') then
            if imgui.CollapsingHeader('/oh') then
                imgui.Text('Описание: открытие меню скрипта')
                imgui.Text('Использование: /oh')
            end
            if imgui.CollapsingHeader('/cc') then
                imgui.Text('Описание: чистка чата')
                imgui.Text('Использование: /cc')
            end
            if imgui.CollapsingHeader('/') then
                imgui.Text('Описание: ')
                imgui.Text('Использование: /')
            end
        end
        if imgui.Button('Прочее', buttonwindow) then
            prochee[0] = not prochee[0]
        end
        if imgui.CollapsingHeader('Действия со скриптом') then
            if imgui.Button('Выключить скрипт', buttonwindow) then
                thisScript():unload()
            end
            if imgui.Button('Перезагрузить скрипт', buttonwindow) then
                thisScript():reload()
            end
        end
        imgui.End()
    end
)

imgui.OnFrame(
    function() return settings[0] end,
    function (ssetings)
        local ssize, sres = imgui.ImVec2(400, 400), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(ssize, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sres.x / 2, sres.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Online RolePlay Helper / Настройки', settings, imgui.WindowFlags.NoResize)
        if addons.ToggleButton('Автологин', alogin) then
            ini.main.alogin = not ini.main.alogin
            inicfg.save(ini, fini)
        end
        if ini.main.alogin then
            imgui.InputTextWithHint('', 'Введите пароль', passwordalogin, 128, imgui.InputTextFlags.Password)
            imgui.SameLine()
            if imgui.Button('Сохранить пароль') then
                text = u8:decode(ffi.string(passwordalogin))
                ini.main.passwordalogin = text
                inicfg.save(ini, fini)
            end
            if imgui.Button('Проверить пароль', buttonwindow) then
                sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Пароль: ' .. u8:decode(ffi.string(passwordalogin)), 0x0055ffff)
            end
        end
    end
)

if ini.main.alogin then
    function ev.onShowDialog(dialogid, style, title, button1, button2, text1)
        if string.find(title, title) then
            if dialogid == 32700 then
                sampSendDialogResponse(32700, 1, _, ini.main.passwordalogin)
                return false
            end
        end
    end
end

imgui.OnFrame(
    function() return prochee[0] end,
    function (piperochee)
        local psize, pres = imgui.ImVec2(400, 400), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(psize, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(pres.x / 2, pres.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Online RolePlay Helper / Прочее', prochee, imgui.WindowFlags.NoResize)
        if imgui.Button('Скопировать в буфер обмена ссылку на ТГК', buttonwindow) then
            setClipboardText('https://t.me/orphelper')
        end
    end
)

function onWindowMessage(m, p) -- https://www.blast.hk/threads/62755/post-553121 thnk
    if p == 0x1B and window[0] then
        consumeWindowMessage()
        window[0] = false
    end
end
function onWindowMessage(m2, p2) -- https://www.blast.hk/threads/62755/post-553121 thnk
    if p2 == 0x1B and settings[0] then
        consumeWindowMessage()
        settings[0] = false
    end
end
