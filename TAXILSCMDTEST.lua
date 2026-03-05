local requests = require 'requests'
local sampev = require 'lib.samp.events'

-- CONFIGURARE AUTO-UPDATE
local script_version = 1.7
local last_update = "05/03/2026 - 11:34"
local script_name = "TAXICMD"
local update_url = "https://raw.githubusercontent.com/deejayxoxofficial-cloud/taxicmd/refs/heads/main/version.json" 
local download_url = "https://raw.githubusercontent.com/deejayxoxofficial-cloud/taxicmd/refs/heads/main/TAXICMD.lua"

-- VARIABILE TEST
local greseli_teorie = 0
local greseli_practic = 0

local questions = {
    ts = {
        [1] = {q = "1. Cu ce se ocupa compania de taxi din orasul Los Santos?", r = "Raspuns: Taxi Los Santos se ocupa cu transportarea jucatorilor intr-o anumita locatie contra-cost."},
        [2] = {q = "2. Ce job-uri nu pot fi practicate ca si taximetrist?", r = "Raspuns: Drug Dealer si Car Jacker."},
        [3] = {q = "3. In cate locatii esti obligat sa transporti minim un client?", r = "Raspuns: O locatie."},
        [4] = {q = "4. Unde poti reclama un coleg de factiune?", r = "Raspuns: La scam/other sau SS si PM leader."},
        [5] = {q = "5. Ce sanctiune primesti in cazul in care raspunzi la telefon in timpul unei comenzi?", r = "Raspuns: Avertisment Verbal."},
        [6] = {q = "6. Care este sanctiunea pe care o vei suporta daca iti vei modifica taxiul cu NOS?", r = "Raspuns: Faction Warn."},
        [7] = {q = "7. In cazul in care in taxi, se urca simultan doi playeri, care dintre ei are prioritate?", r = "Raspuns: Primul care va spune locatia are prioritate."},
        [8] = {q = "8. Cand iti este permisa repararea taxiului fara a avea nevoie de aprobarea clientului?", r = "Raspuns: Cand are minim 500hp in [/dl]. (sau sub 500hp)"},
        [9] = {q = "9. Cum procedezi daca in timpul desfasurarii comenzii, i se acorda [/slap] clientului?", r = "Raspuns: Este obligat sa il astepte."},
        [10] = {q = "10. Cum procedezi in momentul in care un client scoate arma pe geam?", r = "Raspuns: Este nevoit sa ii acorde [/eject] cat mai rapid."},
        [11] = {q = "11. Care sunt locatiile pe care trebuie sa le cunosti in mod obligatoriu?", r = "Raspuns: Cele din [/jobs], [/billboards], [/gps]."},
        [12] = {q = "12. Ai voie sa vinzi materiale sau sa cumperi?", r = "Raspuns: Da."},
        [13] = {q = "13. Cum procedezi cand ti se acorda o locatie pe care nu esti obligat sa o cunosti?", r = "Raspuns: Trebuie sa intrebe clientul despre un reper valid / il pot refuza."},
        [14] = {q = "14. Da-mi 3 exemple pentru care poti folosi comanda [/eject].", r = "Raspuns: l-ai dus deja la o locatie/doreste sa fie plimbat/nu specifica locatie\nRaspuns: e afk cand a ajuns la destinatie/scoate arma/injura/doreste eject"},
        [15] = {q = "15. Cat timp ai la dispozitie pentru a plati o amenda?", r = "Raspuns: 24 de ore."},
        [16] = {q = "16. Care este [/fare-ul] folosit pentru colegii din taxi?", r = "Raspuns: [/fare-ul] este 0."},
        [17] = {q = "17. Ofera-mi 3 exemple de motive pentru care poti folosi comanda [/cancel taxi].", r = "Raspuns: Explodezi/cazi in apa; clientul se plimba cu alta masina; fuge pe jos; refuza sa se urce."},
        [18] = {q = "18. De cate ori aveti voie sa transportati un player ce doreste sa faca materiale [...]\n[...] la punctele de colectare din LS sau LV?", r = "Raspuns: Il poate transporta doar o singura data."},
        [19] = {q = "19. Cum procedezi in momentul in care locatia ceruta de client are mai multe puncte in [/gps]?", r = "Raspuns: Poate intreba clientul la care din ele doreste/il duce la cea mai apropiata."},
        [20] = {q = "20. Care este sanctiunea pe care o vei suporta in cazul in care vei face spam cu [/fare]?", r = "Raspuns: Faction Warn."}
    },
    tm = {
        [1] = {q = "1. Cu ce se ocupa Taxi Los Santos?", r = "Raspuns: Taxi Los Santos se ocupa cu transportarea jucatorilor intr-o anumita locatie contra-cost."},
        [2] = {q = "2. In ce interval orar ai voie sa faci materiale?", r = "Raspuns: Poti face materiale oricand, nu exista un interval anume."},
        [3] = {q = "3. Care sunt locatiile importante pe care esti obligat sa le cunosti?", r = "Raspuns: Locatiile din [/gps], [/jobs], [/billboards]."},
		[4] = {q = "4. Cu ce esti sanctionat daca, in timpul unei curse, efectuezi o ocolire de 1250m?", r = "Raspuns: Avertisment Verbal."},
        [5] = {q = "5. Daca clientul iti da o locatie neimportanta pe care nu o stii, cum procedezi?", r = "Raspuns: Trebuie sa ii cer un punct de reper si il pot duce acolo / il refuz."},
        [6] = {q = "6. Care este [/fare-ul] folosit pentru colegii din taxi?", r = "Raspuns: [/fare-ul] este 0."},
		[7] = {q = "7. La ce rank-uri esti obligat sa-ti schimbi skin-ul?", r = "Raspuns: Sunt obligat sa fac asta la rank-urile 1, 2 si 4 (optional tester / co-lider)."},
        [8] = {q = "8. Daca vei stationa in timpul unei comenzi pentru 20 de secunde, ce sanctiune primesti?", r = "Raspuns: Nu se acorda vreo sanctiune."},
        [9] = {q = "9. Daca vorbesti la telefon in timpul comenzii, cu ce esti sanctionat?", r = "Raspuns: Sunt sanctionat cu un Avertisment Verbal (AV)."},
		[10] = {q = "10. Daca ai dus clientul la o locatie si ti-o cere pe a 2-a, iar tu [...]\n[...] nu ai vreo dovada de la prima locatie, cum vei proceda?", r = "Raspuns: Trebuie sa mai fie dus minim una, ca sa am dovezi pentru 2 locatii."},
        [11] = {q = "11. Unde ai voie sa reclami un coleg de factiune daca a gresit cu ceva?", r = "Raspuns: Am voie sa il reclam doar la 'Other/Scam' pe panel sau prin PM liderului."},
        [12] = {q = "12. Daca in taxi urca simultan 2 playeri si cer 2 locatii diferite, cum procedezi?", r = "Raspuns: Sunt obligat sa il duc pe cel care a zis primul locatia."},
		[13] = {q = "13. Cum procedezi in momentul in care un client scoate arma pe geam?", r = "Raspuns: Trebuie sa ii acorzi [/eject] cat mai rapid."},
        [14] = {q = "14. Spune-mi 3 cazuri in care ai voie sa acorzi [/eject] unui client.", r = "Raspuns: Cand ma injura, face DM, cere mai mult de o locatie, vrea sa fie plimbat."},
        [15] = {q = "15. Ce sanctiune primesti in cazul in care folosesti emoticoane pe chat-ul [/tx]?", r = "Raspuns: Amenda $7.000.000."},
		[16] = {q = "16. In ce cazuri ai voie sa folosesti [/taxi cancel]? Spune-mi 3 motive.", r = "Raspuns: Atunci cand am cazut in apa / am bubuit, cand clientul fuge de mine cu alt vehicul."},
        [17] = {q = "17. Ce ai voie sa anunti pe chat-ul [/tx]? Spune-mi 3 exemple.", r = "Raspuns: Sa cer un FVR, sa anunt un post-hunter, sa intreb de o situatie mai dificila."},
        [18] = {q = "18. Iti este permis sa repari fara acordul clientului daca masina are 483 de HP in [/dl]?", r = "Raspuns: Da, am voie sa o repar daca masina are sub 500 de HP in [/dl]."},
		[19] = {q = "19. Spune-mi toate comenzile factiunii si ce face fiecare in parte.", r = "Raspuns: /taxi accept, /taxi cancel, /fare, /f, /gdeposit, /tx."},
        [20] = {q = "20. Cand ai voie sa transporti un player daca ai wanted?", r = "Raspuns: Niciodata, este strict interzis sa fac raport daca am wanted."},
		[21] = {q = "21. Daca un alt taximetrist accepta o comanda, iar tu esti langa acel jucator, ce e de facut?", r = "Raspuns: Nu am voie sa iau clientul colegului care a acceptat comanda."},
        [22] = {q = "22. Care este cantitatea de droguri pe care o poti cumpara zilnic?", r = "Raspuns: Nu am voie sa detin droguri daca fac parte dintr-o factiune de taxi."}
    },
    tg = {
        [1] = {q = "1. Cu ce se ocupa Taxi Los Santos?", r = "Raspuns: Taxi Los Santos se ocupa cu transportarea jucatorilor intr-o anumita locatie contra-cost."},
        [2] = {q = "2. Daca ai transportat din greseala un coleg cu [/fare] ON, iar cursa a fost de $1.500 [...]\n [...] ce primesti?", r = "Raspuns: Nimic, sanctiunea se acorda de la $2.000+."},
        [3] = {q = "3. Da-mi 4 exemple de cazuri in care poti folosi comanda [/eject] unui client.", r = "Raspuns: Atunci cand face DM, cand jigneste, cand nu spune o locatie, cand doreste sa fie plimbat."},
		[4] = {q = "4. Spune-mi toate comenzile factiunii si ce fac acestea.", r = "Raspuns: /duty; /fare; /taxi accept; /taxi cancel; /f; /tx; /gdeposit."},
        [5] = {q = "5. Poti transporta un player care doreste sa faca Arms Dealer?", r = "Raspuns: Da. INTREABA-L DE CATE ORI ARE VOIE DUPA CE RASPUNDE!!!"},
        [6] = {q = "6. Poti face afaceri cu materiale?", r = "Raspuns: Da."},
		[7] = {q = "7. Ce locatii trebuie sa cunosti in mod obligatoriu?", r = "Raspuns: /gps]; [/jobs]; [/billboards]"},
        [8] = {q = "8. Daca in taxi se urca 2 jucatori si sunt impreuna, dupa cate locatii le poti acorda [/eject]?", r = "Raspuns: Le pot acorda [/eject] dupa o locatie daca sunt impreuna (cu dovezile necesare celei prime locatie)."},
        [9] = {q = "9. Spune-mi limitele ocolirii, in metri, pentru care esti sanctionat cu AV si respectiv FW.", r = "Raspuns: Av - 1000+ D: #bringbackfw."},
		[10] = {q = "10. Ce primesti daca vorbesti la telefon in timpul unei comenzi?", r = "Raspuns: Avertisment Verbal."},
        [11] = {q = "11. La ce rank-uri esti obligat sa-ti schimbi skin-ul?", r = "Raspuns: Sunt obligat sa fac asta la rank-urile 1, 2 si 4 (optional tester / co-lider)."},
        [12] = {q = "12. Vehiculul tau are in [/dl] 550HP si tocmai ai primit o comanda pe Chilliad, poti repara [...]\n[...] fara sa mai ceri permisiunea clientului?", r = "Raspuns: Nu, vehiculul are peste limita minima care iti permite sa-l repari fara permisiune."},
		[13] = {q = "13. Daca vei stationa mai mult de 1 minut in timpul unei comenzi, cu ce vei fi sanctionat?\nDar daca vei stationa mai mult de 30 de secunde, ce vei primi?", r = "Raspuns: Faction Warn (FW)-1min+ / Avertisment VerbaL (AV)-30sec+."},
        [14] = {q = "14. Ce sanctiune primesti in cazul in care folosesti emoticoane pe chat-ul [/tx]?", r = "Raspuns: Amenda $7.000.000."},
        [15] = {q = "15. In cazul in care vei face spam cu [/fare], ce vei primi?", r = "Raspuns: Faction Warn."},
		[16] = {q = "16. Daca permisul iti va fi confiscat, care este sanctiunea pe care o vei suporta?", r = "Raspuns: Amenda in valoare de $10.000.000."},
        [17] = {q = "17. Ai voie sa iti reclami un coleg pe panel?", r = "Raspuns: Se poate face reclamatie la 'scam/other' sau se poate da PM la lider."},
        [18] = {q = "18. Ca taximetrist ce arme esti obligat sa detii cand dai [/rob]?", r = "Raspuns: Pot detine orice arma atunci cand dau [/rob]."},
		[19] = {q = "19. Ce sanctiune vei primi in cazul in care vei transporta un player pe capota taxiului [..]\n[..] in timpul unei comenzi?", r = "Raspuns: Av - prima abatere; FW - urmatoarele abateri."},
        [20] = {q = "20. Poti face raport daca ai wanted?", r = "Raspuns: Nu."},
        [21] = {q = "21. Da-mi exemplu de 4 situatii in care poti folosi comanda [/taxi cancel].", r = "Raspuns: Refuza sa urce, foloseste o alta masina, fuge pe jos; ai bubuit/intrat in apa; cere /cancel."},
		[22] = {q = "22. Cum procedezi in cazul in care clientul tau este somat de catre politie?", r = "Raspuns: Trebuie sa opreasca si sa ii ofere [/eject]."},
		[23] = {q = "23. Esti obligat sa anunti pe [/f] cand ai luat o masina a factiunii?", r = "Raspuns: Nu, nu esti obligat sa anunti acest lucru."},
        [24] = {q = "24. In ce situatii poti transporta un client daca acesta are wanted?", r = "Raspuns: Poate fi transportat oricand, daca este somat, trebuie predat politiei."}
    },
  teorie = {
        -- Slot 1
        [1] = { 
            "Salut @nume, cu mine vei sustine testul de intrare in factiune.",
            "Pentru inceput te voi ruga sa iti opresti telefonul, [/turn off].",
			"Te rog sa imi dai [/pay 1$] pentru a putea continua cu informatiile."
        },
        -- Slot 2
        [2] = { 
            "Testul va consta in doua probe: una teoretica si una practica.",
            "Proba teoretica este alcatuita dintr-o serie de intrebari din regulamentul general si intern taxi.",
            "Cea practica va contine o serie de locatii in care va trebui sa demonstrezi ca le cunosti." 
        },
        -- Slot 3
        [3] = { 
            "Fiecare greseala va fi notata si punctata cu 0,25/3 ; 0,5/3 sau 1/3, in functie de informatia lipsa.",
            "Pentru un raspuns gresit sau pe langa subiect vei primi 1/3.",
            "Ai la dispozitie 60 de secunde pentru a raspunde la o intrebare.", 
			"Daca vei ajunge la 3/3 greseli, esti in mod automat picat."
        },
        -- Slot 4
        [4] = { 
            "In cazul in care vei primi 'crash' in timpul testului ai la dispozitie 5 minute sa revii.",
            "Daca ai primit de doua ori crash in timpul testului, esti automat respins.",
            "Daca te deconectezi intentionat, [/q] esti automat respins.", 
			"Sa incepem!"
        }
    },
    practic = {
        "Testul teoretic s-a incheiat, sa trecem la cel practic.",
        "Pentru ocolire vei primit 0.5/3, pentru locatie nestiuta vei primi 1/3.",
        "Punctajul pe care l-ai obtinut la teoretic este separat de cel practic.",
		"Mult succes!"
    }
}

function main()
    while not isSampAvailable() do wait(100) end
    
    sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} Mod creat de {FFFF00}Eqi(N)oux.{FFFFFF} from {FFFF00}buGGed.ro", -1)
    sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} Scrie {FFFF00}/taxicmd{FFFFFF} pentru lista de comenzi si ce fac acestea.", -1)

    lua_thread.create(function()
        -- Asteptam pana cand jucatorul este spawnat (a trecut de login)
        while not sampIsLocalPlayerSpawned() do wait(1000) end
        
        -- Dupa ce s-a spawnat, mai asteptam 3 secunde sa se incarce textdraw-urile
        wait(3000)
        
        -- Acum pornim verificarea de update
        if checkUpdate then checkUpdate() end
    end)

    sampRegisterChatCommand("taxicmd", showHelp)
   -- sampRegisterChatCommand("comenzi", showCommands)
    sampRegisterChatCommand("togall", runTogAll)

    -- COMENZI INTREBARI
    sampRegisterChatCommand("ts", function(arg) sendTest("ts", arg) end)
    sampRegisterChatCommand("tm", function(arg) sendTest("tm", arg) end)
    sampRegisterChatCommand("tg", function(arg) sendTest("tg", arg) end)
    
    -- LEGATURA CATRE HANDLE-UL DE MAI JOS
    sampRegisterChatCommand("teor", handleTeorie)

    -- UPDATE
	sampRegisterChatCommand("taxicmdupdates", showUpdates)

    -- COMENZI GRESELI
    sampRegisterChatCommand("gr25", function(arg) handleGresala(arg, 0.25, "teorie", "/gr25") end)
    sampRegisterChatCommand("gr50", function(arg) handleGresala(arg, 0.5, "teorie", "/gr50") end)
    sampRegisterChatCommand("gr75", function(arg) handleGresala(arg, 0.75, "teorie", "/gr75") end)
    sampRegisterChatCommand("gr1", function(arg) handleGresala(arg, 1, "teorie", "/gr1") end)
    sampRegisterChatCommand("grp05", function(arg) handleGresala(arg, 0.5, "practic", "/grp05") end)
    sampRegisterChatCommand("grp1", function(arg) handleGresala(arg, 1, "practic", "/grp1") end)
    
    sampRegisterChatCommand("practic", startPractic)
    sampRegisterChatCommand("admis", function(arg) handleAdmis(arg) end)
    sampRegisterChatCommand("stoptest", function()
        greseli_teorie, greseli_practic = 0, 0
        sampAddChatMessage("{FFFF00}[" .. script_name .. "]{FFFFFF} Scoruri resetate manual.", -1)
    end)

    wait(-1)
end

function showUpdates()
    local updateLog = "{FFFFFF}{FFFF00}Ce este nou?\n\n" ..
                      "{33CC33}[+] {FFFFFF}La /tg 2 intrebarea era prea lunga pentru un rand, acum e pe 2 randuri.\n" ..
                      "{33CC33}[+] {FFFFFF}La /practic au fost adaugate mesajele de la vechiul CMD.\n" ..
                      "{33CC33}[+] {FFFFFF}Modificata functia de AUTO-UPDATE care aparea inainte de logarea pe server.\n" ..
                     -- "{33CC33}[+] {FFFFFF}Adaugat jurnal de actualizari (/taxicmdupdates).\n\n" ..
                      "{A9A9A9}Ultima modificare efectuata pe: " .. last_update
                      
    sampShowDialog(1339, "{FFFF00}Update Log - " .. script_name, updateLog, "Inchide", "", 0)
end

function handleTeorie(arg)
    local index, id = arg:match("(%d+)%s*(%d*)")
    index = tonumber(index)
    
    if index and questions.teorie[index] then
        lua_thread.create(function()
            for _, msg in ipairs(questions.teorie[index]) do
                local finalMsg = msg
                
                if finalMsg:find("@nume") then
                    local targetId = tonumber(id)
                    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    
                    -- 1. Verificam daca ai scris ID-ul
                    if not targetId then
                        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FFFFFF}Utilizare: /teor " .. index .. " <ID Candidat>", -1)
                        return
                    end
                    
                    -- 2. Verificam sa nu fie ID-ul tau
                    if targetId == myId then
                        sampAddChatMessage("{FF0000}[" .. script_name .. "] Eroare: Nu poti sustine testul cu tine insuti!", -1)
                        return
                    end
                    
                    -- 3. Verificam daca este conectat
                    if not sampIsPlayerConnected(targetId) then
                        sampAddChatMessage("{FF0000}[" .. script_name .. "] Eroare: Jucatorul cu ID " .. targetId .. " nu este conectat (offline)!", -1)
                        return
                    end

                    -- 4. Verificam daca este aproape de tine (in raza de stream)
                    local exists, charHandle = sampGetCharHandleBySampPlayerId(targetId)
                    if not exists then
                        sampAddChatMessage("{FF0000}[" .. script_name .. "] Eroare: Candidatul nu este in raza ta (prea departe)!", -1)
                        return
                    end
                    
                    -- Daca a trecut de toate, luam numele
                    local name = sampGetPlayerNickname(targetId):gsub("_", " ")
                    finalMsg = finalMsg:gsub("@nume", name)
                end
                
                sampSendChat("/cw " .. finalMsg)
                wait(1200)
            end
        end)
    else
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FFFFFF}Utilizare: /teor <1-4>", -1)
    end
end
-- FUNCTIE UNIVERSALA DE VALIDARE (V1.5 - PROTECTIE SELF-ID)
function validateTarget(id_arg, cmd_name)
    local id = tonumber(id_arg)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    
    -- 1. Verifica daca a scris ID-ul
    if id == nil then
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FFFFFF}Utilizare corecta: {FFFF00}" .. cmd_name .. " <ID Candidat>", -1)
        return false, nil
    end

    -- 2. Protectie: Nu poti sa dai pe propriul ID
    if id == myId then
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FF0000}Eroare: Nu poti folosi aceasta comanda pe propriul tau ID!", -1)
        return false, nil
    end

    -- 3. Verifica daca e online
    if not sampIsPlayerConnected(id) then
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FF0000}Eroare: Jucatorul cu ID-ul " .. id .. " nu este conectat!", -1)
        return false, nil
    end

    -- 4. Verifica daca e in raza (aproape de tester)
    local exists, charHandle = sampGetCharHandleBySampPlayerId(id)
    if not exists then
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FF0000}Eroare: Candidatul este prea departe de tine!", -1)
        return false, nil
    end

    -- 5. Verifica daca e in aceeasi masina (daca testerul e in masina)
    if isCharInAnyCar(PLAYER_PED) then
        local myCar = storeCarCharIsInNoSave(PLAYER_PED)
        if not isCharInCar(charHandle, myCar) then
            sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FF0000}Eroare: Candidatul nu se afla in masina cu tine!", -1)
            return false, nil
        end
    end

    return true, id
end

function handleGresala(id_arg, puncte, tip, cmd_used)
    local valid, id = validateTarget(id_arg, cmd_used)
    if not valid then return end

    local name = sampGetPlayerNickname(id):gsub("_", " ")
    name = name:match("^%s*(.-)%s*$")
    local motiv = ""

    if tip == "teorie" then
        if puncte == 0.25 then motiv = "pentru raspuns incomplet"
        elseif puncte == 0.5 then motiv = "pentru raspuns partial corect"
        elseif puncte == 0.75 then motiv = "pentru greseli multiple in raspuns"
        elseif puncte == 1 then motiv = "pentru raspuns gresit"
        end
        greseli_teorie = greseli_teorie + puncte
        sampSendChat("/cw @" .. name .. ", ai primit " .. puncte .. " greseli " .. motiv .. "! Greseala teorie: (" .. greseli_teorie .. "/3)")
        if greseli_teorie >= 3 then handleRespingere(name, greseli_teorie, "teoretica") end
    else
        if puncte == 0.5 then motiv = "pentru ocolire drum"
        elseif puncte == 1 then motiv = "pentru locatie necunoscuta"
        end
        greseli_practic = greseli_practic + puncte
        sampSendChat("/cw @" .. name .. ", ai primit " .. puncte .. " greseli " .. motiv .. "! Greseala practica: (" .. greseli_practic .. "/3)")
        if greseli_practic >= 3 then handleRespingere(name, greseli_practic, "practica") end
    end
end

function handleAdmis(id_arg)
    local valid, id = validateTarget(id_arg, "/admis")
    if not valid then return end

    local name = sampGetPlayerNickname(id):gsub("_", " ")
    name = name:match("^%s*(.-)%s*$")
    
    lua_thread.create(function()
        sampSendChat("/cw Felicitari, @" .. name .. "! Ai trecut testul de intrare in factiune.")
        wait(1200)
        sampSendChat("/cw Proba teoretica: (" .. greseli_teorie .. "/3) | Proba practica: (" .. greseli_practic .. "/3).")
        wait(1200)
        sampSendChat("/cw Succes!")
        wait(1200)
        sampSendChat("/f @" .. name .. ", a trecut testul de intrare in factiune!")
        greseli_teorie, greseli_practic = 0, 0
    end)
end

function runTogAll()
    lua_thread.create(function()
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FFFFFF}Se executa curatarea chat-ului...", -1)
        local cmds = {"/turn off", "/toge", "/setfreq 0", "/tognews", "/togreports", "/togarrests", "/togc", "/togf", "/toglegend", "/togn", "/togvip"}
        for _, v in ipairs(cmds) do sampSendChat(v) wait(400) end
        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {33CC33}Chat-ul a fost configurat!", -1)
    end)
end

function handleRespingere(name, scor, proba)
    lua_thread.create(function()
        wait(1500)
        sampSendChat("/cw @" .. name .. ", ai fost respins deoarece ai acumulat (" .. scor .. "/3) greseli la proba " .. proba .. ".")
        wait(1200)
        sampSendChat("/f Candidatul @" .. name .. " a fost respins la proba " .. proba .. " (" .. scor .. "/3).")
        greseli_teorie, greseli_practic = 0, 0
    end)
end

function sendTest(type, idx_arg)
    local idx = tonumber(idx_arg)
    if idx and questions[type][idx] then
        -- Creăm un thread ca să putem folosi wait() fără crash
        lua_thread.create(function()
            -- 1. Trimitem INTREBAREA (suportă \n)
            local full_q = questions[type][idx].q
            if full_q:find("\n") then
                for q_line in full_q:gmatch("[^\n]+") do
                    sampSendChat("/cw " .. q_line)
                    wait(1100) -- Pauză între rânduri să nu ia spam
                end
            else
                sampSendChat("/cw " .. full_q)
            end
            
            -- 2. Afișăm RASPUNSUL (local, pentru tine, suportă \n)
            local full_resp = questions[type][idx].r
            for r_line in full_resp:gmatch("[^\n]+") do
                sampAddChatMessage("{33CC33}[RASPUNS] {FFFFFF}" .. r_line, -1)
            end
        end)
    else
        sampAddChatMessage("{FF0000}[" .. script_name .. "] Utilizare: /" .. type .. " <numar>", -1)
    end
end

function startPractic()
    lua_thread.create(function()
        greseli_practic = 0
        for _, msg in ipairs(questions.practic) do sampSendChat("/cw " .. msg) wait(1200) end
    end)
end

--function showCommands()
  --  sampAddChatMessage("{FFFF00}--- COMENZI ---", -1)
    --sampAddChatMessage("{FFFFFF}Foloseste /taxicmd pentru a vedea comenzile si ce fac acestea.", -1)
--end

function showHelp()
    sampShowDialog(1338, "Tutorial Taxi TestCMD creat de {FFFF00}Eqi(N)oux.", "{FFFFFF}/gr25/50/75/1 <id> - acorda 0.25, 0.5, 0.75 sau 1 greseli la teorie - la 3/3 sau mai mult de 3 greseli anunta automat pe /cw candidatul si pe /f ca este picat.\n/grp05/1 <id> - acorda 0.5 sau 1 greseli la practic - la 3/3 sau mai mult de 3 greseli anunta automat pe /cw candidatul si pe /f ca este picat.\n/admis <id> - anunta pe /f si /cw ca a fost admis candidatul\n/togall - opreste chat-uriile: helper, freq 0, news, reports, arrests, c, f, legend, newbie, vip si acorda /turn off\n/stoptest - se foloseste in cazul in care isi da crash, da /q sau nu mai vrea sa dea testul pentru a reseta greselile, daca aveti alt candidat la test fara a da /q.\n/teor (1-4) - este inceputul testului, unde salutati candidatul si oferiti informatiile {FF1D00}(ATENTIE: /teor 1 <id>, de la /teor 2 pana la 4 nu mai trebuie ID-ul)\n{FFFFFF}/ts 1-20, /tm 1-22 si /tg 1-24 - sunt intrebarile la test (simplu, mediu, greu)\n/taxicmdupdates - afiseaza ultimul update\n{cc11ff}AUTO-UPDATE: Modul este creat cu functia de Auto Update, cand apare ceva nou veti primi in joc direct update-ul. Update-ul se realizeaza prin Github. In joc doar confirmati prin butonul 'Update' iar el in secunda aceea s-a si actualizat.\n\n{690C00}\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tVersiune mod: v" .. script_version .. " (ultima actualizare: " .. last_update .. ")", "OK", "", 0)
end

function checkUpdate()
    lua_thread.create(function()
        local ok, response = pcall(requests.get, update_url)
        if ok and response.status_code == 200 then
            local json = response.json()
            if json and json.version > script_version then
                -- Afisam dialogul
                sampShowDialog(1337, "{FFFF00}Update Disponibil", "{FFFFFF}O noua versiune a modului {FFFF00}" .. script_name .. " {FFFFFF}este disponibila!\n\n{FFFFFF}Versiune curenta: {FF0000}" .. script_version .. "\n{FFFFFF}Versiune noua: {33CC33}" .. json.version .. "\n\n{FFFFFF}Doresti sa efectuezi update-ul acum?", "Da", "Nu", 0)
                
                -- Asteptam raspunsul la dialog
                local result, button, list, input = 0, -1, -1, ""
                while result == 0 do
                    wait(0)
                    result, button, list, input = sampHasDialogRespond(1337)
                    if result == 1 and button == 1 then
                        sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FFFFFF}Se descarca actualizarea, te rugam asteapta...", -1)
                        local dl = requests.get(download_url)
                        if dl.status_code == 200 then
                            local f = io.open(thisScript().path, "wb")
                            f:write(dl.text) 
                            f:close()
                            sampAddChatMessage("{FFFF00}[" .. script_name .. "] {33CC33}Update finalizat cu succes! Modul se restarteaza...", -1)
                            wait(1000)
                            thisScript():reload()
                        else
                            sampAddChatMessage("{FFFF00}[" .. script_name .. "] {FF0000}Eroare la descarcare!", -1)
                        end
                    end
                end
            end
        end
    end)
end