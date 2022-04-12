#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define NMRIH_MAX_PLAYERS 8

#define LADDER_PREFIX "\x075CD1E5[래더]\x01"

#define LADDER_BRONZE "브론즈"
#define LADDER_SILVER "실버"
#define LADDER_GOLD "골드"
#define LADDER_PLATINUM "플레티넘"
#define LADDER_DIAMOND "다이아"
#define LADDER_MASTER "마스터"
#define LADDER_GRANDMASTER "그랜드마스터"

#define TIER_SIZE 32

#define ZOMBIE_KILL_POINT 2
#define ESCAPE_POINT 80

#define DEATH_BRONZE_POINT  60
#define DEATH_SILVER_POINT 90
#define DEATH_GOLD_POINT 150
#define DEATH_PLATINUM_POINT 210
#define DEATH_DIAMOND_POINT 270 
#define DEATH_MASTER_POINT 330
#define DEATH_GRANDMASTER_POINT 400

#define RAISE_SILVER_POINT 1000
#define RAISE_GOLD_POINT 2500
#define RAISE_PLATINUM_POINT 4500
#define RAISE_DIAMOND_POINT 7000 
#define RAISE_MASTER_POINT 10500
#define RAISE_GRANDMASTER_POINT 15000

#define DISCONNECT_INFECTION_POINT 30
#define DISCONNECT_BLEEDING_POINT 30

#define MISSION_LIST 5 // 미션 갯수

#define MISSION_NO_DEATH 1
#define MISSION_NO_DEATH_CLEAR_POINT 140 // 안죽고 클리어 할시 추가 보너스 
#define MISSION_NO_DEATH_MINUS_POINT 120 // 죽은 횟수당 차감할 보너스 점수

#define MISSION_NO_HURT 2
#define MISSION_NO_HURT_CLEAR_POINT 160 // 피격 안입고 클리어 할시 추가 보너스 
#define MISSION_NO_HURT_MINUS_POINT 20 // 피격당 차감할 보너스 점수

#define MISSION_ZOMBIE_KILL 3
#define MISSION_ZOMBIE_KILL_GOAL 150 // 잡아야 할 좀비 킬 추가 보너스
#define MISSION_ZOMBIE_KILL_CLEAR_POINT 90 // 달성시 주는 점수

#define MISSION_NO_PILLS 4
#define MISSION_NO_PILLS_CLEAR_POINT 120 // 약 안먹고 클리어 할시 추가 보너스
#define MISSION_NO_PILLS_MINUS_POINT 100 // 약 먹으면 차감할 보너스

#define MISSION_NO_SHOVED 5 
#define MISSION_NO_SHOVED_CLEAR_POINT 140 // 좀비 안 밀치고 클리어 할시 추가 보너스
#define MISSION_NO_SHOVED_MINUS_POINT 5 // 좀비 밀칠시 차감할 보너스
 
#define COLOR_BRONZE "CD7F32"
#define COLOR_SILVER "C0C0C0"
#define COLOR_GOLD "FFD700"
#define COLOR_PLATINUM "6B6B6B"
#define COLOR_DIAMOND "A3A0ED" 
#define COLOR_MASTER "BFFFB7"
#define COLOR_GRANDMASTER "FF9090"

new Handle:database_ladder = INVALID_HANDLE;
new ladderDBPlayersTotal;

new playerLadderScore[NMRIH_MAX_PLAYERS+1];
new playerRanking[NMRIH_MAX_PLAYERS+1];

new bool:isPlayerTierImageCheck[NMRIH_MAX_PLAYERS+1] = { false, false, ... };
new String:playerTier[NMRIH_MAX_PLAYERS+1][TIER_SIZE];
new playerTierImage[NMRIH_MAX_PLAYERS+1];

new bool:playerMissonApply[NMRIH_MAX_PLAYERS+1];
new playerMissionSelection;
new playerZombieKill[NMRIH_MAX_PLAYERS+1]; 
new playerDeathCount[NMRIH_MAX_PLAYERS+1];
new playerHurtCount[NMRIH_MAX_PLAYERS+1];
new playerPillsTakenCount[NMRIH_MAX_PLAYERS+1];
new playerShovedCount[NMRIH_MAX_PLAYERS+1];

new topLadderPlayerScore[10] = { -1, -1, ...};
new String:topLadderPlayerName[10][MAX_NAME_LENGTH];

new bool:playerSafety;


public Plugin:myinfo = {
	name = "LadderSystem",
	author = "사마나",
	description = "서버 경쟁 시스템.",
	version = "0.54",
	url = "https://app.box.com/s/fn7p1knhkawpay6pums7o0wn5o0rhwl0"
};

public OnPluginStart() {
	LadderSystemDownloadFiles();
	ConnectLadderDatabase();
	RegConsoleCmd("sm_ld", CommandLadderSystem, "래더 메뉴를 엽니다.");
	
	AutoExecConfig(true, "ladder_system");
	
	HookEvent("zombie_shoved", Event_ZombieShoved);
	HookEvent("pills_taken", Event_PillsTaken);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("nmrih_round_begin", Event_RoundBegin);	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("npc_killed", Event_NpcKilled);
	HookEvent("player_extracted", Event_PlayerExtracted);
	HookEvent("zombie_killed_by_fire", Event_ZombieKilledByFire);
}

public OnMapStart() {
	SQL_TQuery(database_ladder, LoadPlayersTotalQuery, "SELECT COUNT(*) FROM ladder_system;");
	SQL_TQuery(database_ladder, LoadPlayerLadderTopQuery, "SELECT player_name, ladder_score FROM ladder_system ORDER BY ladder_score DESC LIMIT 10;");
	playerSafety = true;
}

public LoadPlayersTotalQuery(Handle:owner, Handle:hndl, const String:error[], any:client) {
	if(hndl != INVALID_HANDLE && SQL_FetchRow(hndl))
	{
		ladderDBPlayersTotal = SQL_FetchInt(hndl, 0);
	}
}

public LoadPlayerLadderTopQuery(Handle:owner, Handle:hndl, const String:error[], any:client) {
	if(hndl == INVALID_HANDLE)
		return;
	
	new i = 0;

	while(SQL_FetchRow(hndl)) {
		SQL_FetchString(hndl, 0, topLadderPlayerName[i], 32);
		topLadderPlayerScore[i] = SQL_FetchInt(hndl, 1);
		i++;
	}	
}

public OnClientAuthorized(client, const String:auth[]) {
	if(IsFakeClient(client))
		return;
	
	new String:query1[512];
	Format(query1, sizeof(query1), "SELECT player_name, ladder_score FROM ladder_system WHERE steam_id = '%s' LIMIT 1;", auth);
	SQL_TQuery(database_ladder, LoadPlayerDataQuery, query1, client);
}

public LoadPlayerDataQuery(Handle:owner, Handle:hndl, const String:error[], any:client) {
	if(IsFakeClient(client)) 
		return;
	
	if(hndl != INVALID_HANDLE) {
		
		if(SQL_FetchRow(hndl)) {
			playerLadderScore[client] = SQL_FetchInt(hndl, 1);
			
		} else {
			new String:query[512], String:playerSteamAdress[32];
			
			GetClientAuthString(client, playerSteamAdress, sizeof(playerSteamAdress));
			Format(query, sizeof(query), "INSERT INTO ladder_system VALUES ('%s', '%N', '%s', %d);", playerSteamAdress, client, LADDER_BRONZE, 0);
			Format(playerTier[client], TIER_SIZE, LADDER_BRONZE);
			SQL_Query(database_ladder, "SET NAMES UTF8;");
			SQL_Query(database_ladder, query);
			
			playerLadderScore[client] = 0;
		}
	} else {
		PrintToServer("[ladder]Player %N Error - Can Not Load Data", client);
	}
}

public OnClientPutInServer(client) {	
	new String:query[512];
	ClientCommand(client, "bind F2 sm_ld");
	playerZombieKill[client] = 0; 
	playerDeathCount[client] = 0;
	playerShovedCount[client] = 0;
	playerHurtCount[client] = 0;
	playerPillsTakenCount[client] = 0;
	playerMissonApply[client] = false;

	Format(query, sizeof(query), "SELECT ladder_score FROM ladder_system WHERE ladder_score > %d ORDER BY ladder_score ASC;", playerLadderScore[client]);
	SQL_TQuery(database_ladder, LoadPlayerRankingQuery, query, client);	
	CreateTimer(2.0, ClientPutInServerMessage, client);
}

public Action:ClientPutInServerMessage(Handle:timer, any:client) {
	new String:tierColor[16];
	
	GetLadderTier(client, playerTier[client]);
	GetLadderTierColor(client, tierColor, sizeof(tierColor));
	PrintToChatAll("\x01-------------------%s-------------------", LADDER_PREFIX);
	PrintToChatAll("\x01플레이어 : %N | 점수 : %d", client, playerLadderScore[client]);
	PrintToChatAll("\x01티어 : \x07%s%s   \x01순위 : %d   데이터 로드 완료", tierColor, playerTier[client], playerRanking[client]);
	PrintToChatAll("\x01--------------------------------------------");
	
	
	if(!IsPlayerAlive(client))
		DeleteTierImage(client);
	
}


public LoadPlayerRankingQuery(Handle:owner, Handle:hndl, const String:error[], any:client) {
	if(hndl == INVALID_HANDLE || !IsClientInGame(client))
		return;
	
	if(SQL_FetchRow(hndl))
		playerRanking[client] = SQL_GetRowCount(hndl) + 1;
}

public OnClientDisconnect(client) {
	if(!playerSafety) 
		DisconnectLadderMinusScore(client);
	
	LadderSystemDataSavePlayer(client);
	DeleteTierImage(client);
}

public Action:CommandLadderSystem(client, args) {
	CreateLadderMenu(client);
	return Plugin_Handled;
}

public CreateLadderMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderMenuHandler);
	
	SetMenuTitle(menu, "[래더스코어 = %d][%d명중 %d위][다음 티어까지 %d점]", playerLadderScore[client], ladderDBPlayersTotal, playerRanking[client], (GetPlayerLadderRaiseScore(client)-playerLadderScore[client]));
	AddMenuItem(menu, "TOP_LADDER", "래더 순위 Top 10");
	AddMenuItem(menu, "TIER_CHART", "각 구간 티어 점수 표");
	AddMenuItem(menu, "PLAYER_LADDER_SCORE", "접속해 있는 유저 점수 확인");
	AddMenuItem(menu, "LADDER_INFO", "래더에 관한 정보");
	AddMenuItem(menu, "DISCONNECT_POINT", "탈주 패널티 정보");
	AddMenuItem(menu, "PlUS_POINT", "추가 보너스 미션에 대한 정보");
	AddMenuItem(menu, "MY_INFO", "이번판 플레이의 전적 정보");
	AddMenuItem(menu, "DEVELOP_CREDIT", "개발자 크레딧");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public CreateLadderTopScoreMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderTopScoreMenuHandler);
	new String:topLadderInfo[256];
	SetMenuTitle(menu, "1위에서 10위까지 보여줍니다. / 내 순위[%d]", playerRanking[client]);
	
	for(new i=0; i<10; i++) {
		if(topLadderPlayerScore[i] == -1)
			break;
		
		Format(topLadderInfo, sizeof(topLadderInfo), "[%d위][플레이어:%s][래더스코어:%d]", i+1, topLadderPlayerName[i], topLadderPlayerScore[i]);
		AddMenuItem(menu, "", topLadderInfo, ITEMDRAW_DISABLED);
	}
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);  
}

public CreateLadderTierChartMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderTierChartHandler);
	new String:bronzePoint[64], String:silverPoint[64], String:goldPoint[64], String:platinum[64], String:diamond[64], String:master[64], String:grandmaster[64];
	
	Format(bronzePoint, sizeof(bronzePoint), "브론즈[0점 이상]/까이는 점수[%d]", DEATH_BRONZE_POINT);
	Format(silverPoint, sizeof(silverPoint), "실버[%d점 이상]/까이는 점수[%d]", RAISE_SILVER_POINT, DEATH_SILVER_POINT); 
	Format(goldPoint, sizeof(goldPoint), "골드[%d점 이상]/까이는 점수[%d]", RAISE_GOLD_POINT, DEATH_GOLD_POINT); 
	Format(platinum, sizeof(platinum), "플레티넘[%d점 이상]/까이는 점수[%d]", RAISE_PLATINUM_POINT, DEATH_PLATINUM_POINT); 
	Format(diamond, sizeof(diamond), "다이아[%d점 이상]/까이는 점수[%d]", RAISE_DIAMOND_POINT, DEATH_DIAMOND_POINT); 
	Format(master, sizeof(master), "마스터[%d점 이상]/까이는 점수[%d]", RAISE_MASTER_POINT, DEATH_MASTER_POINT); 
	Format(grandmaster, sizeof(grandmaster), "그랜드마스터[%d이상]/까이는 점수[%d]", RAISE_GRANDMASTER_POINT, DEATH_GRANDMASTER_POINT); 
	
	SetMenuTitle(menu, "티어 구간 표[당신의 티어:%s]", playerTier[client]);
	AddMenuItem(menu, "", bronzePoint, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", silverPoint, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", goldPoint, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", platinum, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", diamond, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", master, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", grandmaster, ITEMDRAW_DISABLED);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public CreateLadderPlayerScoreMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderPlayerScoreMenuHandler);
	new String:playerInfo[256];
	new playerScore;
	
	for(new i=1; i<=NMRIH_MAX_PLAYERS; i++) {
		if(IsClientInGame(i)) {
		
			playerScore = playerLadderScore[i];
			
			Format(playerInfo, sizeof(playerInfo), "[플레이어:%N][티어:%s][스코어:%d][순위:%d]", i, playerTier[i], playerScore, playerRanking[i]);
			AddMenuItem(menu, "", playerInfo, ITEMDRAW_DISABLED);
			
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public CreateLadderInfoMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderInfoMenuHandler);
	new String:zombieKill[64], String:zombieFireKill[64], String:mapClear[64], String:mapClearTierBonus[128], String:deathMinusPoint[64];
	
	Format(zombieKill, sizeof(zombieKill), "좀비를 죽일시 [%d]", ZOMBIE_KILL_POINT);
	Format(zombieFireKill, sizeof(zombieFireKill), "좀비를 화염으로 죽일시 [%d]", ZOMBIE_KILL_POINT/2);
	Format(mapClear, sizeof(mapClear), "맵을 클리어 할시 [%d]", ESCAPE_POINT);
	Format(mapClearTierBonus, sizeof(mapClearTierBonus), "[%s]맵 클리어 시 해당 티어 보너스 [%d]", playerTier[client], (GetLadderTierDeathPointScore(client)/5)*2);
	Format(deathMinusPoint, sizeof(deathMinusPoint), "[%s]죽을시 차감되는 티어 포인트 [%d]", playerTier[client], GetLadderTierDeathPointScore(client));
	
	SetMenuTitle(menu, "래더에 관한 정보");
	AddMenuItem(menu, "", zombieKill, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", zombieFireKill, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", mapClear, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", mapClearTierBonus, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", deathMinusPoint, ITEMDRAW_DISABLED);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public CreateLadderDisconnectInfoMenu(client) {
	if(!IsPlayerAlive(client)) {
		PrintToChat(client, "\x01%s살아있을때만 보실수 있습니다.", LADDER_PREFIX);
		return;
	}
	
	new Handle:menu = CreateMenu(CreateLadderDisconnectInfoMenuHandler);
	new String:healthRatioPoint[64], String:infectionPoint[64], String:bleedingPoint[64];
	new infectionMinusScore = 0, bleedingMinusScore = 0;
	
	if(IsClientInfected(client))
		infectionMinusScore = DISCONNECT_INFECTION_POINT;
	
	if(IsClientBleeding(client))
		 bleedingMinusScore = DISCONNECT_BLEEDING_POINT;
		 
	Format(healthRatioPoint, sizeof(healthRatioPoint), "현재 탈주시 체력비례 까이는 점수 [%d]", RoundToCeil(((100-GetClientHealth(client)) * GetLadderTierDeathPointScore(client))/99.0)); 
	Format(infectionPoint, sizeof(infectionPoint), "감염에 걸리고 나갈 시 까이는 점수 [%d]", DISCONNECT_INFECTION_POINT);
	Format(bleedingPoint, sizeof(bleedingPoint), "출혈에 걸리고 나갈 시 까이는 점수 [%d]", DISCONNECT_BLEEDING_POINT);
	
	SetMenuTitle(menu, "현재 탈주시 까이는 점수 [%d]", RoundToCeil((((100-GetClientHealth(client)) * GetLadderTierDeathPointScore(client))/99.0) + bleedingMinusScore + infectionMinusScore));
	AddMenuItem(menu, "", healthRatioPoint, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", infectionPoint, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", bleedingPoint, ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public CreateLadderPlusPointInfoMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderPlusPointInfoHandler);
	
	SetMenuTitle(menu, "미션에 대한 정보 [미션참여 가능 여부 : %s]", (playerMissonApply[client]) ? "가능" : "불가능");
	
	if(playerMissonApply[client]) {
		switch(playerMissionSelection) {
			case MISSION_NO_DEATH: {
				new String:noDeathPoint1[64], String:noDeathPoint2[64];
				
				if((playerDeathCount[client] * MISSION_NO_DEATH_MINUS_POINT) >= MISSION_NO_DEATH_CLEAR_POINT)
					Format(noDeathPoint1, sizeof(noDeathPoint1), "미션[노 데스] 탈출시 얻을 보너스 점수[0]");
				else 
					Format(noDeathPoint1, sizeof(noDeathPoint1), "미션[노 데스] 탈출시 얻을 보너스 점수[%d]", MISSION_NO_DEATH_CLEAR_POINT - (playerDeathCount[client] * MISSION_NO_DEATH_MINUS_POINT));
					
				Format(noDeathPoint2, sizeof(noDeathPoint2), "기본 점수[%d] / 죽을시 차감 점수[%d]", MISSION_NO_DEATH_CLEAR_POINT, MISSION_NO_DEATH_MINUS_POINT);
				
				AddMenuItem(menu, "", noDeathPoint1, ITEMDRAW_DISABLED);
				AddMenuItem(menu, "", noDeathPoint2, ITEMDRAW_DISABLED);	
			}
			
			case MISSION_NO_HURT: {
				new String:noDamagePoint1[64], String:noDamagePoint2[64];
				
				if((playerHurtCount[client] * MISSION_NO_HURT_MINUS_POINT) >= MISSION_NO_HURT_CLEAR_POINT)
					Format(noDamagePoint1, sizeof(noDamagePoint1), "미션[노 피격] 탈출시 얻을 보너스 점수[0]");
				else 
					Format(noDamagePoint1, sizeof(noDamagePoint1), "미션[노 피격] 탈출시 얻을 보너스 점수[%d]", MISSION_NO_HURT_CLEAR_POINT - (playerHurtCount[client] * MISSION_NO_HURT_MINUS_POINT));
					
				Format(noDamagePoint2, sizeof(noDamagePoint2), "기본 점수[%d] / 피격당 차감 점수[%d]", MISSION_NO_HURT_CLEAR_POINT, MISSION_NO_HURT_MINUS_POINT);
				
				AddMenuItem(menu, "", noDamagePoint1, ITEMDRAW_DISABLED);
				AddMenuItem(menu, "", noDamagePoint2, ITEMDRAW_DISABLED);				
			}
			
			case MISSION_ZOMBIE_KILL: {
				new String:zombieKillPoint1[64], String:zombieKillPoint2[64];
				
				if(playerZombieKill[client] < MISSION_ZOMBIE_KILL_GOAL)
					Format(zombieKillPoint1, sizeof(zombieKillPoint1), "미션[좀비 킬] 탈출시 얻을 보너스 점수[0]");
				else 
					Format(zombieKillPoint1, sizeof(zombieKillPoint1), "미션[좀비 킬] 탈출시 얻을 보너스 점수[%d]", MISSION_ZOMBIE_KILL_CLEAR_POINT);
					
				Format(zombieKillPoint2, sizeof(zombieKillPoint2), "미션 클리어 까지 남은 좀비 킬수[%d]", (playerZombieKill[client] < MISSION_ZOMBIE_KILL_GOAL) ? (MISSION_ZOMBIE_KILL_GOAL - playerZombieKill[client]) : 0);
				
				AddMenuItem(menu, "", zombieKillPoint1, ITEMDRAW_DISABLED);
				AddMenuItem(menu, "", zombieKillPoint2, ITEMDRAW_DISABLED);				
			}
			
			case MISSION_NO_PILLS: {
				new String:noPillsPoint1[64], String:noPillsPoint2[64];
				
				if(playerPillsTakenCount[client] * MISSION_NO_PILLS_MINUS_POINT >= MISSION_NO_PILLS_CLEAR_POINT)
					Format(noPillsPoint1, sizeof(noPillsPoint1), "미션[약 안먹기] 탈출시 얻을 보너스 점수[0]");
				else 
					Format(noPillsPoint1, sizeof(noPillsPoint1), "미션[약 안먹기] 탈출시 얻을 보너스 점수[%d]", MISSION_NO_PILLS_CLEAR_POINT - (playerPillsTakenCount[client] * MISSION_NO_PILLS_MINUS_POINT));
					
			
				Format(noPillsPoint2, sizeof(noPillsPoint2), "기본 점수[%d] / 먹을떄마다 차감 점수[%d]", MISSION_NO_PILLS_CLEAR_POINT, MISSION_NO_PILLS_MINUS_POINT);
				
				AddMenuItem(menu, "", noPillsPoint1, ITEMDRAW_DISABLED);
				AddMenuItem(menu, "", noPillsPoint2, ITEMDRAW_DISABLED);				
			}
			
			case MISSION_NO_SHOVED: {
				new String:noShovedPoint1[64], String:noShovedPoint2[64];
				
				if(playerShovedCount[client] * MISSION_NO_SHOVED_MINUS_POINT >= MISSION_NO_SHOVED_CLEAR_POINT)
					Format(noShovedPoint1, sizeof(noShovedPoint1), "미션[안 밀치기] 탈출시 얻을 보너스 점수[0]");
				else 
					Format(noShovedPoint1, sizeof(noShovedPoint1), "미션[안 밀치기] 탈출시 얻을 보너스 점수[%d]", MISSION_NO_SHOVED_CLEAR_POINT - (playerShovedCount[client] * MISSION_NO_SHOVED_MINUS_POINT));
					
			
				Format(noShovedPoint2, sizeof(noShovedPoint2), "기본 점수[%d] / 밀치기당 차감 점수[%d]", MISSION_NO_SHOVED_CLEAR_POINT, MISSION_NO_SHOVED_MINUS_POINT);
				
				AddMenuItem(menu, "", noShovedPoint1, ITEMDRAW_DISABLED);
				AddMenuItem(menu, "", noShovedPoint2, ITEMDRAW_DISABLED);				
			}
		}
	}
	
	AddMenuItem(menu, "", "미션은 처음 게임 시작시에만 수행하실수 있습니다.", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "MISSION_LIST", "미션 종류");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public CreateLadderMissionListMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderMissionListHandler);
	new String:missionString1[64], String:missionString2[64], String:missionString3[64], String:missionString4[64], String:missionString5[64];
	
	Format(missionString1, sizeof(missionString1), "죽지 않고 클리어[보너스 : %d][차감 : %d]", MISSION_NO_DEATH_CLEAR_POINT, MISSION_NO_DEATH_MINUS_POINT);
	Format(missionString2, sizeof(missionString2), "타격 입지 않고 클리어[보너스 : %d][차감 : %d]", MISSION_NO_HURT_CLEAR_POINT, MISSION_NO_HURT_MINUS_POINT);
	Format(missionString3, sizeof(missionString3), "좀비 %d킬후 클리어[보너스 : %d]", MISSION_ZOMBIE_KILL_GOAL, MISSION_ZOMBIE_KILL_CLEAR_POINT);
	Format(missionString4, sizeof(missionString4), "약 안먹고 클리어[보너스 : %d][차감 : %d]", MISSION_NO_PILLS_CLEAR_POINT, MISSION_NO_PILLS_MINUS_POINT);
	Format(missionString5, sizeof(missionString5), "안 밀치고 클리어[보너스 : %d][차감 : %d]", MISSION_NO_SHOVED_CLEAR_POINT, MISSION_NO_SHOVED_MINUS_POINT);
	
	SetMenuTitle(menu, "미션의 종류");
	AddMenuItem(menu, "", missionString1, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", missionString2, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", missionString3, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", missionString4, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", missionString5, ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public CreateLadderMyInfoMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderMyInfoHandler);
	new String:playerInfo1[64], String:playerInfo2[64], String:playerInfo3[64], String:playerInfo4[64], String:playerInfo5[64];
	
	Format(playerInfo1, sizeof(playerInfo1), "좀비 킬 [%d마리]", playerZombieKill[client]);
	Format(playerInfo2, sizeof(playerInfo2), "죽은 횟수 [%d번]", playerDeathCount[client]);
	Format(playerInfo3, sizeof(playerInfo3), "피격 입은 횟수 [%d번]", playerHurtCount[client]);
	Format(playerInfo4, sizeof(playerInfo4), "약 먹은 횟수 [%d번]", playerPillsTakenCount[client]);
	Format(playerInfo5, sizeof(playerInfo5), "좀비를 밀은 횟수 [%d번]", playerShovedCount[client]);
	
	SetMenuTitle(menu, "현재 이번 플레이의 전적");
	AddMenuItem(menu, "", playerInfo1, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", playerInfo2, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", playerInfo3, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", playerInfo4, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", playerInfo5, ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public CreateLadderSystemDeveloperMenu(client) {
	new Handle:menu = CreateMenu(CreateLadderSystemDeveloperHandler);
	
	SetMenuTitle(menu, "[개발자/사마나], 플러그인에 공헌하신 분");
	AddMenuItem(menu, "", "[티어 사진관련] - Amel", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 최고의 마루타] - ⎝Star Shah⎠⎞", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 최고의 마루타] - 예인", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - 무메이", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - 윤", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - KICKASS", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - CalDo", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - [PH]Doc", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - YUKI", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - JUNPA", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - Salt And Pepper", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "", "[티어 마루타] - 미소라", ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 		
}

public CreateLadderMenuHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, item, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "TOP_LADDER")) 
				CreateLadderTopScoreMenu(client);
			else if(StrEqual(itemInfo, "TIER_CHART")) 
				CreateLadderTierChartMenu(client);
			else if(StrEqual(itemInfo, "PLAYER_LADDER_SCORE")) 
				CreateLadderPlayerScoreMenu(client);
			else if(StrEqual(itemInfo, "LADDER_INFO")) 
				CreateLadderInfoMenu(client);
			else if(StrEqual(itemInfo, "DISCONNECT_POINT"))
				CreateLadderDisconnectInfoMenu(client);
			else if(StrEqual(itemInfo, "PlUS_POINT"))
				CreateLadderPlusPointInfoMenu(client);
			else if(StrEqual(itemInfo, "MY_INFO")) 
				CreateLadderMyInfoMenu(client);
			else if(StrEqual(itemInfo, "DEVELOP_CREDIT"))
				CreateLadderSystemDeveloperMenu(client);
				
		}
	}
}

public CreateLadderTopScoreMenuHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderTierChartHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderPlayerScoreMenuHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderInfoMenuHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderDisconnectInfoMenuHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderPlusPointInfoHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}

		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, item, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "MISSION_LIST")) 
				CreateLadderMissionListMenu(client);
				
		}
	}
}

public CreateLadderMissionListHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderPlusPointInfoMenu(client);
		}
	}
}

public CreateLadderMyInfoHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public CreateLadderSystemDeveloperHandler(Handle:menu, MenuAction:action, client, item) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
				CreateLadderMenu(client);
		}
	}
}

public Action:Event_ZombieShoved(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetEventInt(event, "player_id");
	
	if(player >=1 && player <=8) 
		playerShovedCount[player]++;
}

public Action:Event_PillsTaken(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetEventInt(event, "player_id");
	
	if(player >=1 && player <=8) 
		playerPillsTakenCount[player]++;
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(player >=1 && player <=8) 
		playerHurtCount[player]++;
	
}

public Action:Event_RoundBegin(Handle:event, const String:name[], bool:dontBroadcast) {
	for(int i=1; i<=NMRIH_MAX_PLAYERS; i++) {
		if(IsClientInGame(i)) 
			playerMissonApply[i] = true;
			playerZombieKill[i]	= 0; 
			playerDeathCount[i] = 0;
			playerHurtCount[i] = 0;
			playerPillsTakenCount[i] = 0;
			playerShovedCount[i] = 0;
	}
	
	playerSafety = false;
	playerMissionSelection = GetRandomInt(1, MISSION_LIST);
	
	PrintToChatAll("\x01----------------------%s----------------------", LADDER_PREFIX);
	
	switch(playerMissionSelection) {
		case MISSION_NO_DEATH: {
			PrintToChatAll("\x01\x07E5D85CMission \x01안 죽고 탈출해라 성공시 보너스 포인트 [%d]", MISSION_NO_DEATH_CLEAR_POINT);
			PrintToChatAll("\x01죽은 횟수당 [%d]만큼의 보너스 포인트가 차감되며", MISSION_NO_DEATH_MINUS_POINT);
			PrintToChatAll("\x01보너스 포인트는 0점 미만으로 하락되지 않습니다.");
		}
		case MISSION_NO_HURT: {
			PrintToChatAll("\x01\x07E5D85CMission \x01피격을 입지 않고 탈출해라 성공시 보너스 포인트 [%d]", MISSION_NO_HURT_CLEAR_POINT);
			PrintToChatAll("\x01피격 횟수당(피해를 입는것) [%d]만큼의 보너스 포인트가 차감되며", MISSION_NO_HURT_MINUS_POINT);
			PrintToChatAll("\x01보너스 포인트는 0점 미만으로 하락되지 않습니다.");			
		}
		case MISSION_ZOMBIE_KILL: {
			PrintToChatAll("\x01\x07E5D85CMission \x01좀비를 %d마리 처치해라 성공시 보너스 포인트 [%d]", MISSION_ZOMBIE_KILL_GOAL, MISSION_ZOMBIE_KILL_CLEAR_POINT);
			PrintToChatAll("\x01이번 미션은 달성만 하는것이 목적이며");
			PrintToChatAll("\x01실패시 보너스 포인트는 0점으로 처리됩니다.");			
		}
		case MISSION_NO_PILLS: {
			PrintToChatAll("\x01\x07E5D85CMission \x01약 안먹고 탈출해라 성공시 보너스 포인트 [%d]", MISSION_NO_PILLS_CLEAR_POINT);
			PrintToChatAll("\x01약을 한번 먹을때마다 [%d]만큼의 보너스 포인트가 차감되며", MISSION_NO_PILLS_MINUS_POINT);
			PrintToChatAll("\x01보너스 포인트는 0점 미만으로 하락되지 않습니다.");			
		}
		case MISSION_NO_SHOVED: {
			PrintToChatAll("\x01\x07E5D85CMission \x01안 밀치고 탈출해라 성공시 보너스 포인트 [%d]", MISSION_NO_SHOVED_CLEAR_POINT);
			PrintToChatAll("\x01좀비를 한번 밀칠떄마다 [%d]만큼의 보너스 포인트가 차감되며", MISSION_NO_SHOVED_MINUS_POINT);
			PrintToChatAll("\x01보너스 포인트는 0점 미만으로 하락되지 않습니다.");			
		}
	}
	
	PrintToChatAll("\x01-------------------------------------------------");
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(player >=1 && player <=8) {
		if(IsClientInGame(player)) {
			if(IsPlayerAlive(player) && !IsClientObserver(player)) {
			
				DeleteTierImage(player);
				SetLadderTierImage(player, playerTier[player]);
			}
		}
	}
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new player;
	player = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(player >=1 && player<=8) {
		DeleteTierImage(player);
		
		if(playerSafety) {
			PrintToChat(player, "\x01%s안전장치 가동중 준비중에는 죽어도 포인트를 잃지 않습니다.", LADDER_PREFIX);
			return;
		}
		
		new playerMinusDeathPoint;
		
		playerDeathCount[player]++;
		playerMinusDeathPoint = GetLadderTierDeathPointScore(player);
		
		if((playerLadderScore[player]-playerMinusDeathPoint) > 0 ) { // 현재 스코어 - 까일스코어가 0보다 작으면 0으로 설정.
			PrintToChat(player, "%s당신은 %d만큼의 래더 포인트가 차감되었습니다.", LADDER_PREFIX, playerMinusDeathPoint);
			MinusLadderScore(player, playerMinusDeathPoint);
		} else {
			PrintToChat(player, "%s당신은 %d만큼의 래더 포인트가 차감되었습니다.", LADDER_PREFIX, playerMinusDeathPoint);
			playerLadderScore[player] = 0;
			SetLadderTier(player, LADDER_BRONZE);
		}
	}
}

public Action:Event_NpcKilled(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetEventInt(event, "killeridx");
	
	if(player >= 1 && player <= 8) {
		if(playerSafety) {
			PrintToChat(player, "\x01%s안전장치 가동중 준비중에는 포인트를 흭득하실수 없습니다.", LADDER_PREFIX);
			return;
		}
		
		playerZombieKill[player]++;
		AddLadderScore(player, ZOMBIE_KILL_POINT);
	}
}
public Action:Event_ZombieKilledByFire(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetEventInt(event, "igniter_id");
	
	if(player >= 1 && player <= 8) {
		if(playerSafety) {
			PrintToChat(player, "\x01%s안전장치 가동중 준비중에는 포인트를 흭득하실수 없습니다.", LADDER_PREFIX);
			return;
		}
		AddLadderScore(player, ZOMBIE_KILL_POINT/2);
	}
}

public Action:Event_PlayerExtracted(Handle:event, const String:name[], bool:dontBroadcast) {
	new tierScoreBonus;
	new player = GetEventInt(event, "player_id");
	
	
	if(playerMissonApply[player]) {
		switch(playerMissionSelection) {
			case MISSION_NO_DEATH: {
				if((playerDeathCount[player] * MISSION_NO_DEATH_MINUS_POINT) >= MISSION_NO_DEATH_CLEAR_POINT) 
					tierScoreBonus = 0;
				else
					tierScoreBonus = MISSION_NO_DEATH_CLEAR_POINT - (playerDeathCount[player] * MISSION_NO_DEATH_MINUS_POINT);
			}
			
			case MISSION_NO_HURT: {
				if((playerHurtCount[player] * MISSION_NO_HURT_MINUS_POINT) >= MISSION_NO_HURT_CLEAR_POINT) 
					tierScoreBonus = 0;
				else
					tierScoreBonus = MISSION_NO_HURT_CLEAR_POINT - (playerHurtCount[player] * MISSION_NO_HURT_MINUS_POINT);			
			}
			
			case MISSION_ZOMBIE_KILL: {
				tierScoreBonus = (playerZombieKill[player] < MISSION_ZOMBIE_KILL_GOAL) ? 0 : MISSION_ZOMBIE_KILL_CLEAR_POINT;				
			}
			
			case MISSION_NO_PILLS: {
				if((playerPillsTakenCount[player] * MISSION_NO_PILLS_MINUS_POINT) >= MISSION_NO_PILLS_CLEAR_POINT) 
					tierScoreBonus = 0;
				else
					tierScoreBonus = MISSION_NO_PILLS_CLEAR_POINT - (playerPillsTakenCount[player] * MISSION_NO_PILLS_MINUS_POINT);		
			}
			
			case MISSION_NO_SHOVED: {
				if((playerShovedCount[player] * MISSION_NO_SHOVED_MINUS_POINT) >= MISSION_NO_SHOVED_CLEAR_POINT) 
					tierScoreBonus = 0;
				else
					tierScoreBonus = MISSION_NO_SHOVED_CLEAR_POINT - (playerShovedCount[player] * MISSION_NO_SHOVED_MINUS_POINT);
			}
		}
	} else {
		tierScoreBonus = 0;
	}

	PrintToChat(player, "\x01--------------------%s--------------------", LADDER_PREFIX);
	PrintToChat(player, "\x01맵 클리어 보너스 점수[%d], 미션 보너스 추가 점수[%d]", ESCAPE_POINT, tierScoreBonus);
	PrintToChat(player, "\x01얻은 래더 포인트 총 합계[%d]", (ESCAPE_POINT+tierScoreBonus));
	PrintToChat(player, "\x01---------------------------------------------");
	
	AddLadderScore(player, (ESCAPE_POINT+tierScoreBonus));
	DeleteTierImage(player);
}

public ConnectLadderDatabase() {
	new String:error[256];
	
	database_ladder = SQL_Connect("ladder_system", true, error, sizeof(error));
	
	if(database_ladder == INVALID_HANDLE)
		SetFailState(error);
	
	SQL_Query(database_ladder, "CREATE TABLE IF NOT EXISTS ladder_system (steam_id VARCHAR(32) PRIMARY KEY, player_name TEXT, ladder_tier TEXT, ladder_score INTEGER);");
	SQL_Query(database_ladder, "DELETE FROM ladder_system WHERE ladder_score = 0;");
}

public LadderSystemDataSavePlayer(client) {
	new String:query[1024], String:playerSteamAdress[32];
	GetClientAuthString(client, playerSteamAdress, sizeof(playerSteamAdress));
	Format(query, sizeof(query), "UPDATE ladder_system SET player_name = '%N', ladder_tier = '%s', ladder_score = '%d' WHERE steam_id = '%s';", client, playerTier[client], playerLadderScore[client], playerSteamAdress);
	SQL_Query(database_ladder, "SET NAMES UTF8;");
	SQL_Query(database_ladder, query);
}

public LadderSystemDownloadFiles() {
	PrecacheModel("materials/ladder_bronze.vmt", true);
	PrecacheModel("materials/ladder_silver.vmt", true);
	PrecacheModel("materials/ladder_gold.vmt", true);
	PrecacheModel("materials/ladder_platinum.vmt", true);
	PrecacheModel("materials/ladder_diamond.vmt", true);
	PrecacheModel("materials/ladder_master.vmt", true);
	PrecacheModel("materials/ladder_grandmaster.vmt", true);
	
	AddFileToDownloadsTable("materials/ladder_bronze.vmt");
	AddFileToDownloadsTable("materials/ladder_bronze.vtf");
	AddFileToDownloadsTable("materials/ladder_silver.vmt");
	AddFileToDownloadsTable("materials/ladder_silver.vtf");
	AddFileToDownloadsTable("materials/ladder_gold.vmt");
	AddFileToDownloadsTable("materials/ladder_gold.vtf");
	AddFileToDownloadsTable("materials/ladder_platinum.vmt");
	AddFileToDownloadsTable("materials/ladder_platinum.vtf");
	AddFileToDownloadsTable("materials/ladder_diamond.vmt");
	AddFileToDownloadsTable("materials/ladder_diamond.vtf");
	AddFileToDownloadsTable("materials/ladder_master.vmt");
	AddFileToDownloadsTable("materials/ladder_master.vtf");
	AddFileToDownloadsTable("materials/ladder_grandmaster.vmt");
	AddFileToDownloadsTable("materials/ladder_grandmaster.vtf");
}

public AddLadderScore(client, addPoint) {	// 순서 조심 자칫하단 승격 안되는 수가 있음.
	new String:tierColor[16];
	new bool:checkRaise = false; // 승격 없다면 false
	
	if(playerLadderScore[client]<RAISE_SILVER_POINT) { 
		if((playerLadderScore[client] + addPoint)>=RAISE_SILVER_POINT) {
			SetLadderTier(client, LADDER_SILVER);
			checkRaise = true;
		}
		
	} else if(playerLadderScore[client]<RAISE_GOLD_POINT) { 
		if((playerLadderScore[client] + addPoint)>=RAISE_GOLD_POINT) {
			SetLadderTier(client, LADDER_GOLD);
			checkRaise = true;
		}
		
	} else if(playerLadderScore[client]<RAISE_PLATINUM_POINT) { 
		if((playerLadderScore[client] + addPoint)>=RAISE_PLATINUM_POINT) {
			SetLadderTier(client, LADDER_PLATINUM);
			checkRaise = true;
		}
		
	} else if(playerLadderScore[client]<RAISE_DIAMOND_POINT) {
		if((playerLadderScore[client] + addPoint)>=RAISE_DIAMOND_POINT) {
			SetLadderTier(client, LADDER_DIAMOND);
			checkRaise = true;
		}
		
	} else if(playerLadderScore[client]<RAISE_MASTER_POINT) { 
		if((playerLadderScore[client] + addPoint)>=RAISE_MASTER_POINT) {
			SetLadderTier(client, LADDER_MASTER);
			checkRaise = true;
		}
		
	} else if(playerLadderScore[client]<RAISE_GRANDMASTER_POINT) {
		if((playerLadderScore[client] + addPoint)>=RAISE_GRANDMASTER_POINT) {
			SetLadderTier(client, LADDER_GRANDMASTER);
			checkRaise = true;
		}	
		
	} 
	
	playerLadderScore[client] += addPoint;
	
	if(checkRaise) {
		GetLadderTierColor(client, tierColor, sizeof(tierColor));
	
		PrintToChatAll("\x01-------------------%s-------------------", LADDER_PREFIX);
		PrintToChatAll("\x01%N님이 \x07%s%s\x01로 승격되었습니다.", client, tierColor, playerTier[client]);
		PrintToChatAll("\x01--------------------------------------------");
	}
}

public MinusLadderScore(client, minusPoint) { // 순서 조심 자칫하단 강등 안되는 수가 있음.
	new String:tierColor[16];
	new bool:checkDemote = false; //강등 없다면 false
	
	if(playerLadderScore[client]>=RAISE_GRANDMASTER_POINT) { 
		if((playerLadderScore[client] - minusPoint)<RAISE_GRANDMASTER_POINT) {
			SetLadderTier(client, LADDER_MASTER);
			checkDemote = true;
		}
	} else if(playerLadderScore[client]>=RAISE_MASTER_POINT) { 
		if((playerLadderScore[client] - minusPoint)<RAISE_MASTER_POINT) {
			SetLadderTier(client, LADDER_DIAMOND);
			checkDemote = true;
		}
	} else if(playerLadderScore[client]>=RAISE_DIAMOND_POINT) { 
		if((playerLadderScore[client] - minusPoint)<RAISE_DIAMOND_POINT) {
			SetLadderTier(client, LADDER_PLATINUM);
			checkDemote = true;
		}
	} else if(playerLadderScore[client]>=RAISE_PLATINUM_POINT) {
		if((playerLadderScore[client] - minusPoint)<RAISE_PLATINUM_POINT) {
			SetLadderTier(client, LADDER_GOLD);
			checkDemote = true;
		}	
	} else if(playerLadderScore[client]>=RAISE_GOLD_POINT) {
		if((playerLadderScore[client] - minusPoint)<RAISE_GOLD_POINT) { 
			SetLadderTier(client, LADDER_SILVER);
			checkDemote = true;
		}
	} else if(playerLadderScore[client]>=RAISE_SILVER_POINT) {
		if((playerLadderScore[client] - minusPoint)<RAISE_SILVER_POINT) {
			SetLadderTier(client, LADDER_BRONZE);
			checkDemote = true;
		}
	} 
	
	playerLadderScore[client] -= minusPoint;
	
	if(checkDemote) {
		GetLadderTierColor(client, tierColor, sizeof(tierColor));
		PrintToChatAll("\x01--------------------%s--------------------", LADDER_PREFIX);
		PrintToChatAll("\x01%N님이 \x07%s%s\x01로 강등되었습니다...", client, tierColor, playerTier[client]);
		PrintToChatAll("\x01----------------------------------------------");
	}
}

public DisconnectLadderMinusScore(client) {
	if(playerLadderScore[client]<RAISE_SILVER_POINT || !IsPlayerAlive(client))
		return;
		
	new healthMinusScore = 0; // 체력비례 차감
	new infectionMinusScore = 0; // 감염으로 인한 차감
	new bleedingMinusScore = 0; // 출혈로 인한 차감
	
	// 탈주시 피 비례 플레이어 래더 포인트 감소	
	healthMinusScore += RoundToCeil(((100-GetClientHealth(client)) * GetLadderTierDeathPointScore(client))/99.0);
		
	
	if(IsClientInfected(client)) 
		infectionMinusScore = DISCONNECT_INFECTION_POINT;
	
	if(IsClientBleeding(client)) 
		bleedingMinusScore = DISCONNECT_BLEEDING_POINT;
		
	if(!(healthMinusScore == 0 && infectionMinusScore == 0 && bleedingMinusScore == 0)) {
		PrintToChatAll("\x01--------------------%s--------------------", LADDER_PREFIX);
		PrintToChatAll("\x01플레이어 : %N / 탈주로 인한 차감 총합 [%d]", client, (healthMinusScore + infectionMinusScore + bleedingMinusScore));
		
		if(healthMinusScore != 0)
			PrintToChatAll("\x01체력 비례 래더포인트 차감 [%d]", healthMinusScore);
		
		if(infectionMinusScore != 0)
			PrintToChatAll("\x01감염으로 인한 래더포인트 차감 [%d]", infectionMinusScore);
		
		if(bleedingMinusScore != 0)
			PrintToChatAll("\x01출혈로 인한 래더포인트 차감 [%d]", bleedingMinusScore);
		PrintToChatAll("\x01---------------------------------------------");		
	}
	
	MinusLadderScore(client, (healthMinusScore + infectionMinusScore + bleedingMinusScore));
}

public GetPlayerLadderRaiseScore(client) {
	if(playerLadderScore[client]<RAISE_SILVER_POINT) 
		return RAISE_SILVER_POINT;
	else if(playerLadderScore[client]<RAISE_GOLD_POINT) 
		return RAISE_GOLD_POINT;
	else if(playerLadderScore[client]<RAISE_PLATINUM_POINT) 
		return RAISE_PLATINUM_POINT;
	else if(playerLadderScore[client]<RAISE_DIAMOND_POINT) 
		return RAISE_DIAMOND_POINT;
	else if(playerLadderScore[client]<RAISE_MASTER_POINT) 
		return RAISE_MASTER_POINT;
	else if(playerLadderScore[client]<RAISE_GRANDMASTER_POINT) 
		return RAISE_GRANDMASTER_POINT;
	else 
		return 0;	
}

public GetLadderTierDeathPointScore(client) {
	new score = 0;

	if(playerLadderScore[client]>=RAISE_GRANDMASTER_POINT) 
		score = DEATH_GRANDMASTER_POINT;
	else if(playerLadderScore[client]>=RAISE_MASTER_POINT) 
		score = DEATH_MASTER_POINT;
	else if(playerLadderScore[client]>=RAISE_DIAMOND_POINT) 
		score = DEATH_DIAMOND_POINT;
	else if(playerLadderScore[client]>=RAISE_PLATINUM_POINT)
		score = DEATH_PLATINUM_POINT;
	else if(playerLadderScore[client]>=RAISE_GOLD_POINT) 
		score = DEATH_GOLD_POINT;
	else if(playerLadderScore[client]>=RAISE_SILVER_POINT) 
		score = DEATH_SILVER_POINT;
	else
		score = DEATH_BRONZE_POINT;
		
	return score;
}

public GetLadderTierColor(client, String:color[], colorStinrgSize) {
	if(playerLadderScore[client]>=RAISE_GRANDMASTER_POINT) 
		Format(color, colorStinrgSize, COLOR_GRANDMASTER);
	else if(playerLadderScore[client]>=RAISE_MASTER_POINT) 
		Format(color, colorStinrgSize, COLOR_MASTER);
	else if(playerLadderScore[client]>=RAISE_DIAMOND_POINT) 
		Format(color, colorStinrgSize, COLOR_DIAMOND);
	else if(playerLadderScore[client]>=RAISE_PLATINUM_POINT)
		Format(color, colorStinrgSize, COLOR_PLATINUM);
	else if(playerLadderScore[client]>=RAISE_GOLD_POINT) 
		Format(color, colorStinrgSize, COLOR_GOLD);
	else if(playerLadderScore[client]>=RAISE_SILVER_POINT) 
		Format(color, colorStinrgSize, COLOR_SILVER);
	else 
		Format(color, colorStinrgSize, COLOR_BRONZE);
}

public GetLadderTier(client, String:tier[]) {
	if(playerLadderScore[client]>=RAISE_GRANDMASTER_POINT) 
		Format(tier, TIER_SIZE, LADDER_GRANDMASTER);
	else if(playerLadderScore[client]>=RAISE_MASTER_POINT) 
		Format(tier, TIER_SIZE, LADDER_MASTER);
	else if(playerLadderScore[client]>=RAISE_DIAMOND_POINT) 
		Format(tier, TIER_SIZE, LADDER_DIAMOND);
	else if(playerLadderScore[client]>=RAISE_PLATINUM_POINT)
		Format(tier, TIER_SIZE, LADDER_PLATINUM);
	else if(playerLadderScore[client]>=RAISE_GOLD_POINT) 
		Format(tier, TIER_SIZE, LADDER_GOLD);
	else if(playerLadderScore[client]>=RAISE_SILVER_POINT) 
		Format(tier, TIER_SIZE, LADDER_SILVER);
	else 
		Format(tier, TIER_SIZE, LADDER_BRONZE);
}

public SetLadderTier(client, String:tier[]) {
	Format(playerTier[client], TIER_SIZE, tier);
	SetLadderTierImage(client, tier);
}

public SetLadderTierImage(client, String:tier[]) {
	new Float:clientPosition[3];
	new String:szTemp[64], String:imageNamePosition[64];
	new String:steamid[64];
	
	DeleteTierImage(client);
	
	if(!IsPlayerAlive(client))
		return;
		
	if(StrEqual(tier, LADDER_BRONZE))
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_bronze.vmt");
	else if(StrEqual(tier, LADDER_SILVER))
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_silver.vmt");
	else if(StrEqual(tier, LADDER_GOLD)) 	
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_gold.vmt");
	else if(StrEqual(tier, LADDER_PLATINUM)) 	
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_platinum.vmt");
	else if(StrEqual(tier, LADDER_DIAMOND)) 	
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_diamond.vmt");
	else if(StrEqual(tier, LADDER_MASTER)) 	
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_master.vmt");
	else if(StrEqual(tier, LADDER_GRANDMASTER)) 	
		Format(imageNamePosition, sizeof(imageNamePosition), "materials/ladder_grandmaster.vmt");
	
	Format(szTemp, sizeof(szTemp), "client%i", client);
	DispatchKeyValue(client, "targetname", szTemp);
	
	GetClientAbsOrigin(client, clientPosition);
	clientPosition[2] += 11.0;	
	clientPosition[1] -= 3.0;
	clientPosition[0] += 20.0;

	playerTierImage[client] = CreateEntityByName("env_sprite_oriented");
	
	if(playerTierImage[client]) {
		DispatchKeyValue(playerTierImage[client], "model", imageNamePosition);
		DispatchKeyValue(playerTierImage[client], "classname", "env_sprite_oriented");
		DispatchKeyValue(playerTierImage[client], "spawnflags", "1");
		DispatchKeyValue(playerTierImage[client], "scale", "0.1");
		DispatchKeyValue(playerTierImage[client], "rendermode", "1");
		DispatchKeyValue(playerTierImage[client], "rendercolor", "255 255 255");
		DispatchKeyValue(playerTierImage[client], "targetname", "donator_spr");
		DispatchKeyValue(playerTierImage[client], "parentname", szTemp);	
		DispatchSpawn(playerTierImage[client]);
		TeleportEntity(playerTierImage[client], clientPosition, NULL_VECTOR, NULL_VECTOR);	

		GetClientAuthString(client, steamid, 64);
		DispatchKeyValue(client, "targetname", steamid);
		SetVariantString(steamid);
		AcceptEntityInput(playerTierImage[client], "SetParent");
		AcceptEntityInput(playerTierImage[client], "FireUser1");	
		
		isPlayerTierImageCheck[client] = true;
	}
}

public DeleteTierImage(client){
	if(isPlayerTierImageCheck[client]) {
		if(IsValidEntity(playerTierImage[client])) {
			DispatchKeyValue(playerTierImage[client], "model", "0");
			AcceptEntityInput(playerTierImage[client], "Kill");
			isPlayerTierImageCheck[client] = false;
		}
	}
}

stock bool:IsClientInfected(client) {
	if(GetEntPropFloat(client, Prop_Send, "m_flInfectionTime") > 0 && GetEntPropFloat(client, Prop_Send, "m_flInfectionDeathTime") > 0) return true;
	else return false;
}

stock bool:IsClientBleeding(client) {
	if(GetEntProp(client, Prop_Send, "_bleedingOut") == 1) return true;
	else return false;
}
