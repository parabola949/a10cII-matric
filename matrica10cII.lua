package.path  = package.path..";.\\LuaSocket\\?.lua;"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"
package.path  = package.path..";.\\LuaSocket\\?.lua"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll"

local MATRIC = {}
local mtrxlog = nil
MATRIC.ipaddr = "127.0.0.1"
MATRIC.port = 50300
MATRIC.PIN = "9087"
MATRIC.appName = "MATRIC4DCS"
MATRIC.clientId = "VEZuADGZoejrLPtX3y4IMKgCiCHNxVTo6exKqPQeEIU="
MATRIC.updatePeriod = 0.2
local socket = require("socket")
MATRIC.conn = socket.udp()
MATRIC.conn:settimeout(0)
MATRIC.conn:setpeername(MATRIC.ipaddr, MATRIC.port)
JSON = loadfile("Scripts\\JSON.lua")()

--returns the data structure that MATRIC expects for SETDECK command
MATRIC.cmdSETDECK = function()
    return {
        command = "SETDECK",
        appName = MATRIC.appName,
        appPin = MATRIC.PIN,
        clientId = MATRIC.clientId,
        deckId = "",
        pageId = ""
    }   
end    

MATRIC.cmdSETBUTTONSVISUALSTATE = function()
	return {
		command = "SETBUTTONSVISUALSTATE",
		appName = MATRIC.appName,
		appPin = MATRIC.PIN,
		clientId = MATRIC.clientId,
		data = {}
		
	}
end

--returns the data structure that MATRIC expects for SETACTIVEPAGE command
MATRIC.cmdSETACTIVEPAGE = function()
    return {
        command = "SETACTIVEPAGE",
        appName = MATRIC.appName,
        appPin = MATRIC.PIN,
        clientId = MATRIC.clientId,
        pageId = ""
    }
end

--returns the data structure that MATRIC expects for SETBUTTONPROPS command
MATRIC.cmdSETBUTTONPROPS = function()
    return {
        command = "SETBUTTONPROPS",
        appName = MATRIC.appName,
        appPin = MATRIC.PIN,
        clientId = MATRIC.clientId,
        buttonId = "",
        data = {
            imageOff = nil,
            imageOn = nil,
            textcolorOn = nil,
            textcolorOff = nil,
            backgroundcolorOn = nil,
            backgroundcolorOff = nil,
            fontSize = nil,
            text = nil,
            halign = nil,
            valign = nil,
            padding = nil,
        }
    }
end

--returns the data structure that MATRIC expects for SETBUTTONPROPSEX command
MATRIC.cmdSETBUTTONPROPSEX = function()
    return {
        command = "SETBUTTONPROPSEX",
        appName = MATRIC.appName,
        appPin = MATRIC.PIN,
        clientId = MATRIC.clientId,
        data = {}
    }
end

MATRIC.buttonState = function()
	return {
		buttonId = nil,
		state = nil
	}
end

----returns the data structure containing button props we can modify
MATRIC.buttonProps = function()
    return {
        buttonId = nil,
        imageOff = nil,
        imageOn = nil,
        textcolorOn = nil,
        textcolorOff = nil,
        backgroundcolorOn = nil,
        backgroundcolorOff = nil,
        fontSize = nil,
        text = nil,
        halign = nil,
        valign = nil,
        padding = nil,
    }
end

local _prevExport = {}
_prevExport.LuaExportActivityNextEvent = LuaExportActivityNextEvent
_prevExport.LuaExportBeforeNextFrame = LuaExportBeforeNextFrame
_prevExport.LuaExportStart = LuaExportStart
_prevExport.LuaExportStop = LuaExportStop
mtrxlog = io.open(lfs.writedir().."/Logs/matric_connector_log.txt", "w")
function LuaExportStart()
    --initialize
    --mtrxlog = io.open(lfs.writedir().."/Logs/matric_connector_log.txt", "w")
    mtrxlog:write("-- LOG start --")
    --ToDo: set deck, page
    local _status,_result = pcall(function()
        -- Call original function if it exists
        if _prevExport.LuaExportStart then
                _prevExport.LuaExportStart()
        end    
    end)
  end
  
  function LuaExportStop()
    if mtrxlog then
        mtrxlog:write("-- LOG end --")
        mtrxlog:close()
        mtrxlog = nil
    end
    local _status,_result = pcall(function()
        -- Call original function if it exists
        if _prevExport.LuaExportStop then
                _prevExport.LuaExportStop()
        end    
    end)
  end

LuaExportActivityNextEvent = function(tCurrent)
    local tNext = tCurrent + MATRIC.updatePeriod
	if (LoGetSelfData() ~= nil) then
		--mtrxlog = io.open(lfs.writedir().."/Logs/matric_connector_log.txt", "w")
		--mtrxlog:write(LoGetSelfData().Name)
		if (LoGetSelfData().Name == "A-10C_2") then
			UpdateMATRICa10()
		end	
	end

    -- call original
    local _status,_result = pcall(function()
        -- Call original function if it exists
        if _prevExport.LuaExportActivityNextEvent then
                _prevExport.LuaExportActivityNextEvent(tCurrent)
        end
    end)
    return tNext
end

LuaExportBeforeNextFrame = function()   
    -- call original
    _status,_result = pcall(function()
        -- Call original function if it exists
        if _prevExport.LuaExportBeforeNextFrame then
            _prevExport.LuaExportBeforeNextFrame()
        end
    end)
end    

function SendMATRICCommand(data)
    mtrxlog:write("sending UDP update")
    mtrxlog:write(JSON:encode_pretty(data))
    socket.try(MATRIC.conn:send(JSON:encode_pretty(data)))
end    

--Here we have button Ids of the buttons that we shall control with our script
--In the future we might add an option to add a "name" to the button so that we do not need to address them by this horrible mess but instead by names like "ADI_BANK_INDICATOR" or whatever you call your button
--Integration API is still in active development
local A10 = {
    deckId = "e4489b8f-28e3-4d19-b2a7-e66b699202ba",
    initialPageId = "596dfe21-1508-49af-8b9c-21765572fd7b",
    bBANK = "d81e2ccf-7c07-40f7-b8bc-a36162a0d887",
    bPITCH = "a847c207-8d77-43f8-9b0e-b703899eccac",
    bHEADING = "5103f719-4e52-49b7-a333-88abbd872859",
    bALT = "64c3dc12-0296-4460-b865-6b8d3fe98a77",
    bFD = "b7f59734-a19c-4fd4-8ada-631c681cda11",
    bGUNPAC = "54c4f0b7-a50f-46b9-adbc-1597b55eb08d",
    bMASTERARM = "5c701911-f9f8-47ab-b191-da4644ace68c",
    bLASER = "a9747d4d-dc6d-4c3b-a8b5-b33f919595c6",
	bTGP = "a6a48663-53df-4f2c-8553-50d7019b129d",
	bAntiSkid = "09a01f85-b895-4582-9667-23903ee71daa",
	bCICU = "fbca8284-21d2-4ade-8ae0-400f697f4e9c",
	bJTRS = "0592c707-9f55-4838-ae7d-15aa5df09611",
	bIFFCCTest = "38bcf9de-217e-4297-9f7c-36fda75d8713",
	bIFFCCOn = "f071497d-9ccf-47fc-bc9f-e9328f83ba31",
	bAPUGEN = "256c2335-d485-441d-b8fd-6dba74308bef",
	bInverter = "27b43de6-3dd3-4e01-aacf-e95c4367a37a",
	bBattery = "7732b1cb-5a48-4262-b7c3-3190bb4a5409",
	bHMCS = "771ba074-1df8-4af3-8fe0-eda4926fddb7",
	bCDU = "78efad11-4089-417a-bcd1-f5976a1fc110",
	bEGI = "48f1c6ef-253a-4f15-a16d-b6625a5dfed4",
    MasterArmStatusId = 375,
    LaserOnId = 377,
	GunpacStatusId = 376,
	TgpStatusId = 378,
	CicuStatusId = 382,
	JtrsStatusId = 383,
	IffccStatusId = 384,
	AntiSkidStatusId = 654,
	ApuGenStatusId = 241,
	BatteryStatusId = 246,
	InverterStatusId = 242,
	CduStatusId = 476,
	EgiStatusId = 477,
	HmcsStatusId = 550,
    UV26DisplayId = 7,
    bTGTSYS = "0076cd7d-1a49-462d-9da7-eb3133b865cf",
    bUV26Display = "4fdecf9d-c1e8-4711-ae1b-db99f8f7d65b",
    TargetingSystemOnId = 433
}

function UpdateMATRICa10()
    -- Inspect the state of flight director and update matric buttons
    local cmd = MATRIC:cmdSETBUTTONSVISUALSTATE()
    local mainPanel = GetDevice(0)

    --Master arm
    cmd.data[1] = MATRIC.buttonState()
    cmd.data[1].buttonId = A10.bMASTERARM
	local tempVal = mainPanel:get_argument_value(A10.MasterArmStatusId)
	--mtrxlog:write(tempVal)
    if (tempVal < 0.2) then        
        cmd.data[1].state = "off"
    elseif (tempVal > 0.2) then 
        cmd.data[1].state = "on"
    end

    --Laser
    cmd.data[2] = MATRIC.buttonState()
    cmd.data[2].buttonId = A10.bLASER
	tempVal = mainPanel:get_argument_value(A10.LaserOnId)
    if (tempVal < 0.2) then        
        cmd.data[2].state = "off"
    elseif (tempVal > 0.2) then 
        cmd.data[2].state = "on"
    end

	--GUNPAC
    cmd.data[3] = MATRIC.buttonState()
    cmd.data[3].buttonId = A10.bGUNPAC
	tempVal = mainPanel:get_argument_value(A10.GunpacStatusId)
    if (tempVal < 0.2) then        
        cmd.data[3].state = "off"
    elseif (tempVal > 0.2) then 
        cmd.data[3].state = "on"
    end

	--TGP
	cmd.data[4] = MATRIC.buttonState()
    cmd.data[4].buttonId = A10.bTGP
	if (mainPanel:get_argument_value(A10.TgpStatusId) == 1) then
		cmd.data[4].state = "on"
	else
		cmd.data[4].state = "off"
	end
	
	--CICU
	cmd.data[5] = MATRIC.buttonState()
    cmd.data[5].buttonId = A10.bCICU
	if (mainPanel:get_argument_value(A10.CicuStatusId) == 1) then
		cmd.data[5].state = "on"
	else
		cmd.data[5].state = "off"
	end
	
	--JTRS
	cmd.data[6] = MATRIC.buttonState()
    cmd.data[6].buttonId = A10.bJTRS
	if (mainPanel:get_argument_value(A10.JtrsStatusId) == 1) then
		cmd.data[6].state = "on"
	else
		cmd.data[6].state = "off"
	end
	
	--IFFCC
	cmd.data[7] = MATRIC.buttonState()
    cmd.data[7].buttonId = A10.bIFFCCOn
	cmd.data[8] = MATRIC.buttonState()
	cmd.data[8].buttonId = A10.bIFFCCTest
	tempVal = mainPanel:get_argument_value(A10.IffccStatusId)
    if (tempVal < 0.2) then
		if(tempVal > 0) then
			cmd.data[8].state = "on"
			cmd.data[7].state = "off"
		end
    elseif (tempVal > 0.2) then 
        cmd.data[7].state = "on"
		cmd.data[8].state = "off"
	else
		cmd.data[7].state = "off"
		cmd.data[8].state = "off"
    end
	
	--APU GEN
	cmd.data[9] = MATRIC.buttonState()
    cmd.data[9].buttonId = A10.bAPUGEN
	if (mainPanel:get_argument_value(A10.ApuGenStatusId) == 1) then
		cmd.data[9].state = "on"
	else
		cmd.data[9].state = "off"
	end
	
	--Inverter
	cmd.data[10] = MATRIC.buttonState()
    cmd.data[10].buttonId = A10.bInverter
	tempVal = mainPanel:get_argument_value(A10.InverterStatusId)
    if (tempVal < 0.2) then        
        cmd.data[10].state = "off"
    elseif (tempVal > 0.2) then 
        cmd.data[10].state = "on"
    end
	
	local i = 11
	--Battery
	cmd.data[i] = MATRIC.buttonState()
    cmd.data[i].buttonId = A10.bBattery
	if (mainPanel:get_argument_value(A10.BatteryStatusId) == 1) then
		cmd.data[i].state = "on"
	else
		cmd.data[i].state = "off"
	end
	i = 12
	--Antiskid
	cmd.data[i] = MATRIC.buttonState()
    cmd.data[i].buttonId = A10.bAntiSkid
	if (mainPanel:get_argument_value(A10.AntiSkidStatusId) == 1) then
		cmd.data[i].state = "off"
	else
		cmd.data[i].state = "on"
	end
	i = 13
	
	--HMCS
	cmd.data[i] = MATRIC.buttonState()
    cmd.data[i].buttonId = A10.bHMCS
	if (mainPanel:get_argument_value(A10.HmcsStatusId) == 1) then
		cmd.data[i].state = "on"
	else
		cmd.data[i].state = "off"
	end
	i = 14
	--CDU
	cmd.data[i] = MATRIC.buttonState()
    cmd.data[i].buttonId = A10.bCDU
	if (mainPanel:get_argument_value(A10.CduStatusId) == 1) then
		cmd.data[i].state = "on"
	else
		cmd.data[i].state = "off"
	end
	i = 15
	--EGI
	cmd.data[i] = MATRIC.buttonState()
    cmd.data[i].buttonId = A10.bEGI
	if (mainPanel:get_argument_value(A10.EgiStatusId) == 1) then
		cmd.data[i].state = "on"
	else
		cmd.data[i].state = "off"
	end
	i = 16
	
    --UV-26 display
    --cmd.data[10] = MATRIC.buttonProps()
    --cmd.data[10].buttonId = KA50.bUV26Display
    --if (_getListIndicatorValue(KA50.UV26DisplayId) ~= nil) then
    --    local uv26text = _getListIndicatorValue(KA50.UV26DisplayId).txt_digits
    --    cmd.data[10].text = uv26text
    --end

    --mtrxlog:write(JSON:encode_pretty(uv26))
    SendMATRICCommand(cmd)
    --mtrxlog:write(JSON:encode_pretty(LoGetSelfData()))
    --mtrxlog:write(JSON:encode_pretty(autopilotState))
end    

function _getListIndicatorValue(IndicatorID)
	local ListIindicator = list_indication(IndicatorID)
	local TmpReturn = {}
	
	if ListIindicator == "" then
		return nil
	end

	local ListindicatorMatch = ListIindicator:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
	while true do
		local Key, Value = ListindicatorMatch()
		if not Key then
			break
		end
		TmpReturn[Key] = Value
	end

	return TmpReturn
end