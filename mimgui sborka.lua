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
                    print(u8:decode'Скрипт обновлен, перезагрузка...', -1)
                    thisScript():reload()
                end
            end)
        else
            print(u8:decode'Ошибка, невозможно установить обновление, код: '..response.status_code)
        end
    end
    return f
end

local window = imgui.new.bool()

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

function main()
    repeat wait(0) until isSampAvailable()
--[[    sampAddChatMessage('[Сборка] Автор сборки для Online RP - evernos', -1)
    sampAddChatMessage('[Сборка] Информация/помощь - /infosb', -1)
    sampAddChatMessage('[Сборка] Версия сборки - '..versb..', скрипта - '..thisScript().version..'', -1)]]
    print(u8:decode'[Сборка] Проверяем наличие обновлений..')
    local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
        print(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить.. ('..ver..' -> '..lastver..')')
        update():download()
    else
        print(u8:decode'[Сборка] Обновлений не найдено')
        sampAddChatMessage(u8:decode'[Сборка] Автор сборки для Online RP - evernos', -1)
        sampAddChatMessage(u8:decode'[Сборка] Информация/помощь - /is', -1)
    end
    sampRegisterChatCommand('is', function() window[0] = not window[0] end)
    sampRegisterChatCommand('case', case)
    sampRegisterChatCommand('cases', case)
    wait(0)
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
            imgui.SameLine()
            if imgui.Button('Проверить наличие обновлений') then
                print(u8:decode'[Сборка] Проверяем наличие обновлений..')
                if thisScript().version ~= lastver then
                    print(u8:decode'[Сборка] Найдено обновление скрипта. Пытаемся загрузить..')
                    update():download()
                else
                    print(u8:decode'[Сборка] Обновлений не найдено')
                end
            end
        end
        if imgui.CollapsingHeader('История обновлений') then
            imgui.TextWrapped('Вся история обновлений (кроме двух первых версий :D)(дублирование дополнительно -> История обновлений.txt):')
            if imgui.CollapsingHeader('04.09.2024') then
                imgui.TextWrapped('Обновление с выходом оффициального обновления сборки 03.09.2024')
                imgui.TextWrapped('Убраны лишние модификации в модлоадере (по факту - все), лишние файлы в сборке')
                imgui.TextWrapped('Теперь будут только ссылки на модификации в папке "дополнительно", дабы уменьшить размер сборки')
                imgui.TextWrapped('Добавлен мод на первое лицо')
                imgui.TextWrapped('Убраны два камхака, теперь скачать можно ОДИН, ссылка на него в .txtшнике "Другие модификации"')
                imgui.TextWrapped('Замены различных картинок, по типу fist/sampgui/mouse и т.п заменяются теперь как обычно, не через модлоадер, но по желанию заменяйте как хотите :D')
                imgui.TextWrapped('p.s клео и модлоадер добавлены добавлены в оффициальную сборку, так что их устанавливал не я')
            end
            if imgui.CollapsingHeader('05.11.2024') then
                imgui.TextWrapped('Обновление с выходом оффициального обновления сборки 04.11.2024')
                imgui.TextWrapped("Добавлены HD иконки всего оружия (были в самых ранних версиях сборки, только они лежали в modloader'е, а не в gta3.img)")
                imgui.TextWrapped('Добавлен MapFix.asi, т.к. я его забыл добавить в обновлении 04.09.2024 (точнее перенести с более ранней сборки)')
                imgui.TextWrapped('Добавлена возможность видеть все деньги, если у вас их больше 100кк')
                imgui.TextWrapped('Добавлен sf_r3_opcodes_fix.lua (фикс 3-х опкодов сампфункса)')
                imgui.TextWrapped("Убран автотег (/tagmenu), его опять же можно найти в .txt'шнике")
                imgui.SameLine()
                imgui.TextWrapped('"Другие')
                imgui.SameLine()
                imgui.TextWrapped('модификации"')
            end
            if imgui.CollapsingHeader('10.11.2024') then
                imgui.TextWrapped('Фикс крашей и распаковки архива')
            end
            if imgui.CollapsingHeader('13.12.2024') then
                imgui.TextWrapped('Обновление с выходом оффициального обновления сборки 02.12.2024')
                imgui.TextWrapped('Фиксанут скрипт Input Helper, теперь при вводе в консоль сампфункса команд, где нужно нажать букву T, не будет открываться чат ( просто в 41 строке добавил "and not isSampfuncsConsoleActive()" )')
                imgui.TextWrapped('Перенесен скрипт на отображение денег в мой скрипт (короче, удален 100kk+.lua, но его строки лежат в mimgui sborka.lua)')
                imgui.TextWrapped('Касаемо моего скрипта - проще говоря, дубликат папки дополнительно, но имеет расширенный функционал (в будущем запихну автообнову, сейчас опыта мало)(возможен говнокод)')
            end
        end
        if imgui.CollapsingHeader('Другие модификации') then
            imgui.TextWrapped('Читать в дополнительно -> Другие модификации.txt')
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
