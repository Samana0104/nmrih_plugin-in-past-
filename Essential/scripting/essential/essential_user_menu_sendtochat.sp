

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

#define TARGET_NULL -1

/* 유저 귓속말 메뉴 함수 */
public EssentialUserSendToChatMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserSendToChatMenuHandler);
	new String:isSendToChat[32];
	new String:isTargetName[64];
	
	if(GetPlayerSendToChatTarget(client) == TARGET_NULL) {
		Format(isTargetName, sizeof(isTargetName), "귓속말 상대[존재하지 않음]");		
	} else {
		if(IsClientInGame(GetPlayerSendToChatTarget(client))) {
			new String:targetName[MAX_NAME_LENGTH];
			
			GetClientName(GetPlayerSendToChatTarget(client), targetName, sizeof(targetName));
			Format(isTargetName, sizeof(isTargetName), "귓속말 상대[%s]", targetName);
		} else {
			Format(isTargetName, sizeof(isTargetName), "귓속말 상대[귓속말 상대의 접속이 끊김]");
		}
	}
	
	if(IsPlayerSendToChat(client))
		Format(isSendToChat, sizeof(isSendToChat), "귓속말[온]");
	else 
		Format(isSendToChat, sizeof(isSendToChat), "귓속말[오프]");
	
	SetMenuTitle(menu, "귓속말 < 채팅이 얼려질시 사용이 불가능합니다. >");
	AddMenuItem(menu, "SET_SEND_TO_TARGET", isTargetName);
	AddMenuItem(menu, "SET_SEND_TO", isSendToChat);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 유저 귓속말(대상 정하기) - 메뉴 함수 */
public EssentialUserSendToChatTargetMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];
	
	new Handle:menu = CreateMenu(EssentialUserSendToChatTargetMenuHandler);
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

/*  유저 귓속말 - 메뉴 핸들러 */
public EssentialUserSendToChatMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(StrEqual(itemInfo, "SET_SEND_TO_TARGET")) {
				EssentialUserSendToChatTargetMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_SEND_TO")) {
				SendToChatSetOnOff(param1);
				EssentialUserSendToChatMenuCreate(param1);
			}
		}
	}
}

/*  유저 귓속말(타겟 정하기) - 메뉴 핸들러 */
public EssentialUserSendToChatTargetMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialUserSendToChatMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(IsClientInGame(StringToInt(itemInfo))) {
			    SetPlayerSendToChatTarget(param1, StringToInt(itemInfo));
			    PrintToChat(param1, "%s\x01귓속말 상대가 설정되었습니다.", ESSENTIAL_PREFIX);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
            }

			EssentialUserSendToChatMenuCreate(param1);
		}
	}
}