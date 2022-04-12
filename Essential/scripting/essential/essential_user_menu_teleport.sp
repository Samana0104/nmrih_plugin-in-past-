

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

public EssentialUserTeleportMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserTeleportMenuHandler);
	new String:playerIndex[4], String:playerName[MAX_NAME_LENGTH];
	
	SetMenuTitle(menu, "해당 유저에게 텔레포트 합니다.");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			if(i == client)
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

public EssentialUserTeleportMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			new teleportTarget;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			teleportTarget = StringToInt(itemInfo);
			
			if(IsClientInGame(teleportTarget) && IsPlayerAlive(teleportTarget)) { // 이동할 대상 && 타겟
				TeleportPlayer(param1, teleportTarget);
			} else {
			    PrintToChat(param1, "%s\x01해당 플레이어 또는 타겟은 존재하거나 살아 있지 않습니다.", ESSENTIAL_PREFIX);
			}
		}
	}
}
