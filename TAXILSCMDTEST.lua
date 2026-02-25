local sampev = require 'lib.samp.events'
local requests = require 'requests' 

-- CONFIGURARE AUTO-UPDATE (AICI MODIFICI TU DUPA CE FACI GITHUB-UL)
local script_version = 1.0
local script_name = "TAXILSCMDTEST"
local update_url = "https://raw.githubusercontent.com/deejayxoxofficial-cloud/taxicmd/refs/heads/main/version.json" 
local download_url = "https://raw.githubusercontent.com/deejayxoxofficial-cloud/taxicmd/refs/heads/main/TAXILSCMDTEST.lua"

local total_units = 0 

local questions = {
    ts = {[1] = {q = "Intrebare TS 1?", r = "Raspuns 1"}},
    tm = {[1] = {q = "Intrebare TM 1?", r = "Raspuns M1"}},
    tg = {[1] = {q = "Intrebare TG 1?", r = "Raspuns G1"}},
    teorie = {[1] = "Regulament etapa 1..."},
    practic = {
        "Proba teoretica a fost trecuta cu succes!",
        "Acum vom incepe proba practica.",
        "Toate greselile au fost resetate (0/3)."
    }
}

function getScorFormatat(u)
    local val = u / 100
    if u % 100 == 0 then return string.format("%d/3", val) end
    if u % 100 == 50 then return string.format("%.1f/3", val) end
    return string.format("%.2f/3", val)
end

function checkUpdate()
    lua_thread.create(function()
        local ok, response = pcall(requests.get, update_url)
        if ok and response.status_code == 200 then
            local json = response.json()
            if json and json.version > script_version then
                sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} Se descarca update v" .. json.version .. "...", -1)
                local dl_ok, dl = pcall(requests.get, download_url)
                if dl_ok and dl.status_code == 200 then
                    local file = io.open(thisScript().path, "wb")
                    file:write(dl.text)
                    file:close()
                    sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} Update finalizat! Scriptul se reincarca...", -1)
                    thisScript():reload()
                end
            end
        end
    end)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} v" .. script_version .. " incarcat! {33CC33}/comenzi", -1)
    sampAddChatMessage("{AAAAAA}Mod creat de Eqi(N)oux. from buGGed.ro", -1)
    
    -- Activeaza asta dupa ce ai link-urile de GitHub puse sus
    if update_url ~= "AICI_PUI_LINK_RAW_VERSION_JSON" then
        checkUpdate()
    end

    local function handleGresala(id_arg, val, msg_err, puncte_text)
        local id = tonumber(id_arg)
        if id == nil then 
            sampAddChatMessage("{FF0000}[Eroare] Scrie ID-ul corect!", -1)
            return 
        end
        
        local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if result and id == myid then
            sampAddChatMessage("{FF0000}[Eroare] Nu poti da pe propriul id!", -1)
            return
        end

        local name = sampGetPlayerNickname(id)
        if name == nil then
            sampAddChatMessage("{FF0000}[Eroare] Jucatorul nu este conectat!", -1)
            return
        end

        if not isCharInAnyCar(PLAYER_PED) then
            sampAddChatMessage("{FF0000}[Eroare] Trebuie sa fii intr-o masina!", -1)
            return
        end

        local exists, charHandle = sampGetCharHandleBySampPlayerId(id)
        if not exists then
            sampAddChatMessage("{FF0000}[Eroare] ID-ul " .. id .. " nu se afla in raza ta!", -1)
            return
        end

        local myCar = storeCarCharIsInNoSave(PLAYER_PED)
        if not isCharInCar(charHandle, myCar) then
            sampAddChatMessage("{FF0000}[Eroare] ID-ul " .. id .. " nu se afla in masina cu tine!", -1)
            return
        end

        local cleanName = tostring(name):gsub("_", " ")
        total_units = total_units + val
        local total_str = getScorFormatat(total_units)

        sampSendChat("/cw " .. msg_err .. " Ai primit " .. puncte_text .. " puncte de greseala. Total: " .. total_str)

        if total_units >= 300 then
            lua_thread.create(function()
                wait(800)
                sampSendChat("/cw @" .. cleanName .. ", din pacate ai acumulat " .. total_str .. " greseli si ai fost respins.")
                wait(1200)
                sampSendChat("/f Candidatul " .. cleanName .. " a acumulat " .. total_str .. " greseli la testul teoretic.")
                wait(1000)
                sampSendChat("/f Acesta a fost declarat respins. Testul s-a terminat.")
                total_units = 0 
            end)
        end
    end

    -- COMENZI
    sampRegisterChatCommand("gr25", function(arg) handleGresala(arg, 25, "Raspunsul tau este incomplet.", "0.25") end)
    sampRegisterChatCommand("gr50", function(arg) handleGresala(arg, 50, "Raspunsul tau este doar pe jumatate.", "0.5") end)
    sampRegisterChatCommand("gr75", function(arg) handleGresala(arg, 75, "Raspunsul tau este aproape gresit in totalitate.", "0.75") end)
    sampRegisterChatCommand("gr1",  function(arg) handleGresala(arg, 100, "Raspunsul tau este gresit.", "1") end)
    
    sampRegisterChatCommand("practic", function()
        total_units = 0
        lua_thread.create(function()
            for i=1, #questions.practic do
                sampSendChat("/cw " .. questions.practic[i])
                wait(1600)
            end
        end)
    end)

    sampRegisterChatCommand("comenzi", function()
        sampAddChatMessage("{FFFF00}--- COMENZI TEST TAXI ---", -1)
        sampAddChatMessage("{FFFFFF}/gr25, /gr50, /gr75, /gr1, /practic, /ts, /tm, /tg, /teor, /togall", -1)
    end)

    sampRegisterChatCommand("togall", function()
        local c = {"/turn off", "/toge", "/setfreq 0", "/tognews", "/togreports", "/togarrests", "/togc", "/togf", "/toglegend", "/togn", "/togvip"}
        for i=1, #c do sampSendChat(c[i]) end
    end)

    local function sendTest(type, arg)
        local idx = tonumber(arg)
        if idx and questions[type] and questions[type][idx] then
            sampAddChatMessage("{33CC33}[RASPUNS] {FFFFFF}" .. questions[type][idx].r, -1)
            sampSendChat("/cw " .. questions[type][idx].q)
        end
    end

    sampRegisterChatCommand("ts", function(arg) sendTest("ts", arg) end)
    sampRegisterChatCommand("tm", function(arg) sendTest("tm", arg) end)
    sampRegisterChatCommand("tg", function(arg) sendTest("tg", arg) end)
    sampRegisterChatCommand("teor", function(arg)
        local idx = tonumber(arg)
        if idx and questions.teorie[idx] then sampSendChat("/cw " .. questions.teorie[idx]) end
    end)

    wait(-1)
end