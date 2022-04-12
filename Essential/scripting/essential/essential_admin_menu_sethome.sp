

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new Float:playerSetHomePoint[MAXPLAYERS+1][3]; // 플레이어의 셋홈포인트를 저장할 변수

/* 어드민 셋홈 메뉴 함수 */
public EssentialAdminSethomeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminSethomeMenuHandler);
	
	SetMenuTitle(menu, "Set Home!");
	AddMenuItem(menu, "SET_POINT", "자신이 있는 위치를 홈으로 설정합니다.");
	AddMenuItem(menu, "TP_HOME", "지정한 홈으로 텔레포트 합니다.");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/*  어드민 셋홈 - 메뉴 핸들러 */
public EssentialAdminSethomeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(IsPlayerAlive(param1)) {
                if(StrEqual(itemInfo, "SET_POINT")) 
				    PlayerSetHome(param1);
                else if(StrEqual(itemInfo, "TP_HOME")) 
				    PlayerTeleportHome(param1);	
			} else {
			    PrintToChat(param1, "%s\x01살아있을때 해당 기능을 사용하실수 있습니다.", ESSENTIAL_PREFIX);
			}

			EssentialAdminSethomeMenuCreate(param1);			
		}
	}
}

stock PlayerSetHome(client) {
	new Float:playerSetSethomePoint[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerSetSethomePoint);
	SetPlayerSetHomePoint(client, playerSetSethomePoint);
	PrintToChat(client, "%s\x01현재 위치를 홈으로 설정하였습니다!", ESSENTIAL_PREFIX);
}

stock PlayerTeleportHome(client) {
	new Float:playerSetSethomePoint[3];
	GetPlayerSetHomePoint(client, playerSetSethomePoint);
					
	if(playerSetSethomePoint[0] == 0.0 && playerSetSethomePoint[1] == 0.0 && playerSetSethomePoint[2] == 0.0) {
		PrintToChat(client, "%s\x01홈으로 설정한 위치포인트가 존재하지 않습니다. / 위치를 먼저 설정해주세요", ESSENTIAL_PREFIX);
	} else {
		TeleportEntity(client, playerSetSethomePoint, NULL_VECTOR, NULL_VECTOR);
		PrintToChat(client, "%s\x01해당 홈으로 텔레포트 하였습니다.", ESSENTIAL_PREFIX);
	}
}

public GetPlayerSetHomePoint(client, Float:getPosition[3]) {
	getPosition[0] = playerSetHomePoint[client][0];
	getPosition[1] = playerSetHomePoint[client][1];
	getPosition[2] = playerSetHomePoint[client][2];
}

public SetPlayerSetHomePoint(client, Float:setPosition[3]) {
    playerSetHomePoint[client][0] = setPosition[0];
    playerSetHomePoint[client][1] = setPosition[1];
    playerSetHomePoint[client][2] = setPosition[2];
}