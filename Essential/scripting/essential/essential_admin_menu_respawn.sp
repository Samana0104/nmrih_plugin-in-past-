

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new Float:playerLastDeathPoint[MAXPLAYERS+1][3]; // 플레이어가 죽은 위치를 저장할 변수
new Float:spawnPoint[3]; // 플레이어 첫 시작 스폰포인트를 저장할 변수
 
new playerRespawnTarget[MAXPLAYERS+1][1]; // 리스폰 에디터<동료부활> 메뉴창에 플레이어가 지정한 리스폰 대상을 저장하는 변수

/* 어드민 리스폰에디터 메뉴 함수 */
public EssentialAdminRespawnEditorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminRespawnEditorMenuHandler);
	
	SetMenuTitle(menu, "Respawn Editor!");
	AddMenuItem(menu, "PLAYER_SPAWN", "해당유저를 시작점에 리스폰");
	AddMenuItem(menu, "LAST_DEATH_SPAWN", "해당유저를 죽은위치에 리스폰");
	AddMenuItem(menu, "PLAYER_TARGET_SPAWN", "해당유저를 동료 근처에서 리스폰");
	AddMenuItem(menu, "ALL_PLAYER_RESPAWN", "전부 나에게 리스폰 시킵니다.");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/* 어드민 리스폰에디터 - 플레이어 스폰 메뉴 함수 */
public EssentialAdminRespawnEditorPlayerSpawnMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminRespawnEditorPlayerSpawnMenuHandler);
	SetMenuTitle(menu, "죽은 유저 리스트");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && !IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/* 어드민 리스폰에디터 - 마지막 죽은 위치 플레이어 스폰 메뉴 함수 */
public EssentialAdminRespawnEditorPlayerLastDeathSpawnMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminRespawnEditorPlayerLastDeathSpawnMenuHandler);
	SetMenuTitle(menu, "죽은 유저 리스트");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && !IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/* 어드민 리스폰에디터 - 동료 근처에서 스폰<플레이어 리스트> 메뉴 함수 */
public EssentialAdminRespawnEditorPlayerSpawnListMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminRespawnEditorPlayerSpawnListMenuHandler);
	SetMenuTitle(menu, "부활할 대상");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && !IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);      
}

/* 어드민 리스폰에디터 - 동료 근처에서 스폰<타겟 리스트> 메뉴 함수 */
public EssentialAdminRespawnEditorTargetListMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminRespawnEditorTargetListMenuHandler);
	
	SetMenuTitle(menu, "%N님을 누군가에게 스폰?", GetPlayerRespawnTarget(client));
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

/*  어드민 리스폰에디터 - 메뉴 핸들러 */
public EssentialAdminRespawnEditorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "PLAYER_SPAWN"))
				EssentialAdminRespawnEditorPlayerSpawnMenuCreate(param1);	
			else if(StrEqual(itemInfo, "LAST_DEATH_SPAWN"))
                EssentialAdminRespawnEditorPlayerLastDeathSpawnMenuCreate(param1);
			else if(StrEqual(itemInfo, "PLAYER_TARGET_SPAWN"))
				EssentialAdminRespawnEditorPlayerSpawnListMenuCreate(param1);
			else if(StrEqual(itemInfo, "ALL_PLAYER_RESPAWN"))
                EssentialAdminRespawnEditorAllPlayerSpawn(param1);			
		}
	}
}

/* 어드민 리스폰에디터(플레이어 스폰) - 메뉴 핸들러 */
public EssentialAdminRespawnEditorPlayerSpawnMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminRespawnEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(!IsClientInGame(StringToInt(itemInfo))) //해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			else
				PlayerRespawn(StringToInt(itemInfo));
			
			EssentialAdminRespawnEditorPlayerSpawnMenuCreate(param1);			
		}
	}
}

/* 어드민 리스폰에디터(마지막 죽은위치 플레이어 스폰) - 메뉴 핸들러 */
public EssentialAdminRespawnEditorPlayerLastDeathSpawnMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminRespawnEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new targetPlayer;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			targetPlayer = StringToInt(itemInfo);
			
 			if(!IsClientInGame(targetPlayer)) { //해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				PlayerRespawn(targetPlayer);
				
				if(!(playerLastDeathPoint[targetPlayer][0] == 0.0 && playerLastDeathPoint[targetPlayer][1] == 0.0 && playerLastDeathPoint[targetPlayer][2] == 0.0))
				    TeleportEntity(targetPlayer, playerLastDeathPoint[targetPlayer], NULL_VECTOR, NULL_VECTOR);
            }
			
			EssentialAdminRespawnEditorPlayerLastDeathSpawnMenuCreate(param1);			
		}
	}
}

/* 어드민 리스폰에디터(동료 근처에서 부활)<플레이어 리스트> - 메뉴 핸들러 */
public EssentialAdminRespawnEditorPlayerSpawnListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminRespawnEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(IsClientInGame(StringToInt(itemInfo))) {
				SetPlayerRespawnTarget(param1, StringToInt(itemInfo));
				EssentialAdminRespawnEditorTargetListMenuCreate(param1);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
            }						
		}
	}
}

/* 어드민 리스폰에디터(동료 근처에서 부활)<타겟 리스트> - 메뉴 핸들러 */
public EssentialAdminRespawnEditorTargetListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminRespawnEditorPlayerSpawnListMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new targetPlayer;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			targetPlayer = StringToInt(itemInfo);
			
			if(IsClientInGame(GetPlayerRespawnTarget(param1)) && IsClientInGame(targetPlayer)) { // 부활할 대상 && 타겟
				PlayerRespawn(GetPlayerRespawnTarget(param1))
				TeleportPlayer(GetPlayerRespawnTarget(param1), targetPlayer);
				EssentialAdminRespawnEditorPlayerSpawnListMenuCreate(param1);
			} else {
			    PrintToChat(param1, "%s\x01부활할 대상 또는 타겟이 존재하지 않습니다.", ESSENTIAL_PREFIX);
			}
		}
	}
}

/* 어드민 리스폰에디터 - 전부 나에게 리스폰 함수 */
public EssentialAdminRespawnEditorAllPlayerSpawn(client) {
	if(IsPlayerAlive(client)) {
		for(new i=1; i<=GetMaxClients(); i++) {
			if(IsClientInGame(i) && !IsPlayerAlive(i)) {
				PlayerRespawn(i);
				TeleportPlayer(i, client);
			}
		}
		PrintToChat(client, "%s\x01전부 리스폰 시켰습니다.", ESSENTIAL_PREFIX);
	} else {
		PrintToChat(client, "%s\x01살아있을때 시전이 가능합니다.", ESSENTIAL_PREFIX);	
	}
	
}

stock PlayerRespawn(target){ // target = 부활대상 - 플레이어 부활
	new targetSpawnEntity = CreateEntityByName("info_player_nmrih"); 
	new Float:playerSpawnPoint[3];
	
	GetSpawnPoint(playerSpawnPoint);
	
	DispatchKeyValueVector(targetSpawnEntity, "Origin", playerSpawnPoint);
	DispatchKeyValueVector(target, "Origin", playerSpawnPoint);
	DispatchSpawn(targetSpawnEntity);
	DispatchSpawn(target);
	
	AcceptEntityInput(targetSpawnEntity, "Kill");
	
	SetEntProp(target, Prop_Send, "m_iPlayerState", 0);
	SetEntProp(target, Prop_Send, "m_iHideHUD", 2050);
	
	PrintToChat(target, "%s\x01당신은 부활되었습니다.", ESSENTIAL_PREFIX);
}

public GetPlayerLastDeathPoint(client, Float:getPoint[3]){
	getPoint[0] = playerLastDeathPoint[client][0];
	getPoint[1] = playerLastDeathPoint[client][1];
	getPoint[2] = playerLastDeathPoint[client][2];
}

public GetPlayerRespawnTarget(client){
	return playerRespawnTarget[client][0];
}

public GetSpawnPoint(Float:getPoint[3]){
	getPoint[0] = spawnPoint[0];
	getPoint[1] = spawnPoint[1];
	getPoint[2] = spawnPoint[2];
}

public SetPlayerLastDeathPoint(client, Float:setPoint[3]){
	playerLastDeathPoint[client][0] = setPoint[0];
	playerLastDeathPoint[client][1] = setPoint[1];
	playerLastDeathPoint[client][2] = setPoint[2];
}

public SetPlayerRespawnTarget(client, target){
	playerRespawnTarget[client][0] = target;
}

public SetSpawnPoint(Float:setPoint[3]) {
	spawnPoint[0] = setPoint[0];
	spawnPoint[1] = setPoint[1];
	spawnPoint[2] = setPoint[2];
}