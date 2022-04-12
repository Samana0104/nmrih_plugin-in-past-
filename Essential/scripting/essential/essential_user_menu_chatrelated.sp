
#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

#define COLOR_WHITE "FFFFFF"
#define COLOR_RED "FF4848" 
#define COLOR_ORANGE "FF8224"
#define COLOR_YELLOW "FFE400" 
#define COLOR_GREEN "7DFE74" 
#define COLOR_BLUE "6799FF"
#define COLOR_PURPLE "FF77FB"
#define COLOR_PALE_BLACK "4F4F4F"
#define COLOR_EMERALD "4FC9DE"

public EssentialUserChatRelateMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserChatRelateMenuHandler); 
	
	SetMenuTitle(menu, "채팅에 관련된 기능");
	if(IsExistPrefix(client))
		AddMenuItem(menu, "PREFIX_CORLOR", "접두사 컬러 설정");
	
	AddMenuItem(menu, "CHAT_CORLOR", "채팅 컬러 설정");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}

public EssentialUserChatRelatePrefixColorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserChatRelatePrefixColorMenuHandler); 
	
	SetMenuTitle(menu, "접두사의 컬러를 선택.");
	
	AddMenuItem(menu, COLOR_WHITE, "화이트");
	AddMenuItem(menu, COLOR_RED, "빨강");
	AddMenuItem(menu, COLOR_ORANGE, "오렌지");
	AddMenuItem(menu, COLOR_YELLOW, "노랑");
	AddMenuItem(menu, COLOR_GREEN, "초록");
	AddMenuItem(menu, COLOR_BLUE, "파랑");
	AddMenuItem(menu, COLOR_PURPLE, "보라");
	AddMenuItem(menu, COLOR_PALE_BLACK, "연한 검정");
	AddMenuItem(menu, COLOR_EMERALD, "에메랄드");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public EssentialUserChatRelateChatColorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialUserChatRelateChatColorMenuHandler); 
	
	SetMenuTitle(menu, "채팅의 컬러를 선택.");
	
	AddMenuItem(menu, COLOR_WHITE, "화이트");
	AddMenuItem(menu, COLOR_RED, "빨강");
	AddMenuItem(menu, COLOR_ORANGE, "오렌지");
	AddMenuItem(menu, COLOR_YELLOW, "노랑");
	AddMenuItem(menu, COLOR_GREEN, "초록");
	AddMenuItem(menu, COLOR_BLUE, "파랑");
	AddMenuItem(menu, COLOR_PURPLE, "보라");
	AddMenuItem(menu, COLOR_PALE_BLACK, "연한 검정");
	AddMenuItem(menu, COLOR_EMERALD, "에메랄드");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialUserChatRelateMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "PREFIX_CORLOR"))
			    EssentialUserChatRelatePrefixColorMenuCreate(param1);
			else if(StrEqual(itemInfo, "CHAT_CORLOR"))
				EssentialUserChatRelateChatColorMenuCreate(param1);
		}
	}
}

public EssentialUserChatRelatePrefixColorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialUserChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			SetPrefixColor(param1, itemInfo);
			PrintToChat(param1, "%s\x01접두사의 색깔을 선택하신 [\x07%s색깔\x01]로 설정되었습니다", ESSENTIAL_PREFIX, itemInfo);
			
			EssentialUserChatRelatePrefixColorMenuCreate(param1);
		}
	}
}

public EssentialUserChatRelateChatColorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialUserChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			SetChatColor(param1, itemInfo);
			
			PrintToChat(param1, "%s\x01채팅의 색깔을 선택하신 [\x07%s색깔\x01]로 설정되었습니다", ESSENTIAL_PREFIX, itemInfo);
			
			EssentialUserChatRelateChatColorMenuCreate(param1);
		}
	}
}