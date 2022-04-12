

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

#define TARGET_NULL -1


new playerSendToChatTarget[MAXPLAYERS+1][1]; // 귓속말<대상 정하기> 메뉴창에 플레이어가 지정한 귓속말 대상을 저장하는 변수

new bool:playerSendToChat[MAXPLAYERS+1] = { false, ... }; // 플레이어의 귓속말이 켜져있는지 확인!
new bool:playerAdminChat[MAXPLAYERS+1] = { false, ... }; // 플레이어의 어드민채팅이 켜져있는지 확인!

/* 어드민 귓속말 메뉴 함수 */
public EssentialAdminSendToChatMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminSendToChatMenuHandler);
	new String:isSendToChat[32];
	new String:isAdminChat[32];
	new String:isTargetName[64];
	
	if(GetPlayerSendToChatTarget(client) == TARGET_NULL) {
		Format(isTargetName, sizeof(isTargetName), "귓속말 상대[존재하지 않음]");		
	} else {
		if(IsClientInGame(GetPlayerSendToChatTarget(client))) {
			Format(isTargetName, sizeof(isTargetName), "귓속말 상대[%N]", GetPlayerSendToChatTarget(client));
		} else {
			Format(isTargetName, sizeof(isTargetName), "귓속말 상대[귓속말 상대의 접속이 끊김]");
		}
	}
	
	if(IsPlayerSendToChat(client))
		Format(isSendToChat, sizeof(isSendToChat), "귓속말[온]");
	else 
		Format(isSendToChat, sizeof(isSendToChat), "귓속말[오프]");
	
	if(IsPlayerAdminChat(client)) 
		Format(isAdminChat, sizeof(isAdminChat), "어드민 전용 채팅[온]");
	else 
		Format(isAdminChat, sizeof(isAdminChat), "어드민 전용 채팅[오프]");
		
	SetMenuTitle(menu, "귓속말!");
	AddMenuItem(menu, "SET_SEND_TO_TARGET", isTargetName);
	AddMenuItem(menu, "SET_SEND_TO", isSendToChat);
	AddMenuItem(menu, "SET_ADMIN_CHAT", isAdminChat);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 귓속말(대상 정하기) - 메뉴 함수 */
public EssentialAdminSendToChatTargetMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];
		
	new Handle:menu = CreateMenu(EssentialAdminSendToChatTargetMenuHandler);	
	SetMenuTitle(menu, "귓속말 대상 정하기");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(i == client)
			continue;
		
		if(IsClientInGame(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/*  어드민 귓속말 - 메뉴 핸들러 */
public EssentialAdminSendToChatMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "SET_SEND_TO_TARGET")) {
				EssentialAdminSendToChatTargetMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_SEND_TO")) {
				SendToChatSetOnOff(param1);
				EssentialAdminSendToChatMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ADMIN_CHAT")) {
				AdminChatSetOnOff(param1);
				EssentialAdminSendToChatMenuCreate(param1);
			}
		}
	}
}

/*  어드민 귓속말(타겟 정하기) - 메뉴 핸들러 */
public EssentialAdminSendToChatTargetMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminSendToChatMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(IsClientInGame(StringToInt(itemInfo))) {
			    playerSendToChatTarget[param1][0] = StringToInt(itemInfo);
			    PrintToChat(param1, "%s\x01귓속말 상대가 설정되었습니다.", ESSENTIAL_PREFIX);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
            }

			EssentialAdminSendToChatMenuCreate(param1);
		}
	}
}

/* 귓속말(On off) - 함수 */
stock SendToChatSetOnOff(client) { 
	if(IsPlayerSendToChat(client)) {
		SetPlayerSendToChat(client, false);
		SetPlayerSendToChatTarget(client, TARGET_NULL);
		
		PrintToChat(client, "%s\x01귓속말이 꺼졌습니다.", ESSENTIAL_PREFIX);
	} else {
		if(GetPlayerSendToChatTarget(client) == TARGET_NULL) {
			PrintToChat(client, "%s\x01귓속말 대상이 정해지지 않았습니다. 대상을 먼저 정해주세요!", ESSENTIAL_PREFIX);
		} else {
			SetPlayerSendToChat(client, true);
			PrintToChat(client, "%s\x01귓속말이 켜졌습니다. 이제부터 하는 채팅은 다 귓속말로 처리됩니다.", ESSENTIAL_PREFIX);
		}
	}
}

/* 어드민 귓속말(어드민 채팅 on off) - 함수 */
stock AdminChatSetOnOff(client) {
	if(IsPlayerAdmin(client)) {
		if(IsPlayerAdminChat(client)) {
			SetPlayerAdminChat(client, false);
			PrintToChat(client, "%s\x01어드민 채팅이 꺼졌습니다.", ESSENTIAL_PREFIX);
		} else {
			SetPlayerAdminChat(client, true);
			PrintToChat(client, "%s\x01어드민 채팅이 켜졌습니다. 이제부터 하는 채팅은 다 어드민 전용 채팅으로 처리됩니다.", ESSENTIAL_PREFIX);
		}   
	} else {
		PrintToChat(client, "%s\x01어드민이 아니라면 이 기능을 사용하실수 없습니다.", ESSENTIAL_PREFIX);
	}
}

public bool:IsPlayerSendToChat(client) {
    return playerSendToChat[client];
}

public bool:IsPlayerAdminChat(client) {
    return playerAdminChat[client];
}

public GetPlayerSendToChatTarget(client) {
    return playerSendToChatTarget[client][0];
}

public SetPlayerSendToChat(client, bool:onAndOff) {
    return playerSendToChat[client] = onAndOff;
}

public SetPlayerAdminChat(client, bool:onAndOff) {
    playerAdminChat[client] = onAndOff;
}

public SetPlayerSendToChatTarget(client, target) { // target TARGET_NULL을 넣을시 각 함수에서 타겟이 없다는것을 알아차림
    playerSendToChatTarget[client][0] = target;
}