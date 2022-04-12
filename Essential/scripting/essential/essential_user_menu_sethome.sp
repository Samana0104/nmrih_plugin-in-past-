

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

/* 유저 셋홈 메뉴 함수 */
public EssentialUserSethomeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserSethomeMenuHandler);
	
	SetMenuTitle(menu, "Set Home!");
	AddMenuItem(menu, "SET_POINT", "자신이 있는 위치를 홈으로 설정합니다.");
	AddMenuItem(menu, "TP_HOME", "지정한 홈으로 텔레포트 합니다.");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/*  유저 셋홈 - 메뉴 핸들러 */
public EssentialUserSethomeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(IsPlayerAlive(param1)) {
                if(StrEqual(itemInfo, "SET_POINT")) 
				    PlayerSetHome(param1);
                else if(StrEqual(itemInfo, "TP_HOME")) 
				    PlayerTeleportHome(param1);	
			} else {
			    PrintToChat(param1, "%s\x01살아있을때 해당 기능을 사용하실수 있습니다.", ESSENTIAL_PREFIX);
			}

			EssentialUserSethomeMenuCreate(param1);			
		}
	}
}