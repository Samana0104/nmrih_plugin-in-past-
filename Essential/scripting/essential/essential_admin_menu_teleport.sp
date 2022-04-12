

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new playerTeleportTarget[MAXPLAYERS+1][1]; // 텔레포트 에디터<유저리스트> 메뉴창에 플레이어가 지정한 티피 대상을 저장하는 변수

/* 어드민 텔레포트 에디터 메뉴 함수 */
public EssentialAdminTeleportEditorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminTeleportEditorMenuHandler);
	
	SetMenuTitle(menu, "텔레포트 에디터!");
	AddMenuItem(menu, "TELEPORT_PLAYER", "해당유저를 텔레포트 시킵니다.");
	AddMenuItem(menu, "ALL_PLAYER_TELEPORT", "전부 나에게 티피 시킵니다.");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);   
}

/* 어드민 텔레포트 에디터 - 플레이어 리스트 메뉴 함수 */
public EssentialAdminTeleportEditorPlayerListMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminTeleportEditorPlayerListMenuHandler);
	SetMenuTitle(menu, "이동할 대상");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);      
}

/* 어드민 텔레포트 에디터 - 타겟 리스트 메뉴 함수 */
public EssentialAdminTeleportEditorTargetListMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminTeleportEditorTargetListMenuHandler);
	
	SetMenuTitle(menu, "%N님을 누군가에게 텔레포트?", GetPlayerTeleportTarget(client));
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			if(GetPlayerTeleportTarget(client) == i)
			    continue;
			
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);      
}
/* 어드민 텔레포트 에디터 - 전부 나에게 티피 함수 */
public EssentialAdminTeleportEditorAllPlayerTeleport(client) {
	if(IsPlayerAlive(client)) {
		AllPlayerTeleport(client);
		PrintToChat(client, "%s\x01전부 티피시켰습니다.", ESSENTIAL_PREFIX);
	} else {
		PrintToChat(client, "%s\x01살아있을때 시전이 가능합니다.", ESSENTIAL_PREFIX);				    
	}	 
}

/* 어드민 텔레포트 에디터 - 메뉴 핸들러 */
public EssentialAdminTeleportEditorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "TELEPORT_PLAYER")) {
				EssentialAdminTeleportEditorPlayerListMenuCreate(param1);
			} else if(StrEqual(itemInfo, "ALL_PLAYER_TELEPORT"))
				EssentialAdminTeleportEditorAllPlayerTeleport(param1);    			
		}
	}
}

/* 어드민 텔레포트 에디터(플레이어 리스트) - 메뉴 핸들러 */
public EssentialAdminTeleportEditorPlayerListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminTeleportEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(IsClientInGame(StringToInt(itemInfo))) {
				SetPlayerTeleportTarget(param1, StringToInt(itemInfo));
				EssentialAdminTeleportEditorTargetListMenuCreate(param1);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
            }						
		}
	}
}

/* 어드민 텔레포트 에디터(타겟 리스트) - 메뉴 핸들러 */
public EssentialAdminTeleportEditorTargetListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminTeleportEditorPlayerListMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			new teleportTarget;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			teleportTarget = StringToInt(itemInfo);
			
			if(IsClientInGame(GetPlayerTeleportTarget(param1)) && IsPlayerAlive(GetPlayerTeleportTarget(param1)) && IsClientInGame(teleportTarget) && IsPlayerAlive(teleportTarget)) { // 이동할 대상 && 타겟
				TeleportPlayer(GetPlayerTeleportTarget(param1), teleportTarget);
				EssentialAdminTeleportEditorPlayerListMenuCreate(param1);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어 또는 타겟은 존재하거나 살아 있지 않습니다.", ESSENTIAL_PREFIX);
			}
		}
	}
}

stock TeleportPlayer(player, targetPlayer) {
	new Float:targetPlayerPos[3];
	GetEntPropVector(targetPlayer, Prop_Send, "m_vecOrigin", targetPlayerPos);
	TeleportEntity(player, targetPlayerPos, NULL_VECTOR, NULL_VECTOR);
	PrintToChat(player, "%s\x01Teleporting...", ESSENTIAL_PREFIX);
}

stock AllPlayerTeleport(player) { // 해당 플레이어에게 텔레포트 합니다.
	for(new i=1; i<=GetMaxClients(); i++) {
		if(i == player)
			continue;
						
		if(IsClientInGame(i) && IsPlayerAlive(i)) 
			TeleportPlayer(i, player);
	}   
}

public GetPlayerTeleportTarget(client){
    return playerTeleportTarget[client][0];
}


public SetPlayerTeleportTarget(client, target) {
    playerTeleportTarget[client][0] = target;
}