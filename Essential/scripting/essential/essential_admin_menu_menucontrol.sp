

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new String:essentialUsermenuSettingFile[PLATFORM_MAX_PATH];

stock SetControlBuildPathCreate() {
    BuildPath(Path_SM, essentialUsermenuSettingFile, PLATFORM_MAX_PATH, "data/essential/essential_setting.txt");
}

/* 어드민 유저메뉴 관리 메뉴 함수 */
public EssentialAdminUsermenuControlMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminUsermenuControlMenuHandler);
	new String:isUserTool[64];
	new String:isUserSethome[64];
	new String:isUserSendToChat[64];
	new String:isUserInvenSee[64];
	new String:isUserTeleport[64];
	
	if(EssentialSettingUsermenuControlGetFlag("user_tool"))
	    Format(isUserTool, sizeof(isUserTool), "유저 - 도구[현재 사용 가능]");
	else
	    Format(isUserTool, sizeof(isUserTool), "유저 - 도구[현재 사용 불가능]");
	
	if(EssentialSettingUsermenuControlGetFlag("user_sethome"))
	    Format(isUserSethome, sizeof(isUserSethome), "유저 - 셋홈[현재 사용 가능]");
	else 
	    Format(isUserSethome, sizeof(isUserSethome), "유저 - 셋홈[현재 사용 불가능]");

	if(EssentialSettingUsermenuControlGetFlag("user_sendtochat"))
	    Format(isUserSendToChat, sizeof(isUserSendToChat), "유저 - 귓속말[현재 사용 가능]");
	else 
	    Format(isUserSendToChat, sizeof(isUserSendToChat), "유저 - 귓속말[현재 사용 불가능]");
		
	if(EssentialSettingUsermenuControlGetFlag("user_invsee"))
	    Format(isUserInvenSee, sizeof(isUserInvenSee), "유저 - 인벤보기[현재 사용 가능]");
	else 
	    Format(isUserInvenSee, sizeof(isUserInvenSee), "유저 - 인벤보기[현재 사용 불가능]");
	
	if(EssentialSettingUsermenuControlGetFlag("user_teleport"))
	    Format(isUserTeleport, sizeof(isUserTeleport), "유저 - 텔레포트[현재 사용 가능]");
	else 
	    Format(isUserTeleport, sizeof(isUserTeleport), "유저 - 텔레포트[현재 사용 불가능]");
		
	SetMenuTitle(menu, "유저 메뉴 관리")
	AddMenuItem(menu, "USER_MENU_TOOL", isUserTool);
	AddMenuItem(menu, "USER_MENU_SETHOME", isUserSethome);
	AddMenuItem(menu, "USER_MENU_SEND_TO_CHAT", isUserSendToChat);
	AddMenuItem(menu, "USER_MENU_INVEN_SEE", isUserInvenSee);
	AddMenuItem(menu, "USER_MENU_TELEPORT", isUserTeleport);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);        
}

/* 어드민 유저메뉴 관리 - 메뉴 핸들러 */
public EssentialAdminUsermenuControlMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "USER_MENU_TOOL")) {
			    if(EssentialSettingUsermenuControlGetFlag("user_tool")) {
					EssentialSettingUsermenuControlSetFlag("user_tool", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[도구]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_tool", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[도구]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				}
			} else if(StrEqual(itemInfo, "USER_MENU_SETHOME")) {
			    if(EssentialSettingUsermenuControlGetFlag("user_sethome")) {
					EssentialSettingUsermenuControlSetFlag("user_sethome", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[셋홈]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_sethome", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[셋홈]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				}			
			} else if(StrEqual(itemInfo, "USER_MENU_SEND_TO_CHAT")) {
			    if(EssentialSettingUsermenuControlGetFlag("user_sendtochat")) {
					EssentialSettingUsermenuControlSetFlag("user_sendtochat", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[귓속말]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_sendtochat", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[귓속말]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				}			
			} else if(StrEqual(itemInfo, "USER_MENU_INVEN_SEE")) {
			    if(EssentialSettingUsermenuControlGetFlag("user_invsee")) {
					EssentialSettingUsermenuControlSetFlag("user_invsee", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[인벤보기]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_invsee", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[인벤보기]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				}			
			} else if(StrEqual(itemInfo, "USER_MENU_TELEPORT")) {
				if(EssentialSettingUsermenuControlGetFlag("user_teleport")) {
					EssentialSettingUsermenuControlSetFlag("user_teleport", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[텔레포트]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_teleport", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[텔레포트]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);				
				}
			}
			
			EssentialAdminUsermenuControlMenuCreate(param1);
		}
	}
}

stock bool:EssentialSettingUsermenuControlGetFlag(const String:flag[]) {
	new Handle:keyValue = CreateKeyValues("settings");
	
	FileToKeyValues(keyValue, essentialUsermenuSettingFile);
	KvJumpToKey(keyValue, "menucontrol");
	
	return (KvGetNum(keyValue, flag) == 1) ? true : false;
}

stock EssentialSettingUsermenuControlSetFlag(const String:flag[], bool:onAndOff) {
	new Handle:keyValue = CreateKeyValues("settings");
	
	FileToKeyValues(keyValue, essentialUsermenuSettingFile);
	KvJumpToKey(keyValue, "menucontrol");
	
	(onAndOff == true) ? KvSetString(keyValue, flag, "1") : KvSetString(keyValue, flag, "0");
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, essentialUsermenuSettingFile);
	CloseHandle(keyValue);
}

