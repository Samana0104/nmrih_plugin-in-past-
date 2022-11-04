#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
  
#include "essential/essential_admin_menu_essentialsetting.sp"
#include "essential/essential_admin_menu_adminsetting.sp"
#include "essential/essential_admin_menu_tools.sp"
#include "essential/essential_admin_menu_respawn.sp"
#include "essential/essential_admin_menu_inveditor.sp"
#include "essential/essential_admin_menu_teleport.sp"
#include "essential/essential_admin_menu_playerstatechange.sp"
#include "essential/essential_admin_menu_sendtochat.sp"
#include "essential/essential_admin_menu_sethome.sp"
#include "essential/essential_admin_menu_developermode.sp"
#include "essential/essential_admin_menu_allcontrol.sp"
#include "essential/essential_admin_menu_zombiespawner.sp"
#include "essential/essential_admin_menu_chatrelated.sp"
#include "essential/essential_user_menu_tools.sp"
#include "essential/essential_user_menu_sethome.sp"
#include "essential/essential_user_menu_sendtochat.sp"
#include "essential/essential_user_menu_invensee.sp"
#include "essential/essential_user_menu_teleport.sp"
#include "essential/essential_user_menu_chatrelated.sp"
#include "essential/essential_api.sp"

public Plugin:myinfo = {
	name = "Essential",
	author = "사마나",
	description = "버그가 생기면 이 플러그인의 해당 게시글에 댓글을 달아주시면 정말 감사드립니다.",
	version = "0.5",
	url = "https://app.box.com/s/fn7p1knhkawpay6pums7o0wn5o0rhwl0"
};

/* type = int */
new playerRankCount; // 클리어시 이름앞에 등수를 나타내는 변수 - 맵이 바뀌면 1로 초기화 되며 플레이어가 맵을 클리어 할때마다 1씩 증가함!

/* type = Float */
/* type = bool */

// new bool:isPlayerAlias[NMRIH_MAX_PLAYERS+1] = { false, ... }; // 접두사메뉴가 켜져있는지 아닌지 확인

new bool:playerSpawn = false; // 플레이어 스폰이 따여있는지

/* type = String */
new String:playerRank[MAXPLAYERS+1][12]; // 플레이어 순위를 나타나게 해주는 접두사

/*__________________
  |                                    |
  |서버 관련 콜백함수들|
  |__________________|
*/

public OnPluginStart() {	
	RegConsoleCmd("sm_es", CreateEssentialMenu, "에센셜 메뉴를 생성합니다.");
	RegConsoleCmd("say", Command_Say);
	
	SetPermissionBuildPathFile(); // api 함수
	SetEssentialSettingBuildPathFile(); // essentialsetting 함수 
	SetWeaponBuildPathFile(); // inveneditior 함수
	SetChatReladtedBuildPathFile(); // chatrelated 함수
	SetDevelopModeBuildPathFile(); // developermode 함수
	
	HookEvent("player_extracted", Event_PlayerExtracted);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("nmrih_round_begin", Event_RoundStart);
	HookEvent("weapon_picked_up", Event_WeaponPickedUp);
	
	new UserMsg:sayText2 = GetUserMessageId("SayText2");
	if (sayText2 != INVALID_MESSAGE_ID)
		HookUserMessage(sayText2, OnSayTextHook, true);
}

public OnClientPutInServer(client) {
	new Float:nullPoint[3] = {0.0, 0.0, 0.0};
	ClientCommand(client, "bind F3 sm_es"); //바인드 기능 단축키를 바꾸시려면 F3을 수정하세요!
	
	if(!IsPlayerAdmin(client)) { // 접속시 보이스 사용이 차단 되있다면 들어오는 플레이어를 보이스 차단시킴.
		if(!IsPlayerVoiceMuteOn()) 
			SetClientListeningFlags(client, VOICE_MUTED);
	}

	SetPlayerSetHomePoint(client, nullPoint); // essential_admin_menu_sethome 함수
	SetPlayerLastDeathPoint(client, nullPoint); // essential_admin_menu_respawn 함수
	SetPlayerChooseZombieSpawnPos(client, nullPoint); // essential_admin_menu_zombiespawner 함수
	SetPlayerChooseZombieSpawnPos(client, nullPoint);
	SetPlayerSendToChatTarget(client, TARGET_NULL);
	SetPlayerChooseZombieType(client, ZOMBIE_TYPE_NULL);
	SetPlayerChooseZombieColor(client, RGB_WHITE);
	SetPlayerChooseZombieSize(client, ZOMBIE_BASE_SIZE);
	SetPlayerChooseZombieHealth(client, ZOMBIE_BASE_HEALTH);
	
	SetPlayerSendToChat(client, false);
	SetPlayerAdminChat(client, false);
	
	SetChatColor(client, "FFFFFF");
}

public OnClientDisconnect(client) {
	
	if(IsAimShot(client)) // 에임샷을 킨유저가 나가면 꺼버림
		PlayerAimShotOnAndOff(client);
		
	if(IsHudAim(client)) // 허드줌을 킨유저가 나가버리면 꺼버림
		PlayerHudAimOnAndOff(client); 
	
	if(IsPlayerBhop(client)) 
		SetPlayerBhop(client, false);
		
	
}

public OnMapStart() {
    SetPlayerSpawn(false);
    SetPlayerRankCount(1);
	
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2]) {
	if(IsPlayerBhop(client)) {
		if(IsPlayerAlive(client)) {
			if(buttons & IN_JUMP) 
				PlayerActionBunnyHop(client);
		}
	}
	return Plugin_Continue;
}

/*____________________
  |                                        |
  |명령어 관련 콜백함수들|
  |____________________|
*/

// 어드민일시 어드민 메뉴를 생성하고 유저일시 유저메뉴를 생성합니다. < Permisson 이 등록되있을시 어드민 메뉴로 열림! >
public Action:CreateEssentialMenu(client, args) {
	if(IsPlayerEssentialPermission(client)) {
		EssentialAdminMenuCreate(client);
		return Plugin_Handled;
	}
	
	if(IsPlayerAdmin(client)) 
		EssentialAdminMenuCreate(client);
	else 
		EssentialUserMenuCreate(client);
	
	
	return Plugin_Handled;
}

public Action:Command_Say(client, args) { 		
	if(client == 0 || !EssentialSettingFunctionGetFlag("chat_function")) // 클라이언트가 콘솔이면 메세지만 출력
		return Plugin_Continue;

	new String:prefix[32], String:prefixColor[16], String:chatColor[16], String:message[128], String:messagePrint[256];
	
	GetCmdArgString(message, sizeof(message));
	message[strlen(message)-1] = '\x0';
	
	if(IsPrefixSetting(client)) { // 접두사를 추가한다고 접두사 이름을 입력할떄 
		if(IsClientInGame(GetPrefixTarget(client))) {
			AddPrefixPlayer(GetPrefixTarget(client), message[1]);
			SetPrefixSetting(client, false);
			PrintToChat(client, "%s\x01접두사를 설정하였습니다.", ESSENTIAL_PREFIX);
			PrintToChat(GetPrefixTarget(client), "%s\x01당신의 접두사는 %s으로 설정되었습니다!", ESSENTIAL_PREFIX, message[1]);
		} else {
			SetPrefixSetting(client, false);
			PrintToChat(client, "%s\x01해당 타겟은 접속중이 아닙니다.", ESSENTIAL_PREFIX);
		}
		
		return Plugin_Continue;
	}
	
	if(!IsPlayerChatOn()) { // 전체채팅이 얼려져있다면
		if(!IsPlayerAdmin(client)) 
			PrintToChat(client, "%s\x01지금은 채팅을 치실수 없습니다 < 귓속말 포함 >.", ESSENTIAL_PREFIX);
		
		return Plugin_Continue; 
	} else if(IsPlayerSendToChat(client)) { // 플레이어의 귓속말이 켜져있다면!
		if(IsClientInGame(GetPlayerSendToChatTarget(client))) {
			PrintToChat(client, "\x077DFE74[나->%N] : \x0792FFFF%s", GetPlayerSendToChatTarget(client), message[1]); // 자신에게 메세지 보여주기
			PrintToChat(GetPlayerSendToChatTarget(client), "\x077DFE74[%N->나] : \x0792FFFF%s", client, message[1]); // 귓속말 상대에게 메세지 보여주기
		} else {
			PrintToChat(client, "%s\x01당신의 귓속말 상대는 접속중이 아닙니다.", ESSENTIAL_PREFIX);
		}		
		
		return Plugin_Continue; 
	} else if(IsPlayerAdminChat(client)) {
		for(new i=1; i<=GetMaxClients(); i++) {
			if(IsClientInGame(i)) {
				if(IsPlayerAdmin(i))
					PrintToChat(i, "\x07FF4848[어드민 채팅]\x01%N : %s", client, message[1]);
			} 
		}
		return Plugin_Continue; 
	}
	
	LoadPrefix(client, prefix, sizeof(prefix));
	LoadPrefixColor(client, prefixColor, sizeof(prefixColor));
	LoadChatColor(client, chatColor, sizeof(chatColor));
	
	if(IsPlayerAlive(client)) {
		if(IsPlayerAdmin(client)) 
			Format(messagePrint, sizeof(messagePrint), "\x07FFB2F5[어드민]\x07BCFFB5%s\x01%N : \x07%s%s\x07%s%s", playerRank[client], client, prefixColor, prefix, chatColor, message[1]);
		else 
			Format(messagePrint, sizeof(messagePrint), "\x07BCFFB5%s\x01%N : \x07%s%s\x07%s%s", playerRank[client], client, prefixColor, prefix, chatColor, message[1]);
	} else {
		if(IsPlayerAdmin(client)) 
			Format(messagePrint, sizeof(messagePrint), "\x07FF5A5A(사망)\x07FFB2F5[어드민]\x07BCFFB5%s\x01%N : \x07%s%s\x07%s%s", playerRank[client], client, prefixColor, prefix, chatColor, message[1]);
		else 
			Format(messagePrint, sizeof(messagePrint), "\x07FF5A5A(사망)\x07BCFFB5%s\x01%N : \x07%s%s\x07%s%s", playerRank[client], client, prefixColor, prefix, chatColor, message[1]);	
	}
	
	PrintToChatAll(messagePrint);
	return Plugin_Continue; 
}

/*____________________
  |                                        |
  |에센셜 메뉴 관련 함수들|
  |____________________|
*/

/*
Admin Menu
*/

/* 에센셜 메뉴 본체 함수 */
public EssentialAdminMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminMenuHandler);
	SetMenuTitle(menu, "Admin Essential Menu!");
	
	if(IsPlayerEssentialPermission(client)) // 이 기능은 essential_permission 에 등록된 유저만 쓸수 있습니다.
		AddMenuItem(menu, "ADM_SETTING", "어드민 설정"); 
		
	AddMenuItem(menu, "TOOLS", "어드민 도구"); 
	AddMenuItem(menu, "SETHOME", "셋홈");

	if(EssentialSettingFunctionGetFlag("chat_function")) {
		AddMenuItem(menu, "SEND_TO_CHAT", "귓속말");
		AddMenuItem(menu, "CHAT_RELATE", "채팅 관련 설정 기능");
	}
	
	AddMenuItem(menu, "TELEPORT_EDITOR", "텔레포트 에디터");
	AddMenuItem(menu, "INVEN_EDITOR", "인벤 에디터");
	AddMenuItem(menu, "RESPAWN_EDITOR", "리스폰 에디터"); 
	AddMenuItem(menu, "PLAYER_STATE_CHANGE", "플레이어 상태 변경");
	AddMenuItem(menu, "ZOMBIE_SPAWNER", "좀비 스폰 에디터");
	AddMenuItem(menu, "ALL_CONTROL", "전체 관리");
	AddMenuItem(menu, "ESSENTIAL_SETTING", "에센셜 설정");
	
	if(IsPlayerEssentialPermission(client))
		AddMenuItem(menu, "DEVELOP_MODE", "개발자 모드");
		
	AddMenuItem(menu, "USER_MENU_JOIN", "유저 메뉴 접속");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/*
User Menu 
*/

/* 에센셜 메뉴 본체 함수 */
public EssentialUserMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserMenuHandler);
	SetMenuTitle(menu, "User Essential Menu!");
	
	if(EssentialSettingUsermenuControlGetFlag("user_tool"))
	    AddMenuItem(menu, "TOOLS", "도구");
	
	if(EssentialSettingUsermenuControlGetFlag("user_sethome"))
	    AddMenuItem(menu, "SETHOME", "셋홈");
	
	if(EssentialSettingFunctionGetFlag("chat_function")) {
		if(EssentialSettingUsermenuControlGetFlag("user_chatrelated"))
			AddMenuItem(menu, "CHAT_RELATE", "채팅 설정");
		
		if(EssentialSettingUsermenuControlGetFlag("user_sendtochat"))
			AddMenuItem(menu, "SEND_TO_CHAT", "귓속말");
	}
	
	if(EssentialSettingUsermenuControlGetFlag("user_invsee"))
	    AddMenuItem(menu, "INVEN_SEE", "플레이어 인벤 보기");
	
	if(EssentialSettingUsermenuControlGetFlag("user_teleport") && IsPlayerAlive(client)) // 플레이어가 살아있을때만 추가됨.
	    AddMenuItem(menu, "TELEPORT", "텔레포트");
	  
		
	AddMenuItem(menu, "DEVELOP_CREDIT", "개발자 크레딧");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);  
}


/* 유저 개발자 크레딧 메뉴 함수 */
public EssentialUserDevelopCreditMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserDevelopCreditMenuHandler);
	
	SetMenuTitle(menu, "개발자:사마나 - 도움 주신분");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);  
}

/*______________
  |                            |
  |메뉴 관련 핸들러|
  |______________|
*/

/*
Admin Menu Handler
*/

/* 에센셜 어드민 메뉴 본체 - 메뉴 핸들러*/
public EssentialAdminMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "ADM_SETTING")) 
			    EssentialAdminAdmSettingMenuCreate(param1);
			else if(StrEqual(itemInfo, "TOOLS"))
			    EssentialAdminToolsMenuCreate(param1);
			else if(StrEqual(itemInfo, "SETHOME"))
			    EssentialAdminSethomeMenuCreate(param1);
			else if(StrEqual(itemInfo, "SEND_TO_CHAT"))
			    EssentialAdminSendToChatMenuCreate(param1);
			else if(StrEqual(itemInfo, "CHAT_RELATE"))
				EssentialAdminChatRelateMenuCreate(param1);
			else if(StrEqual(itemInfo, "TELEPORT_EDITOR"))
			    EssentialAdminTeleportEditorMenuCreate(param1);
			else if(StrEqual(itemInfo, "INVEN_EDITOR"))
			    EssentialAdminInvenEditorMenuCreate(param1);
			else if(StrEqual(itemInfo, "RESPAWN_EDITOR"))
			    EssentialAdminRespawnEditorMenuCreate(param1);
			else if(StrEqual(itemInfo, "PLAYER_STATE_CHANGE"))
				EssentialAdminPlayerStateChangeMenuCreate(param1);
			else if(StrEqual(itemInfo, "ZOMBIE_SPAWNER")) 
				EssentialAdminZombieSpawnerMenuCreate(param1);
			else if(StrEqual(itemInfo, "ALL_CONTROL")) 
			    EssentialAdminAllControlMenuCreate(param1);
			else if(StrEqual(itemInfo, "ESSENTIAL_SETTING"))
			    EssentialAdminEssentialSettingMenuCreate(param1);
			else if(StrEqual(itemInfo, "DEVELOP_MODE"))
				EssentialAdminDevelopModeMenuCreate(param1);
			else if(StrEqual(itemInfo, "USER_MENU_JOIN"))
			    EssentialUserMenuCreate(param1);
		}
	}
}


/*________________
  |                                |
  | User Menu Handler |
  |________________|
*/

/* 유저 메뉴 본체 - 메뉴 핸들러*/
public EssentialUserMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "TOOLS"))
			    EssentialUserToolsMenuCreate(param1);
			else if(StrEqual(itemInfo, "SETHOME"))
			    EssentialUserSethomeMenuCreate(param1);
			else if(StrEqual(itemInfo, "SEND_TO_CHAT"))
			    EssentialUserSendToChatMenuCreate(param1);
			else if(StrEqual(itemInfo, "INVEN_SEE")) 
			    EssentialUserInvenSeeMenuCreate(param1);
			else if(StrEqual(itemInfo, "TELEPORT")) 
			    EssentialUserTeleportMenuCreate(param1);
			else if(StrEqual(itemInfo, "CHAT_RELATE"))
				EssentialUserChatRelateMenuCreate(param1);
			else if(StrEqual(itemInfo, "DEVELOP_CREDIT"))
			    EssentialUserDevelopCreditMenuCreate(param1);
		}
	}
}

/* 유저 개발자 크레딧  - 메뉴 핸들러 */
public EssentialUserDevelopCreditMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialUserMenuCreate(param1);
		}
	}
}

/*______________
  |                            |
  |    Essential API    |
  |______________|
*/
public Action:OnSayTextHook(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init) {
	if(!EssentialSettingFunctionGetFlag("chat_function"))
		return Plugin_Continue;
		
	return Plugin_Handled;
}


public Action:Event_PlayerExtracted(Handle:event, const String:name[], bool:dontBroadcast) {
	new player = GetEventInt(event, "player_id");
	Format(playerRank[player], 12, "[%d등!]", GetPlayerRankCount());
	SetPlayerRankCount(GetPlayerRankCount()+1);
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
    new player = GetClientOfUserId(GetEventInt(event, "userid"));
	
    if(IsPlayerAlive(player))
	    SetEntProp(player, Prop_Send, "m_iFOV", 90);
		
    if(!IsPlayerSpawn()) { // 처음 스폰장소가 따여있는지 확인
	    if(IsPlayerAlive(player)) {
			new Float:playerSpawnPointer[3];
			GetEntPropVector(player, Prop_Send, "m_vecOrigin", playerSpawnPointer);
			
			SetSpawnPoint(playerSpawnPointer); // essential_admin_menu_respawn 함수
			SetPlayerSpawn(true);
		}
	}
}
 
public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new Float:playerLastDeathPointer[3];
	new player = GetClientOfUserId(GetEventInt(event, "userid"));

	GetEntPropVector(player, Prop_Send, "m_vecOrigin", playerLastDeathPointer);		
	SetPlayerLastDeathPoint(player, playerLastDeathPointer); //essential_admin_menu_respawn 함수
	
	if(IsAimShot(player)) // 에임샷을 킨유저가 죽으면 꺼버림
		PlayerAimShotOnAndOff(player);
		
	if(IsHudAim(player)) // 허드줌을 킨유저가 죽으면 꺼버림
		PlayerHudAimOnAndOff(player);

	if(IsPlayerBhop(player)) 
		SetPlayerBhop(player, false);		
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	SetPlayerRankCount(1);
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			SetEntProp(i, Prop_Send, "m_iFOV", 90);
		}
		
		if(IsPlayerBhop(i)) {
			SetPlayerBhop(i, false);
			PrintToChat(i, "%s\x01버니합을 자동으로 종료합니다. < 무한점프의 우려가 있음 >", ESSENTIAL_PREFIX);
		}
		
		Format(playerRank[i], 12, "");
	}
}

public Action:Event_WeaponPickedUp(Handle:event, const String:name[], bool:dontBroadcast) {
	new weapon, player;
	new String:weaponName[64];
	
	player = GetEventInt(event, "player_id");
	weapon = GetEventInt(event, "weapon_id");
	
	if(IsPlayerAdmin(player))
		return Plugin_Handled;
		
	GetEntityClassname(weapon, weaponName, sizeof(weaponName));
	
	if(EssentialInvenEditiorWeaponBanGetFlag(weaponName, "ban")) {
		new weaponWeight = EssentialInvenEditiorWeaponBanGetFlag(weaponName, "weight");
		new playerWeight = GetEntProp(player, Prop_Send, "_carriedWeight");
		
		AcceptEntityInput(weapon, "Kill");
		SetEntProp(player, Prop_Send, "_carriedWeight", (playerWeight - weaponWeight));
		
		PrintToChat(player, "%s\x01이 물품은 금지 된 물품이므로 삭제합니다.", ESSENTIAL_PREFIX);
	}
	return Plugin_Handled;
}

public bool:IsPlayerSpawn() {
    return playerSpawn
}
 
public GetPlayerRankCount() {
    return playerRankCount;
}

public SetPlayerSpawn(bool:onAndOff) {
    playerSpawn = onAndOff;
}

public SetPlayerRankCount(count) {
    playerRankCount = count;
}
