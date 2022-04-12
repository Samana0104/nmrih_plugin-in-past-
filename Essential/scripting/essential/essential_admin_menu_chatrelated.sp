

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

#define NMRIH_MAX_PLAYERS 8

new String:chatRelateFile[PLATFORM_MAX_PATH]; // 채팅 관련 파일.
new String:playerChatColor[NMRIH_MAX_PLAYERS+1][16];

new bool:prefixSetting[NMRIH_MAX_PLAYERS+1] = { false, ... };
new prefixTarget[NMRIH_MAX_PLAYERS+1][1];

new String:playerPrefix[NMRIH_MAX_PLAYERS+1][32];
new String:playerPrefixColor[NMRIH_MAX_PLAYERS+1][16];

stock SetChatReladtedBuildPathFile() {
	BuildPath(Path_SM, chatRelateFile, PLATFORM_MAX_PATH, "data/essential/essential_chatrelated.txt");
}

public EssentialAdminChatRelateMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminChatRelateMenuHandler); 
	
	SetMenuTitle(menu, "채팅에 관련된 기능");
	AddMenuItem(menu, "ADD_PREFIX", "[접속중인 유저만]접두사 추가");
	AddMenuItem(menu, "DELETE_PREFIX", "[접속중인 유저만]접두사 삭제");
	
	if(IsExistPrefix(client))
		AddMenuItem(menu, "PREFIX_CORLOR", "[자신만]접두사 컬러 설정");
	
	AddMenuItem(menu, "CHAT_CORLOR", "[자신만]채팅 컬러 설정");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminChatRelateAddPrefixMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminChatRelateAddPrefixMenuHandler); 
	
	SetMenuTitle(menu, "접두사를 설정시킬 타겟");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i)) {			
			new String:playerName[MAX_NAME_LENGTH], String:targetIntToString[4];
			
			GetClientName(i, playerName, sizeof(playerName));
			IntToString(i, targetIntToString, sizeof(targetIntToString));
			AddMenuItem(menu, targetIntToString, playerName);
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminChatRelateDeletePrefixMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminChatRelateDeletePrefixMenuHandler); 
	
	SetMenuTitle(menu, "접두사를 삭제시킬 플레이터 선택");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i)) {
			if(IsExistPrefix(i)) {
				new String:prefixInfo[128], String:prefix[32], String:targetIntToString[4];
				
				LoadPrefix(i, prefix, sizeof(prefix));
				IntToString(i, targetIntToString, sizeof(targetIntToString));
				Format(prefixInfo, sizeof(prefixInfo), "%N[접두사:%s]", i, prefix);
				
				AddMenuItem(menu, targetIntToString, prefixInfo);
			}
		}
	}
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminChatRelatePrefixColorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminChatRelatePrefixColorMenuHandler); 
	
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

public EssentialAdminChatRelateChatColorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminChatRelateChatColorMenuHandler); 
	
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

public EssentialAdminChatRelateMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "ADD_PREFIX")) 
			    EssentialAdminChatRelateAddPrefixMenuCreate(param1);
			else if(StrEqual(itemInfo, "DELETE_PREFIX"))
			    EssentialAdminChatRelateDeletePrefixMenuCreate(param1);
			else if(StrEqual(itemInfo, "PREFIX_CORLOR"))
			    EssentialAdminChatRelatePrefixColorMenuCreate(param1);
			else if(StrEqual(itemInfo, "CHAT_CORLOR"))
				EssentialAdminChatRelateChatColorMenuCreate(param1);
		}
	}
}

public EssentialAdminChatRelateAddPrefixMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new playerPrefixTarget;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			playerPrefixTarget = StringToInt(itemInfo);
			
			if(IsClientInGame(playerPrefixTarget)) {
				SetPrefixSetting(param1, true);
				SetPrefixTarget(param1, playerPrefixTarget);
				PrintToChat(param1, "%s\x01%N님의 설정할 접두사의 이름을 채팅으로 쳐주세요. < 너무길시 접두사가 짤림 >", ESSENTIAL_PREFIX, playerPrefixTarget);
			} else {
				PrintToChat(param1, "%s\x01해당 타겟은 접속중이 아닙니다.");
			}
		}
	}
}

public EssentialAdminChatRelateDeletePrefixMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new playerPrefixTarget;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			playerPrefixTarget = StringToInt(itemInfo);
			
			if(IsClientInGame(playerPrefixTarget)) {
				DeletePrefix(playerPrefixTarget);
				PrintToChat(param1, "%s\x01%N님의 접두사를 삭제시켰습니다.", ESSENTIAL_PREFIX, playerPrefixTarget);
				PrintToChat(playerPrefixTarget, "%s\x01당신의 접두사는 삭제되었습니다.", ESSENTIAL_PREFIX);
			} else {
				PrintToChat(param1, "%s\x01해당 타겟은 접속중이 아닙니다.");
			}
			
			EssentialAdminChatRelateMenuCreate(param1);
		}
	}
}

public EssentialAdminChatRelatePrefixColorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			SetPrefixColor(param1, itemInfo);
			PrintToChat(param1, "%s\x01접두사의 색깔을 선택하신 [\x07%s색깔\x01]로 설정되었습니다", ESSENTIAL_PREFIX, itemInfo);
			
			EssentialAdminChatRelatePrefixColorMenuCreate(param1);
		}
	}
}

public EssentialAdminChatRelateChatColorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminChatRelateMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			SetChatColor(param1, itemInfo);
			
			PrintToChat(param1, "%s\x01채팅의 색깔을 선택하신 [\x07%s색깔\x01]로 설정되었습니다", ESSENTIAL_PREFIX, itemInfo);
			
			EssentialAdminChatRelateChatColorMenuCreate(param1);
		}
	}
}

public AddPrefixPlayer(player, const String:prefix[]) {	// 접두사를 추가시킵니다.
	new String:playerAccount[32], String:playerName[MAX_NAME_LENGTH];
	new Handle:keyValue = CreateKeyValues("chat_relate");

	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	GetClientName(player, playerName, sizeof(playerName));
	
	KvJumpToKey(keyValue, playerAccount, true);
	KvSetString(keyValue, "name", playerName); 
	KvSetString(keyValue, "prefix", prefix);
	KvSetString(keyValue, "prefix_color", "FFFFFF"); 
	
	/*else {
		KvSetString(keyValue, "name", playerName);
		KvSetString(keyValue, "prefix", prefix);	
		KvSetString(keyValue, "prefix_color", "FFFFFF"); 
	}
	*/
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, chatRelateFile);
	CloseHandle(keyValue);
	
	Format(playerPrefix[player], 32, prefix);
}

public SetPrefixColor(player, const String:color[]) {	// 접두사의 컬러를 설정
	new String:playerAccount[32];
	new Handle:keyValue = CreateKeyValues("chat_relate");

	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	KvJumpToKey(keyValue, playerAccount);
	KvSetString(keyValue, "prefix_color", color); 
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, chatRelateFile);
	CloseHandle(keyValue);
	
	Format(playerPrefixColor[player], 16, color);
}

public SetChatColor(player, const String:color[]) {	// 채팅의 컬러를 설정
	Format(playerChatColor[player], 16, "%s", color);
}

public DeletePrefix(player) { // 접두사를 가진 플레이어를 삭제합니다.
	new String:playerAccount[32];
	new Handle:keyValue = CreateKeyValues("chat_relate");
	 
	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	KvJumpToKey(keyValue, playerAccount)
	KvDeleteThis(keyValue);
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, chatRelateFile);
	CloseHandle(keyValue);

	Format(playerPrefix[player], 32, "");    
}

public LoadPrefix(player, String:prefix[], prefixStringSize) { //접두사를 불러옵니다.
	new String:playerAccount[32];
	new Handle:keyValue = CreateKeyValues("chat_relate");
	
	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	if(KvJumpToKey(keyValue, playerAccount)) {
		KvGetString(keyValue, "prefix", prefix, prefixStringSize);
	} else {
		Format(prefix, prefixStringSize, "");
	}
	CloseHandle(keyValue);
}

public LoadPrefixColor(player, String:color[], colorStringSize) { //접두사를 불러옵니다.
	new String:playerAccount[32];
	new Handle:keyValue = CreateKeyValues("chat_relate");
	
	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	if(KvJumpToKey(keyValue, playerAccount)) {
		KvGetString(keyValue, "prefix_color", color, colorStringSize);
	} else {
		Format(color, colorStringSize, "FFFFFF"); // 컬러채팅에 등록 안되어있을시 색깔 하얀색 반환
	}
	
	CloseHandle(keyValue);
}

public LoadChatColor(player, String:color[], colorStringSize) { //접두사를 불러옵니다.
	Format(color, colorStringSize, "%s", playerChatColor[player]);
}

public bool:IsExistPrefix(player) {
	new String:playerAccount[32];
	new Handle:keyValue = CreateKeyValues("chat_relate");
	
	FileToKeyValues(keyValue, chatRelateFile);
	GetClientAuthId(player, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	if(KvJumpToKey(keyValue, playerAccount)) {
		CloseHandle(keyValue);
		return true;
	} else {
		CloseHandle(keyValue);
		return false;
	}
}

public bool:IsPrefixSetting(client) {
	return prefixSetting[client];
}

public GetPrefixTarget(client) {
	return prefixTarget[client][0];
}

public SetPrefixSetting(client, bool:onAndOff) {
	prefixSetting[client] = onAndOff;
}

public SetPrefixTarget(client, target) {
	prefixTarget[client][0] = target;
}