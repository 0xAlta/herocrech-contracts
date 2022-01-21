// SPDX-License-Identifier: MIT

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

interface IQuestTypes {
    struct QuestType {
        uint256 id;
        address quest;
        uint8 status;
        uint8 minHeroes;
        uint8 maxHeroes;
        uint16 requiredStamina;
        uint256 level;
        uint8 maxAttempts;
    }

    struct Quest {
        uint256 id;
        address quest;
        uint256[] heroes;
        address player;
        uint256 startTime;
        uint256 startBlock;
        uint256 completeAtTime;
        uint8 attempts;
        uint8 status;
    }

    struct RewardItem {
        address item;
        int64 expBonus;
        int64 skillUpChance;
        int64 smallSkillUpMod;
        int64 mediumSkillUpMod;
        int64 largeSkillUpMod;
        int64 baseChance;
        int64 skillMod;
        int64 statMod;
        int64 luckMod;
    }
}

interface ICrystalTypes {
    struct HeroCrystal {
        address owner;
        uint256 summonerId;
        uint256 assistantId;
        uint16 generation;
        uint256 createdBlock;
        uint256 heroId;
        uint8 summonerTears;
        uint8 assistantTears;
        address bonusItem;
        uint32 maxSummons;
        uint32 firstName;
        uint32 lastName;
        uint8 shinyStyle;
    }
}

interface IHeroTypes {
    struct Hero {
        uint256 id;
        SummoningInfo summoningInfo;
        HeroInfo info;
        HeroState state;
        HeroStats stats;
        HeroStatGrowth primaryStatGrowth;
        HeroStatGrowth secondaryStatGrowth;
        HeroProfessions professions;
    }

    struct SummoningInfo {
        uint256 summonedTime;
        uint256 nextSummonTime;
        uint256 summonerId;
        uint256 assistantId;
        uint32 summons;
        uint32 maxSummons;
    }

    struct HeroInfo {
        uint256 statGenes;
        uint256 visualGenes;
        uint8 rarity;
        bool shiny;
        uint16 generation;
        uint32 firstName;
        uint32 lastName;
        uint8 shinyStyle;
        uint8 class;
        uint8 subClass;
    }

    struct HeroState {
        uint256 staminaFullAt;
        uint256 hpFullAt;
        uint256 mpFullAt;
        uint16 level;
        uint64 xp;
        address currentQuest;
        uint8 sp;
        uint8 status;
    }

    struct HeroStats {
        uint16 strength;
        uint16 intelligence;
        uint16 wisdom;
        uint16 luck;
        uint16 agility;
        uint16 vitality;
        uint16 endurance;
        uint16 dexterity;
        uint16 hp;
        uint16 mp;
        uint16 stamina;
    }

    struct HeroStatGrowth {
        uint16 strength;
        uint16 intelligence;
        uint16 wisdom;
        uint16 luck;
        uint16 agility;
        uint16 vitality;
        uint16 endurance;
        uint16 dexterity;
        uint16 hpSm;
        uint16 hpRg;
        uint16 hpLg;
        uint16 mpSm;
        uint16 mpRg;
        uint16 mpLg;
    }

    struct HeroProfessions {
        uint16 mining;
        uint16 gardening;
        uint16 foraging;
        uint16 fishing;
    }
}
