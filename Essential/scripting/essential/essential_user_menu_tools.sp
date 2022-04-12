

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

/* 유저 도구(허드줌, FOV) 메뉴 함수 */
public EssentialUserToolsMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserToolsMenuHandler)
	new String:hudAimOnAndOff[32];
	
	if(IsHudAim(client))
		Format(hudAimOnAndOff, sizeof(hudAimOnAndOff), "줌[적용]");
	else
		Format(hudAimOnAndOff, sizeof(hudAimOnAndOff), "줌[비적용]");
	
	SetMenuTitle(menu, "유저 도구 모음");
	AddMenuItem(menu, "HUD_AIM", hudAimOnAndOff);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);		
}

/* 유저 도구 - 메뉴 핸들러*/
public EssentialUserToolsMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "HUD_AIM")) 
			    PlayerHudAimOnAndOff(param1);
				
			EssentialUserToolsMenuCreate(param1);
		}
	}    
}