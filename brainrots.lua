local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotGenerations = {
    ["Noobini Pizzanini"] = 1,
    ["Lirilì Larilà"] = 3,
    ["Tim Cheese"] = 5,
    ["Fluriflura"] = 7,
    ["Svinina Bombardino"] = 10,
    ["Talpa Di Fero"] = 9,
    ["Pipi Kiwi"] = 13,
    ["Pipi Corni"] = 14,
    ["Raccooni Jandelini"] = 12,
    ["Tartaragno"] = 13,
    ["Trippi Troppi"] = 15,
    ["Gangster Footera"] = 30,
    ["Boneca Ambalabu"] = 40,
    ["Ta Ta Ta Ta Sahur"] = 55,
    ["Tric Trac Baraboom"] = 65,
    ["Bandito Bobritto"] = 35,
    ["Cacto Hipopotamo"] = 50,
    ["Pipi Avocado"] = 70,
    ["Pinealotto Fruttarino"] = 75,
    ["Cappuccino Assassino"] = 75,
    ["Brr Brr Patapim"] = 100,
    ["Trulimero Trulicina"] = 125,
    ["Bananita Dolphinita"] = 150,
    ["Brri Brri Bicus Dicus Bombicus"] = 175,
    ["Bambini Crostini"] = 135,
    ["Perochello Lemonchello"] = 160,
    ["Avocadini Guffo"] = 225,
    ["Salamino Penguino"] = 250,
    ["Ti Ti Ti Sahur"] = 225,
    ["Penguino Cocosino"] = 300,
    ["Avocadini Antilopini"] = 115,
    ["Bandito Axolito"] = 90,
    ["Malame Amarele"] = 140,
    ["Mangolini Parrocini"] = 235,
    ["Mummio Rappitto"] = 325,
    ["Burbaloni Loliloli"] = 200,
    ["Chimpanzini Bananini"] = 300,
    ["Ballerina Cappuccina"] = 500,
    ["Chef Crabracadabra"] = 600,
    ["Glorbo Fruttodrillo"] = 750,
    ["Blueberrinni Octopusini"] = 1000,
    ["Lionel Cactuseli"] = 650,
    ["Pandaccini Bananini"] = 1250,
    ["Strawberrelli Flamingelli"] = 1150,
    ["Cocosini Mama"] = 1200,
    ["Pi Pi Watermelon"] = 1300,
    ["Sigma Boy"] = 1350,
    ["Pipi Potato"] = 1100,
    ["Quivioli Ameleonni"] = 900,
    ["Tirilikalika Tirilikalako"] = 450,
    ["Caramello Filtrello"] = 1050,
    ["Signore Carapace"] = 1325,
    ["Sigma Girl"] = 1800,
    ["Quackula"] = 1275,
    ["Buho de Fuego"] = 1850,
    ["Frigo Camelo"] = 1900,
    ["Orangutini Ananassini"] = 2000,
    ["Bombardiro Crocodilo"] = 2500,
    ["Bombombini Gusini"] = 5000,
    ["Rhino Toasterino"] = 2150,
    ["Cavallo Virtuoso"] = 7500,
    ["Spioniro Golubiro"] = 3500,
    ["Zibra Zubra Zibralini"] = 6000,
    ["Tigrilini Watermelini"] = 6500,
    ["Gorillo Watermelondrillo"] = 8000,
    ["Avocadorilla"] = 7000,
    ["Ganganzelli Trulala"] = 9000,
    ["Tob Tobi Tobi"] = 8500,
    ["Te Te Te Sahur"] = 9500,
    ["Tracoducotulu Delapeladustuz"] = 12000,
    ["Lerulerulerule"] = 8750,
    ["Carloo"] = 13500,
    ["Carrotini Brainini"] = 15000,
    ["Brutto Gialutto"] = 3000,
    ["Gorillo Subwoofero"] = 7750,
    ["Los Noobinis"] = 12500,
    ["Rhino Helicopterino"] = 11000,
    ["Elefanto Frigo"] = 14000,
    ["Toiletto Focaccino"] = 16000,
    ["Cachorrito Melonito"] = 13000,
    ["Bananito Bandito"] = 16500,
    ["Magi Ribbitini"] = 11500,
    ["Jacko Spaventosa"] = 16250,
    ["Chihuanini Taconini"] = 45000,
    ["Cocofanto Elefanto"] = 17500,
    ["Tralalero Tralala"] = 50000,
    ["Odin Din Din Dun"] = 75000,
    ["Girafa Celestre"] = 20000,
    ["Trenostruzzo Turbo 3000"] = 150000,
    ["Matteo"] = 50000,
    ["Tigroligre Frutonni"] = 60000,
    ["Orcalero Orcala"] = 100000,
    ["Unclito Samito"] = 75000,
    ["Gattatino Nyanino"] = 35000,
    ["Espresso Signora"] = 70000,
    ["Ballerino Lololo"] = 200000,
    ["Piccione Macchina"] = 225000,
    ["Los Crocodillitos"] = 55000,
    ["Tukanno Bananno"] = 100000,
    ["Trippi Troppi Troppa Trippa"] = 175000,
    ["Los Tungtungtungcitos"] = 210000,
    ["Agarrini la Palini"] = 425000,
    ["Bulbito Bandito Traktorito"] = 205000,
    ["Los Orcalitos"] = 235000,
    ["Tipi Topi Taco"] = 75000,
    ["Bombardini Tortinii"] = 225000,
    ["Tralalita Tralala"] = 100000,
    ["Urubini Flamenguini"] = 150000,
    ["Alessio"] = 85000,
    ["Pakrahmatmamat"] = 215000,
    ["Los Bombinitos"] = 220000,
    ["Brr es Teh Patipum"] = 225000,
    ["Tartaruga Cisterna"] = 250000,
    ["Cacasito Satalito"] = 240000,
    ["Mastodontico Telepiedone"] = 275000,
    ["Crabbo Limonetta"] = 235000,
    ["Gattito Tacoto"] = 165000,
    ["Los Tipi Tacos"] = 260000,
    ["Antonio"] = 18500,
    ["Las Capuchinas"] = 185000,
    ["Orcalita Orcala"] = 240000,
    ["Piccionetta Macchina"] = 270000,
    ["Anpali Babel"] = 280000,
    ["Extinct Ballerina"] = 125000,
    ["Tractoro Dinosauro"] = 230000,
    ["Belula Beluga"] = 290000,
    ["Capi Taco"] = 155000,
    ["Dug dug dug"] = 255000,
    ["Corn Corn Corn Sahur"] = 250000,
    ["Brasilini Berimbini"] = 285000,
    ["Squalanana"] = 250000,
    ["Pop Pop Sahur"] = 295000,
    ["Vampira Cappucina"] = 125000,
    ["Jacko Jack Jack"] = 150000,
    ["Snailenzo"] = 250000,
    ["Tentacolo Tecnico"] = 292500,
    ["La Vacca Saturno Saturnita"] = 300000,
    ["Los Tralaleritos"] = 500000,
    ["Graipuss Medussi"] = 1000000,
    ["La Grande Combinasion"] = 10000000,
    ["Sammyni Spyderini"] = 325000,
    ["Garama and Madundung"] = 50000000,
    ["Torrtuginni Dragonfrutini"] = 350000,
    ["Las Tralaleritas"] = 650000,
    ["Pot Hotspot"] = 2500000,
    ["Nuclearo Dinossauro"] = 15000000,
    ["Las Vaquitas Saturnitas"] = 750000,
    ["Chicleteira Bicicleteira"] = 3500000,
    ["Los Combinasionas"] = 15000000,
    ["Karkerkar Kurkur"] = 300000,
    ["Dragon Cannelloni"] = 200000000,
    ["Los Hotspotsitos"] = 20000000,
    ["Esok Sekolah"] = 30000000,
    ["Nooo My Hotspot"] = 1500000,
    ["Los Matteos"] = 300000,
    ["Job Job Job Sahur"] = 700000,
    ["Dul Dul Dul"] = 375000,
    ["Blackhole Goat"] = 400000,
    ["Los Spyderinis"] = 425000,
    ["Ketupat Kepat"] = 35000000,
    ["La Supreme Combinasion"] = 40000000,
    ["Bisonte Giuppitere"] = 300000,
    ["Guerriro Digitale"] = 550000,
    ["Ketchuru and Musturu"] = 42500000,
    ["Spaghetti Tualetti"] = 60000000,
    ["Los Nooo My Hotspotsitos"] = 5500000,
    ["Trenostruzzo Turbo 4000"] = 310000,
    ["Fragola La La La"] = 450000,
    ["La Sahur Combinasion"] = 2000000,
    ["La Karkerkar Combinasion"] = 600000,
    ["Tralaledon"] = 27500000,
    ["Los Bros"] = 24000000,
    ["Los Chicleteiras"] = 7000000,
    ["Chachechi"] = 400000,
    ["Extinct Tralalero"] = 450000,
    ["Extinct Matteo"] = 625000,
    ["67"] = 7500000,
    ["Las Sis"] = 17500000,
    ["Celularcini Viciosini"] = 22500000,
    ["La Extinct Grande"] = 23500000,
    ["Quesadilla Crocodila"] = 3000000,
    ["Tacorita Bicicleta"] = 16500000,
    ["La Cucaracha"] = 475000,
    ["To to to Sahur"] = 2250000,
    ["Mariachi Corazoni"] = 12500000,
    ["Los Tacoritas"] = 32000000,
    ["Tictac Sahur"] = 37500000,
    ["Yess my examine"] = 575000,
    ["Karker Sahur"] = 725000,
    ["Noo my examine"] = 1750000,
    ["Money Money Puggy"] = 21000000,
    ["Los Primos"] = 31000000,
    ["Tang Tang Keletang"] = 33500000,
    ["Perrito Burrito"] = 1000000,
    ["Chillin Chili"] = 25000000,
    ["Los Tortus"] = 500000,
    ["Los Karkeritos"] = 750000,
    ["Los Jobcitos"] = 1500000,
    ["Los 67"] = 22500000,
    ["La Secret Combinasion"] = 125000000,
    ["Burguro And Fryuro"] = 150000000,
    ["Zombie Tralala"] = 500000,
    ["Vulturino Skeletono"] = 500000,
    ["Frankentteo"] = 700000,
    ["La Vacca Jacko Linterino"] = 850000,
    ["Chicleteirina Bicicleteirina"] = 4000000,
    ["Eviledon"] = 31500000,
    ["La Spooky Grande"] = 24500000,
    ["Los Mobilis"] = 22000000,
    ["Spooky and Pumpky"] = 80000000,
    ["Strawberry Elephant"] = 350000000,
}

local Synchronizer = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))

local notifiedPets = {}

local function sendWebhook(player, petName, generation, mutation)
    local playerCount = #Players:GetPlayers()
    local jobId = game.JobId
    local placeId = game.PlaceId

    local mutationText = mutation and (" **[" .. mutation .. "]**") or ""
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🔥 HIGH GENERATION PET FOUND!",
            ["color"] = 15158332,
            ["fields"] = {
                {
                    ["name"] = "👤 Player",
                    ["value"] = "**" .. player.Name .. "**\n`UserID: " .. player.UserId .. "`",
                    ["inline"] = true
                },
                {
                    ["name"] = "🐾 Pet",
                    ["value"] = "**" .. petName .. "**" .. mutationText,
                    ["inline"] = true
                },
                {
                    ["name"] = "⚡ Generation",
                    ["value"] = "```fix\n" .. tostring(generation) .. "\n```",
                    ["inline"] = false
                },
                {
                    ["name"] = "🌐 Server",
                    ["value"] = "**" .. playerCount .. "/8** players",
                    ["inline"] = true
                },
                {
                    ["name"] = "🆔 Job ID",
                    ["value"] = "```" .. jobId .. "```",
                    ["inline"] = false
                },
                {
                    ["name"] = "📜 Join Script",
                    ["value"] = "```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(" .. placeId .. ", '" .. jobId .. "', game.Players.LocalPlayer)\n```",
                    ["inline"] = false
                }
            },
            ["timestamp"] = DateTime.now():ToIsoDate(),
            ["footer"] = {
                ["text"] = "Brainrot Scanner • Min Gen: " .. MIN_GENERATION
            }
        }}
    }

    task.spawn(function()
        local success, err = pcall(function()
            local response = request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
            
            if response.StatusCode == 204 or response.StatusCode == 200 then
                print("[✓] Webhook sent:", petName, "Gen:", generation)
            else
                warn("[✗] Webhook failed with status:", response.StatusCode)
            end
        end)
        
        if not success then
            warn("[✗] Webhook error:", err)
        end
    end)
end

local function checkPet(pet, owner)
    if type(pet) ~= "table" or not pet.Index or pet.Index == "Empty" then
        return
    end

    local generation = BrainrotGenerations[pet.Index]
    
    if not generation then
        return
    end

    local uniqueKey = owner.UserId .. "-" .. (pet.UUID or pet.Index)
    
    if generation >= MIN_GENERATION and not notifiedPets[uniqueKey] then
        notifiedPets[uniqueKey] = true
        print(string.format("[FOUND] %s (Gen: %d) | Owner: %s | Mutation: %s", 
            pet.Index, generation, owner.Name, pet.Mutation or "None"))
        sendWebhook(owner, pet.Index, generation, pet.Mutation)
    end
end

local function scanAllChannels()
    local allChannels = Synchronizer:GetAllChannels()
    local scannedCount = 0
    local foundCount = 0
    
    for channelId, channelData in pairs(allChannels) do
        if channelData.CacheTable and channelData.CacheTable.AnimalList and channelData.CacheTable.Owner then
            scannedCount = scannedCount + 1
            local owner = channelData.CacheTable.Owner
            local animalList = channelData.CacheTable.AnimalList

            for _, pet in ipairs(animalList) do
                if type(pet) == "table" and pet.Index then
                    local generation = BrainrotGenerations[pet.Index]
                    if generation and generation >= MIN_GENERATION then
                        foundCount = foundCount + 1
                        checkPet(pet, owner)
                    end
                end
            end
        end
    end
    
    return scannedCount, foundCount
end

task.wait(2)

while task.wait(15) do
    local success, err = pcall(function()
        local scanned, found = scanAllChannels()
        print(string.format("[SCAN] Checked %d players | Found %d high-gen pets", scanned, found))
    end)
    
    if not success then
        warn("[ERROR] Scan failed:", err)
    end
end
