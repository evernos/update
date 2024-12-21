script_name('info sborka')
script_author('evernos')
script_version('0.2-beta')
local ver = '0.2-beta'
local versb = '13.12.2024'

local imgui = require('mimgui')
local ffi = require('ffi')
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local fa = require('fAwesome6_solid')
require('lib.moonloader')

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/evernos/update/refs/heads/main/update.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/evernos/update/edit/main/mimgui%20sborka.lua"
        end
    end
end

local window = imgui.new.bool()

writeMemory(0x571784, 4, 0x57C7FFF, false)
writeMemory(0x57179C, 4, 0x57C7FFF, false) -- https://www.blast.hk/threads/13380/post-1069199 thnk

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
end)

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage('[Сборка] Автор сборки для Online RP - evernos', -1)
    sampAddChatMessage('[Сборка] Информация/помощь - /infosb', -1)
    sampAddChatMessage('[Сборка] Версия сборки - '..versb..', скрипта - '..ver..'', -1)
    sampRegisterChatCommand('infosb', function() window[0] = not window[0] end)
    sampRegisterChatCommand('case', case)
    sampRegisterChatCommand('cases', case)
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    wait(0)
end

function case()
    sampSendChat('/case')
    sampAddChatMessage('[Сборка] Такая команда доступна только для игроков с телефона!', -1)
end

imgui.OnFrame(
    function() return window[0] end,
    function(this)
        local size, res = imgui.ImVec2(500, 500), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if (imgui.Begin(u8'Информация о сборке', window, imgui.WindowFlags.NoResize)) then
            imgui.TextWrapped(u8'Дарова, тута можешь посмотреть информацию о сборке, а также воспользоваться несколькими функциями')
        end
        if imgui.CollapsingHeader(u8'Общее') then
            imgui.Text(fa.USER)
            imgui.SameLine()
            imgui.Text(u8'Автор: evernos')
            imgui.Text(fa.ENVELOPE)
            imgui.SameLine()
            imgui.TextWrapped(u8'Связь с автором - ВК/ТГ @evernos')
            imgui.Text(fa.CALENDAR_DAYS)
            imgui.SameLine()
            imgui.Text(u8'Ваша версия сборки - '..versb..'')
        end
        if imgui.CollapsingHeader(u8'История обновлений') then
            imgui.TextWrapped(u8'Вся история обновлений (кроме двух первых версий :D)(дублирование дополнительно -> История обновлений.txt):')
            if imgui.CollapsingHeader(u8'04.09.2024') then
                imgui.TextWrapped(u8'Обновление с выходом оффициального обновления сборки 03.09.2024')
                imgui.TextWrapped(u8'Убраны лишние модификации в модлоадере (по факту - все), лишние файлы в сборке')
                imgui.TextWrapped(u8'Теперь будут только ссылки на модификации в папке "дополнительно", дабы уменьшить размер сборки')
                imgui.TextWrapped(u8'Добавлен мод на первое лицо')
                imgui.TextWrapped(u8'Убраны два камхака, теперь скачать можно ОДИН, ссылка на него в .txtшнике "Другие модификации"')
                imgui.TextWrapped(u8'Замены различных картинок, по типу fist/sampgui/mouse и т.п заменяются теперь как обычно, не через модлоадер, но по желанию заменяйте как хотите :D')
                imgui.TextWrapped(u8'p.s клео и модлоадер добавлены добавлены в оффициальную сборку, так что их устанавливал не я')
            end
            if imgui.CollapsingHeader(u8'05.11.2024') then
                imgui.TextWrapped(u8'Обновление с выходом оффициального обновления сборки 04.11.2024')
                imgui.TextWrapped(u8"Добавлены HD иконки всего оружия (были в самых ранних версиях сборки, только они лежали в modloader'е, а не в gta3.img)")
                imgui.TextWrapped(u8'Добавлен MapFix.asi, т.к. я его забыл добавить в обновлении 04.09.2024 (точнее перенести с более ранней сборки)')
                imgui.TextWrapped(u8'Добавлена возможность видеть все деньги, если у вас их больше 100кк')
                imgui.TextWrapped(u8'Добавлен sf_r3_opcodes_fix.lua (фикс 3-х опкодов сампфункса)')
                imgui.TextWrapped(u8"Убран автотег (/tagmenu), его опять же можно найти в .txt'шнике")
                imgui.SameLine()
                imgui.Text(u8'"Другие ')
                imgui.Text(u8'модификации"')
            end
            if imgui.CollapsingHeader(u8'10.11.2024') then
                imgui.TextWrapped(u8'Фикс крашей и распаковки архива')
            end
            if imgui.CollapsingHeader(u8'13.12.2024') then
                imgui.TextWrapped(u8'Обновление с выходом оффициального обновления сборки 02.12.2024')
                imgui.TextWrapped(u8'Фиксанут скрипт Input Helper, теперь при вводе в консоль сампфункса команд, где нужно нажать букву T, не будет открываться чат ( просто в 41 строке добавил "and not isSampfuncsConsoleActive()" )')
                imgui.TextWrapped(u8'Перенесен скрипт на отображение денег в мой скрипт (короче, удален 100kk+.lua, но его строки лежат в mimgui sborka.lua)')
                imgui.TextWrapped(u8'Касаемо моего скрипта - проще говоря, дубликат папки дополнительно, но имеет расширенный функционал (в будущем запихну автообнову, сейчас опыта мало)(возможен говнокод)')
            end
        end
        if imgui.CollapsingHeader(u8'Другие модификации') then
            imgui.TextWrapped(u8'Читать в дополнительно -> Другие модификации.txt')
        end
        if imgui.CollapsingHeader(u8'Реконнект') then
            imgui.TextWrapped(u8'Клео скрипт, реконнект v6 от AIR')
            imgui.TextWrapped(u8'Команды:')
            imgui.TextWrapped(u8'/rec [sec] - переподключает на сервер с заданной задержкой. Рекомендуется ставить минимум 10, если не указать - реконнектит сразу, но есть риск словить бан айпи')
            imgui.TextWrapped(u8'Также /rec может менять ник после реконнекта (/rec Eron_Evernos), смена айпи сервера (/rec 80.66.71.65:7777), смена буквенного айпи сервера (/rec s3.gta-mobile.ru:7777), рекконект с не целой задержкой (/rec 10.6 - реконнект через 10.6 секунд)')
            imgui.TextWrapped(u8'/arec [sec] - авто реконнект после разрыва подключения с сервером через заданную задержку')
            imgui.TextWrapped(u8'/fcon [режим] [sec] - изменение режима и времени фаст коннекта. Пример - /rec 0 1 - реконнектит раз в 1 секунду, /rec 1 1 - увеличение корректных запросов и повышение шансев на коннект к серверу')
            imgui.TextWrapped(u8'(не нужный?) /pcon [min] [max] - изменение порта подключения')
            imgui.TextWrapped(u8'/spassword [password] - изменяет пароль сервера (не входа в игру, а именно сервера). /spassword ставит пустое значение, /spassword 528363 (пример) меняет пароль от сервера на 528363')
        end
        if imgui.CollapsingHeader(u8'Реконнект на другие сервера') then
            if imgui.Button(u8'HMS (тест)') then
                sampConnectToServer('109.69.58.7', 7777)
            end
            if imgui.Button(u8'ORP | Texas') then
                sampConnectToServer('s1.gta-mobile.ru', 7777)
            end
            if imgui.Button(u8'ORP | Florida') then
                sampConnectToServer('s2.gta-mobile.ru', 7777)
            end
            if imgui.Button(u8'ORP | Nevada') then
                sampConnectToServer('80.66.71.65', 7777)
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

