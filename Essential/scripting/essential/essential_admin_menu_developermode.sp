

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new String:offsetInCodeFile[PLATFORM_MAX_PATH]; // 오프셋 적는 파일

stock SetDevelopModeBuildPathFile() {
	BuildPath(Path_SM, offsetInCodeFile, PLATFORM_MAX_PATH, "data/essential/essential_developmod.txt");
}

public EssentialAdminDevelopModeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminDevelopModeMenuHandler);
	
	SetMenuTitle(menu, "개발자 모드 < 오프셋 값을 알아내자 >");
	AddMenuItem(menu, "VIEW_TARGET_OFFSET", "에임에 보인 오브젝트의 오프셋 값을 보여줍니다.");
	AddMenuItem(menu, "VIEW_MY_OFFSET", "자신에 대한 오프셋 값을 보여줍니다.");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	PrintToChat(client, "%s\x01이 기능은 따로 essential_developmod.txt를 건드려 줘야 작동됩니다.", ESSENTIAL_PREFIX);
}

/*
밑 함수에 관해서.

	"my_offset"
	{
		"fl_stamina"
		{
			"name" "스태미나"
			"type" "float"
		}
	}
	
	name은 자유
	type 종류 : int, float
*/
public EssentialAdminDevelopModeViewMyOffsetMenuCreate(client) {
	new Handle:keyValue = CreateKeyValues("viewoffset");
	new Handle:menu = CreateMenu(EssentialAdminDevelopModeViewMyOffsetMenuHandler);
	
	SetMenuTitle(menu, "불러온 오프셋 값들");

	FileToKeyValues(keyValue, offsetInCodeFile);
	KvJumpToKey(keyValue, "my_offset");

	if(KvGotoFirstSubKey(keyValue)) {
		new String:offsetCode[32], String:offsetName[32], String:type[8], String:offsetInfo[64];
		new value1 = 0;
		new Float:value2 = 0.0;
		
		do {
			KvGetSectionName(keyValue, offsetCode, sizeof(offsetCode));
			KvGetString(keyValue, "name", offsetName, sizeof(offsetName));
			KvGetString(keyValue, "type", type, sizeof(type));
			
			if(StrEqual(type, "int", false)) {
				value1 = GetEntProp(client, Prop_Send, offsetCode);
				Format(offsetInfo, sizeof(offsetInfo), "%s - [값 : %d]", offsetName, value1);
			} else if(StrEqual(type, "float", false)) {
				value2 = GetEntPropFloat(client, Prop_Send, offsetCode);
				Format(offsetInfo, sizeof(offsetInfo), "%s - [값 : %f]", offsetName, value2);				
			} 
			
			AddMenuItem(menu, "", offsetInfo, ITEMDRAW_DISABLED);
		} while(KvGotoNextKey(keyValue));
		
	} else {
		PrintToChat(client, "%s\x01텍스트 파일에 등록시킨 오프셋이 존재하지 않습니다.", ESSENTIAL_PREFIX);
	}
	
	KvRewind(keyValue);
	CloseHandle(keyValue);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminDevelopModeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "VIEW_TARGET_OFFSET"))
			    PrintToChat(param1, "%s\x01기능 준비중.", ESSENTIAL_PREFIX);
			else if(StrEqual(itemInfo, "VIEW_MY_OFFSET"))
			    EssentialAdminDevelopModeViewMyOffsetMenuCreate(param1);			
		}
	}
}

public EssentialAdminDevelopModeViewMyOffsetMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminDevelopModeMenuCreate(param1);
		}
	}
}