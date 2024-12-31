script_name('mimgui sborka')
script_author('evernos')
script_version('0.21-beta')
local versb = '13.12.2024'
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

local fini = 'settings_mimgui_sborka.ini'
local ini = inicfg.load({
    main = {
        si = true,
        au = true,
        auc = true,
        aucc = false
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
                if ini.main.auc then
                    print(u8:decode'Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                end
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    if ini.main.auc then
                        print(u8:decode'Скрипт обновлен, перезагрузка...')
                    end
                    if ini.main.aucc then
                        sampAddChatMessage(u8:decode'Скрипт обновлен, перезагрузка...', -1)
                    end
                end
            end)
        else
            if ini.main.auc then
                print(u8:decode'Ошибка, невозможно установить обновление, код: '..response.status_code)
            end
            if ini.main.aucc then
                sampAddChatMessage(u8:decode'Ошибка, невозможно установить обновление, код: '..response.status_code, -1)
            end
        end
    end
    return f
end

function imgui.ToggleButton(str_id, bool)
    local rBool = false
    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local height = imgui.GetTextLineHeightWithSpacing()
    local width = height * 1.70
    local radius = height * 0.50
    local ANIM_SPEED = type == 2 and 0.10 or 0.15
    local butPos = imgui.GetCursorPos()
    if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
        bool[0] = not bool[0]
        rBool = true
        LastActiveTime[tostring(str_id)] = os.clock()
        LastActive[tostring(str_id)] = true
    end
    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 8, butPos.y + 2.5))
    imgui.Text( str_id:gsub('##.+', '') )
    local t = bool[0] and 1.0 or 0.0
    if LastActive[tostring(str_id)] then
        local time = os.clock() - LastActiveTime[tostring(str_id)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool[0] and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(str_id)] = false
        end
    end
    local col_circle = bool[0] and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])) or imgui.ColorConvertFloat4ToU32(imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.TextDisabled]))
    dl:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg]), height * 0.5)
    dl:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, col_circle)
    return rBool
end

local window = imgui.new.bool()
local si1 = imgui.new.bool(ini.main.si)
local au1 = imgui.new.bool(ini.main.au)
local auc1 = imgui.new.bool(ini.main.auc)
local aucc1 = imgui.new.bool(ini.main.aucc)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

function main()
    repeat wait(0) until isSampAvailable()
--[[    sampAddChatMessage('[Сборка] Автор сборки для Online RP - evernos', -1)
    sampAddChatMessage('[Сборка] Информация/помощь - /infosb', -1)
    sampAddChatMessage('[Сборка] Версия сборки - '..versb..', скрипта - '..thisScript().version..'', -1)]]
    local lastver = update():getLastVersion()
    if ini.main.au then
        if ini.main.au and ini.main.auc then
            if thisScript().version ~= lastver then
                if ini.main.auc then
                    print(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить.. ('..ver..' -> '..lastver..')')
                end
                if ini.main.aucc then
                    sampAddChatMessage(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить.. ('..ver..' -> '..lastver..')', -1)
                end
                update():download()
            else
                if ini.main.auc then
                    print(u8:decode'[Сборка] Обновлений не найдено')
                end
                if ini.main aucc then
                    sampAddChatMessage(u8:decode'[Сборка] Обновлений не найдено', -1)
                end
            end
        end
    end
    if ini.main.si then
        sampAddChatMessage(u8:decode'[Сборка] Автор сборки для Online RP - evernos', -1)
        sampAddChatMessage(u8:decode'[Сборка] Информация/помощь - /is', -1)
    end
    sampRegisterChatCommand('is', function() window[0] = not window[0] end)
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
    sampAddChatMessage(u8:decode'[Сборка] Такая команда доступна только для игроков с телефона!', -1)
end

imgui.OnFrame(
    function() return window[0] end,
    function(this)
        local size, res = imgui.ImVec2(500, 500), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if (imgui.Begin('Информация о сборке', window, nil)) then
            imgui.TextWrapped('Дарова, тута можешь посмотреть информацию о сборке, а также воспользоваться несколькими функциями')
        end
        if imgui.CollapsingHeader('Общее') then
            imgui.TextWrapped(fa.USER)
            imgui.SameLine()
            imgui.TextWrapped('Автор: evernos')
            imgui.TextWrapped(fa.ENVELOPE)
            imgui.SameLine()
            imgui.TextWrapped('Связь с автором - ВК/ТГ @evernos')
            imgui.TextWrapped(fa.CALENDAR_DAYS)
            imgui.SameLine()
            imgui.TextWrapped('Ваша версия сборки - '..versb..'')
            imgui.TextWrapped('Версия скрипта - '..ver..'')
            if imgui.Button('Перезагрузить скрипт') then
                thisScript():reload()
            end
            if imgui.Button('Очистить чат') then
                cchat()
            end
            imgui.SameLine()
            imgui.TextWrapped('ну или /cc в чат')
        end
        if imgui.CollapsingHeader('Настройки скрипта') then
            if imgui.ToggleButton('Приветственное сообщение при входе в игру', si1) then
                ini.main.si = not ini.main.si
                inicfg.save(ini, fini)
            end
            if imgui.ToggleButton('Автообновление скрипта', au1) then
                if imgui.ToggleButton('Информирование в лог (moonloader.log / консоль SAMPFUNCS)', auc1) then
                    ini.main.auc = not ini.main.auc
                    inicfg.save(ini, fini)
                end
                if imgui.ToggleButton('Информирование в чат', aucc1) then
                    ini.main.aucc = not ini.main.aucc
                    inicfg.save(ini, fini)
                end
                ini.main.au = not ini.main.au
                inicfg.save(ini, fini)
            end
        end
        if imgui.CollapsingHeader('Реконнект') then
            imgui.TextWrapped('Клео скрипт, реконнект v6 от AIR')
            imgui.TextWrapped('Команды:')
            imgui.TextWrapped('/rec [sec] - переподключает на сервер с заданной задержкой. Рекомендуется ставить минимум 10, если не указать - реконнектит сразу, но есть риск словить бан айпи')
            imgui.TextWrapped('Также /rec может менять ник после реконнекта (/rec Eron_Evernos), смена айпи сервера (/rec 80.66.71.65:7777), смена буквенного айпи сервера (/rec s3.gta-mobile.ru:7777), рекконект с не целой задержкой (/rec 10.6 - реконнект через 10.6 секунд)')
            imgui.TextWrapped('/arec [sec] - авто реконнект после разрыва подключения с сервером через заданную задержку')
            imgui.TextWrapped('/fcon [режим] [sec] - изменение режима и времени фаст коннекта. Пример - /rec 0 1 - реконнектит раз в 1 секунду, /rec 1 1 - увеличение корректных запросов и повышение шансев на коннект к серверу')
            imgui.TextWrapped('(не нужный?) /pcon [min] [max] - изменение порта подключения')
            imgui.TextWrapped('/spassword [password] - изменяет пароль сервера (не входа в игру, а именно сервера). /spassword ставит пустое значение, /spassword 528363 (пример) меняет пароль от сервера на 528363')
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
