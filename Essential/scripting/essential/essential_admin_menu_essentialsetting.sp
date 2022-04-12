

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new String:essentialFunctionSettingFile[PLATFORM_MAX_PATH];
new String:essentialUsermenuSettingFile[PLATFORM_MAX_PATH];

stock SetEssentialSettingBuildPathFile() {
	BuildPath(Path_SM, essentialFunctionSettingFile, PLATFORM_MAX_PATH, "data/essential/essential_setting.txt");
	BuildPath(Path_SM, essentialUsermenuSettingFile, PLATFORM_MAX_PATH, "data/essential/essential_setting.txt");
}

public EssentialAdminEssentialSettingMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminEssentialSettingMenuHandler);
	new String:isChatFunction[64], String:isUserTool[64], String:isUserSethome[64], String:isUserSendToChat[64], String:isUserInvenSee[64], String:isUserTeleport[64], String:isUserChatRelate[64];
	
	if(EssentialSettingFunctionGetFlag("chat_function"))
		Format(isChatFunction, sizeof(isChatFunction), "에센셜 채팅 기능[적용]");
	else
		Format(isChatFunction, sizeof(isChatFunction), "에센셜 채팅 기능[비적용]");

	if(EssentialSettingUsermenuControlGetFlag("user_tool"))
	    Format(isUserTool, sizeof(isUserTool), "유저메뉴 - 도구[현재 사용 가능]");
	else
	    Format(isUserTool, sizeof(isUserTool), "유저메뉴 - 도구[현재 사용 불가능]");
	
	if(EssentialSettingUsermenuControlGetFlag("user_sethome"))
	    Format(isUserSethome, sizeof(isUserSethome), "유저메뉴 - 셋홈[현재 사용 가능]");
	else 
	    Format(isUserSethome, sizeof(isUserSethome), "유저메뉴 - 셋홈[현재 사용 불가능]");

	if(EssentialSettingUsermenuControlGetFlag("user_sendtochat"))
	    Format(isUserSendToChat, sizeof(isUserSendToChat), "유저메뉴 - 귓속말[현재 사용 가능]");
	else 
	    Format(isUserSendToChat, sizeof(isUserSendToChat), "유저메뉴 - 귓속말[현재 사용 불가능]");
		
	if(EssentialSettingUsermenuControlGetFlag("user_invsee"))
	    Format(isUserInvenSee, sizeof(isUserInvenSee), "유저메뉴 - 인벤보기[현재 사용 가능]");
	else 
	    Format(isUserInvenSee, sizeof(isUserInvenSee), "유저메뉴 - 인벤보기[현재 사용 불가능]");
	
	if(EssentialSettingUsermenuControlGetFlag("user_teleport"))
	    Format(isUserTeleport, sizeof(isUserTeleport), "유저메뉴 - 텔레포트[현재 사용 가능]");
	else 
	    Format(isUserTeleport, sizeof(isUserTeleport), "유저메뉴 - 텔레포트[현재 사용 불가능]");

	if(EssentialSettingUsermenuControlGetFlag("user_chatrelated"))
	    Format(isUserChatRelate, sizeof(isUserChatRelate), "유저메뉴 - 채팅 관련 설정[현재 사용 가능]");
	else 
	    Format(isUserChatRelate, sizeof(isUserChatRelate), "유저메뉴 - 채팅 관련 설정[현재 사용 불가능]");

		
	SetMenuTitle(menu, "에센셜 설정 메뉴") ;
	AddMenuItem(menu, "CHAT_FUNCTION", isChatFunction);
	AddMenuItem(menu, "USER_MENU_TOOL", isUserTool);
	AddMenuItem(menu, "USER_MENU_SETHOME", isUserSethome);
	AddMenuItem(menu, "USER_MENU_SEND_TO_CHAT", isUserSendToChat);
	AddMenuItem(menu, "USER_MENU_INVEN_SEE", isUserInvenSee);
	AddMenuItem(menu, "USER_MENU_TELEPORT", isUserTeleport);
	AddMenuItem(menu, "USER_MENU_CHATRELATE", isUserChatRelate);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminEssentialSettingMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "CHAT_FUNCTION")) {
				if(EssentialSettingFunctionGetFlag("chat_function")) {
					EssentialSettingFunctionSetFlag("chat_function", false);
					PrintToChat(param1, "%s\x07FF4848[주의]\x01채팅 관련 기능을 껏습니다. 이 경우 AllChat 플러그인을 넣어주셔야 죽어도 채팅이 보이며\n에센셜에 있는 채팅에 관련된 기능은 사용하실수 없습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingFunctionSetFlag("chat_function", true);
					PrintToChat(param1, "%s\x01채팅 관련 기능을 켰습니다.", ESSENTIAL_PREFIX);
				}
			} else if(StrEqual(itemInfo, "USER_MENU_TOOL")) {
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
			} else if(StrEqual(itemInfo, "USER_MENU_CHATRELATE")) {
				if(EssentialSettingUsermenuControlGetFlag("user_chatrelated")) {
					EssentialSettingUsermenuControlSetFlag("user_chatrelated", false);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[채팅 관련 설정]를 사용 불가능하게 만들었습니다.", ESSENTIAL_PREFIX);
				} else {
					EssentialSettingUsermenuControlSetFlag("user_chatrelated", true);
					PrintToChatAll("%s\x01어드민이 에센셜 유저메뉴[채팅 관련 설정]를 사용 가능하게 만들었습니다.", ESSENTIAL_PREFIX);				
				}			
			}
			
			EssentialAdminEssentialSettingMenuCreate(param1);
		}
	}
}

stock EssentialSettingFunctionGetFlag(const String:flag[]) { // 반환시 1 = true 아니면 0 = false
	new Handle:keyValue = CreateKeyValues("settings");
	new flagData;
	
	FileToKeyValues(keyValue, essentialFunctionSettingFile);
	KvJumpToKey(keyValue, "essential");
	
	flagData = KvGetNum(keyValue, flag);
	CloseHandle(keyValue);
	return flagData
}

stock EssentialSettingUsermenuControlGetFlag(const String:flag[]) { // 반환시 1 = true 아니면 0 = false
	new Handle:keyValue = CreateKeyValues("settings");
	new flagData;
	
	FileToKeyValues(keyValue, essentialUsermenuSettingFile);
	KvJumpToKey(keyValue, "menucontrol");
	
	flagData = KvGetNum(keyValue, flag);
	CloseHandle(keyValue);
	return flagData
}

stock EssentialSettingFunctionSetFlag(const String:flag[], bool:onAndOff) {
	new Handle:keyValue = CreateKeyValues("settings");
	
	FileToKeyValues(keyValue, essentialFunctionSettingFile);
	KvJumpToKey(keyValue, "essential");
	
	(onAndOff == true) ? KvSetString(keyValue, flag, "1") : KvSetString(keyValue, flag, "0");
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, essentialFunctionSettingFile);
	CloseHandle(keyValue);
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