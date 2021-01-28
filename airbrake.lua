script_name("AirBrake")
script_authors("Clinton", "Baby")
script_version("0.2")


require 'lib.sampfuncs'
require 'lib.moonloader'

local inicfg = require("inicfg")
local sampev = require 'lib.samp.events'
local direct = 'moonloader\\config\\air.ini'
local main_color = 0xA012ED
local main_color_text = '{A012ED}'
local white_color = '{FFFFFF}'

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    repeat wait(0) until isSampAvailable()
    --_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    --nick = sampGetPlayerNickname(id)
    --wait(5000)
    --if nick == 'Tim_Rojers' then
      --  sampAddChatMessage('Произошел троллинг, ты выйдешь из игры через ' .. white_color .. '10' .. main_color_text .. ' секунд xD',main_color)
       -- wait(10000)
      --  sendEmptyPacket(PACKET_DISCONNECTION_NOTIFICATION)
      --  closeConnect()
      --  thisScript():unload()
   -- end
    if not doesDirectoryExist("moonloader\\config") then
        createDirectory("moonloader\\config")
    end
    settings = inicfg.load(nil, direct)
    wait(5000)
    if settings == nil or settings.SETTINGS.speedcar == nil or settings.SETTINGS.speedped == nil or settings.SETTINGS.key == nil then
        sampShowDialog(125466000228 ,'Информация','Вы в первый раз запустили скрипт поэтому значения будут выставлены по стандарту\n\n Скорость авто = 1.5\n Скорость персонажа = 0.3','Установить по стандарту','Отключить',0)
        repeat wait(0) until not sampIsDialogActive(125466000228)
        local res, button, list, input = sampHasDialogRespond(125466000228)
        if button == 1 then
            local settings = inicfg.load({
            SETTINGS = {
                speedcar = 1.5,
                speedped = 0.3,
                key = 161
                }
            }, '..\\config\\air.ini')
            inicfg.save(settings, '..\\config\\air.ini')
            settings = inicfg.load(nil, direct)
        else
            thisScript():unload()
        end
    end
    sampAddChatMessage('[AirBrake] - Версия скрипта 0.1',-1)
    sampAddChatMessage('[AirBrake] - Автор скрипта:Clinton',-1)
    sampRegisterChatCommand('aspeed', function() lua_thread.create(set) end)
    settings = inicfg.load(nil, direct)
    while true do wait(0)
        if isKeyJustPressed(settings.SETTINGS.key) and not sampIsDialogActive() then
            air = not air
            local posX, posY, posZ = getCharCoordinates(playerPed)
            airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
            lua_thread.create(airb)
        end
    end
end

function set()
    text = 'Скорость авто:\t '..settings.SETTINGS.speedcar.. '\nСкорость персонажа:\t'..settings.SETTINGS.speedped
    sampShowDialog(587342856,'AirBrake',text,'Продолжить', 'Закрыть',4)
    repeat wait(0) until sampIsDialogActive(587342856)
    local res, button, list, input = sampHasDialogRespond(587342856)
    if button == 1 and list == 0 then
        sampShowDialog(42424242,'Настройка скорости авто','Значение по умолчанию: 1.5\n\n Значение сейчас: '..settings.SETTINGS.speedcar,'Сохранить','Закрыть',1)
        repeat wait(0) until not sampIsDialogActive(42424242)
        res, button, list, input = sampHasDialogRespond(42424242)
        if button == 1 then
            input = tonumber(input)
            if input ~= nil and input >= 0.1 then
                settings.SETTINGS.speedcar = input
                inicfg.save(settings, '..\\config\\air.ini')
                settings = inicfg.load(nil, direct)
                sampAddChatMessage('Новое значение сохранено!',-1)
            else
                sampAddChatMessage('Новое значение введено неверно',-1)
            end
        end
    elseif button == 1 and list == 1 then
        sampShowDialog(65436534634,'Настройка скорости персонажа','Стандартное значение: 0.3\n\n Значение сейчас:'..settings.SETTINGS.speedped,'Сохранить','Закрыть',1)
        repeat wait(0) until not sampIsDialogActive(65436534634)
        res, button, list, input = sampHasDialogRespond(65436534634)
        if button == 1 then
            input = tonumber(input)
            if input ~= nil and input >= 0.1 then
                settings.SETTINGS.speedped = input
                inicfg.save(settings, '..\\config\\air.ini')
                settings = inicfg.load(nil, direct)
                sampAddChatMessage('Новое значение сохранено!', -1)
            else
                sampAddChatMessage('Новое значение введено неверно!' -1)
            end
        end
    end
end

function airb()
    sh = {}
    if air then sampAddChatMessage('[AirBrake] - Активирован', -1) else sampAddChatMessage('[AirBrake] - Деактивирован', -1) end
    while air do wait(0)
        local _, id = sampGetPlayerIdByCharHandle(playerPed)
        local fX, fY, fZ = getActiveCameraCoordinates()
        local zX, zY, zZ = getActiveCameraPointAt()
        local heading = getHeadingFromVector2d(zX - fX, zY - fY)
        if isCharInAnyCar(PLAYER_PED) then
            car = getCarCharIsUsing(playerPed)
            setCarHeading(car, heading)
            setCarProofs(car, true, true, true, true, true)
            local _, id = sampGetVehicleIdByCarHandle(car)
            if getDriverOfCar(getCarCharIsUsing(PLAYER_PED)) == -1 then
                pcall(sampForcePassengerSyncSeatId, sh[1], sh[2])
                pcall(sampForceUnoccupiedSyncSeatId, sh[1], sh[2])
            else
                pcall(sampForceVehicleSync, sh[1])
            end
            speed = settings.SETTINGS.speedcar
        elseif not isCharInAnyCar(PLAYER_PED) then
            setCharHeading(PLAYER_PED, heading)
            setCharProofs(PLAYER_PED, true, true, true, true, true)
            speed = settings.SETTINGS.speedped
            pcall(sampForceOnfootSync)
        end
        setCharCoordinates(PLAYER_PED, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] - 0.79)
        if not sampIsChatInputActive() and not sampIsDialogActive() then
            if isKeyDown(VK_SPACE) then
                airBrkCoords[3] = airBrkCoords[3] + speed / 2.0
            elseif isKeyDown(VK_LSHIFT) and airBrkCoords[3] > -95.0 then
                airBrkCoords[3] = airBrkCoords[3] - speed / 2.0
            end
            if isKeyDown(VK_W) then
                airBrkCoords[1] = airBrkCoords[1] + speed * math.sin(-math.rad(heading))
                airBrkCoords[2] = airBrkCoords[2] + speed * math.cos(-math.rad(heading))
            elseif isKeyDown(VK_S) then
                airBrkCoords[1] = airBrkCoords[1] - speed * math.sin(-math.rad(heading))
                airBrkCoords[2] = airBrkCoords[2] - speed * math.cos(-math.rad(heading))
            end
            if isKeyDown(VK_A) then
                airBrkCoords[1] = airBrkCoords[1] - speed * math.sin(-math.rad(heading - 90))
                airBrkCoords[2] = airBrkCoords[2] - speed * math.cos(-math.rad(heading - 90))
            elseif isKeyDown(VK_D) then
                airBrkCoords[1] = airBrkCoords[1] + speed * math.sin(-math.rad(heading - 90))
                airBrkCoords[2] = airBrkCoords[2] + speed * math.cos(-math.rad(heading - 90))
            end
        end
    end
end

function getMoveSpeed(heading, speed)
    moveSpeed = {x = math.sin(-math.rad(heading)) * speed, y = math.cos(-math.rad(heading)) * speed, z = -0.0000001}
    return moveSpeed
end

function sampev.OnSendPlayerSync(data)
    if air then
        sh = {data.vehicleId}
        if sh[1] ~= nil then
            local _, veh = sampGetCarHandleBySampVehicleId(data.vehicleId)
            if _ then
                local fX, fY, fZ = getActiveCameraCoordinates()
                local zX, zY, zZ = getActiveCameraPointAt()
                local heading = getHeadingFromVector2d(zX - fX, zY - fY)
                data.moveSpeed = getMoveSpeed(heading, 1.250)
                data.position = {airBrkCoords[1], airBrkCoords[2], airBrkCoords[3]}
                return data
            end
        end
    end
end

function sampev.onSendUnoccupiedSync(data)
    if air then
        sh = {data.vehicleId, data.seatId}
        if sh[1] ~= nil and isCharInAnyCar(PLAYER_PED) then
            local veh = getCarCharIsUsing(PLAYER_PED)
            local _, id = sampGetVehicleIdByCarHandle(veh)
            if _ then
                if id == data.vehicle then
                    local fX, fY, fZ = getActiveCameraCoordinates()
                    local zX, zY, zZ = getActiveCameraPointAt()
                    local heading = getHeadingFromVector2d(zX - FfX, zY - fY)
                    data.moveSpeed = getMoveSpeed(heading, 0.200)
                    data.position = {airBrkCoords[1], airBrkCoords[2], airBrkCoords[3]}
                    return data
                end
            end
        end
    end
end

function sampev.onSendPassengerSync(data)
    if air then
        sh = {data.vehicleId, data.seatId}
    end
end

function sendEmptyPacket(id)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt8(bs, id)
	raknetSendBitStream(bs)
	raknetDeleteBitStream(bs)
end

function closeConnect()
	local bs = raknetNewBitStream()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, bs)
	raknetDeleteBitStream(bs)
end
