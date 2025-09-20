BanditCreator = BanditCreator or {}

function BanditCreator.MakeFromRoom(room)

    local building = room:getBuilding()
    local buildingDef = building:getDef()
    local keyId = buildingDef:getKeyId()

    local roomData = BWORooms.Get(room)
    if not roomData then return end

    local bandit = {}
    
    -- this always generates bandits of clan 0 - citizens
    local clan = BanditCreator.GroupMap[0]

    -- properties to be rewritten from clan file to bandit instance
    bandit.clan = clan.id
    bandit.health = clan.health
    bandit.eatBody = clan.eatBody
    bandit.accuracyBoost = clan.accuracyBoost

    -- default weapon config
    config = {}
    config.hasRifleChance = 0
    config.hasPistolChance = SandboxVars.BanditsWeekOne.InhabitantsPistolChance
    config.rifleMagCount = 0
    config.pistolMagCount = 3
    config.clanId = 0

    if BWOScheduler.SymptomLevel >= 3 then
        config.hasRifleChance = 5
        config.hasPistolChance = 40
        config.rifleMagCount = 2
        config.pistolMagCount = 3
    end

    bandit.femaleChance = clan.femaleChance
    if roomData.femaleChance then
        bandit.femaleChance = roomData.femaleChance
    end

    bandit.outfit = BanditUtils.Choice(clan.Outfits)
    if roomData.outfits then
        bandit.outfit = BanditUtils.Choice(roomData.outfits)

        if bandit.outfit == "MallSecurity" or bandit.outfit == "Security" then
            config.hasPistolChance = 100
            config.pistolMagCount = 2
            bandit.femaleChance = 0
        elseif bandit.outfit == "OfficeWorkerSkirt" then
            bandit.femaleChance = 100
        end
    end

    if roomData.hasPistolChance and roomData.pistolMagCount then
        config.hasPistolChance = roomData.hasPistolChance
        config.pistolMagCount = roomData.pistolMagCount
    end
    if roomData.hasRifleChance and roomData.rifleMagCount then
        config.hasRifleChance = roomData.hasRifleChance
        config.rifleMagCount = roomData.rifleMagCount
    end
    bandit.weapons = BanditCreator.MakeWeapons(config, clan)

    bandit.weapons.melee = "Base.BareHands" -- BanditUtils.Choice(clan.Melee)
    if roomData.melee then
        bandit.weapons.melee = BanditUtils.Choice(roomData.melee)
    end

    if clan.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(clan.hairStyles)
    end

    if roomData.hairStyles then
        bandit.hairStyle = BanditUtils.Choice(roomData.hairStyles)
    end

    bandit.loot = BanditCreator.MakeLoot(clan.Loot)

    if not roomData.isShop and not roomData.isRestaurant then
        bandit.key = keyId
    end

    return bandit
end
