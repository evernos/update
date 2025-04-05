script_name('ONLINE RP HELPER')
script_author('evernos')
script_version('0.21-beta')
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

local fini = 'settings_orphelper.ini'
local ini = inicfg.load({
    main = {
        si = true,
        fraction = false
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
local wsettings = imgui.new.bool()
local si1 = imgui.new.bool(ini.main.si)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

function main()
    repeat wait(0) until isSampAvailable()
    local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
        print(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить.. ('..ver..' -> '..lastver..')')
        update():download()
    else
        print(u8:decode'[Сборка] Обновлений не найдено')
    end
    sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Загрузились. Автор - evernos', 0x0055ffff)
    sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Настройки скрипта - /oh', 0x0055ffff)
    sampAddChatMessage(u8:decode'[orp helper] не вижу смысл использовать скрипт, после обновы будет уже что-то', -1)
    sampRegisterChatCommand('oh', function() window[0] = not window[0] end)
    sampRegisterChatCommand('case', case)
    sampRegisterChatCommand('cases', case)
    sampRegisterChatCommand('cc', cchat)
    wait(0)
end

function cchat()
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function case()
    sampAddChatMessage(u8:decode'[ORP HELPER] {ffffff}Такая команда доступна только для игроков с телефона!', 0x0055ffff)
end

imgui.OnFrame(
    function() return window[0] end,
    function(this)
        local size, res = imgui.ImVec2(500, 500), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Online RolePlay Helper / Автор evernos / Версия '..ver, window, nil)
        if imgui.Button('Настройки скрипта') then
            wsettings[0] = not wsettings[0]
            -- if not ini.main.fraction then
            --     if imgui.CollapsingHeader('Выбери группу фракций') then
            --         if imgui.Button('ПД/ФБР') then
            --             ini.main.fraction = 'mj'
            --             inicfg.save(ini, fini)
            --         end
            --     end
            -- end
        end
        if imgui.CollapsingHeader('Действия со скриптом') then
            if imgui.Button('Выключить скрипт') then
                thisScript():unload()
            end
            if imgui.Button('Перезагрузить скрипт') then
                thisScript():reload()
            end
        end
        imgui.End()
    end
)

function onWindowMessage(m, p) -- https://www.blast.hk/threads/62755/post-553121 thnk
    if p == 0x1B and window[0] then
        consumeWindowMessage()
        window[0] = false
    end
end
