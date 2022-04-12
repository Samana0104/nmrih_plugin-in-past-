

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

/* type = AdminId */
new AdminId:playerAdminIdList[MAXPLAYERS+1]; // 임시어드민

new String:permissionFile[PLATFORM_MAX_PATH]; // 에센셜 권한 파일 ( 어드민 설정 사용 및 어드민이 아니라도 어드민 메뉴를 열수있음! )
new String:serverAdminFile[PLATFORM_MAX_PATH];

stock SetPermissionBuildPathFile() {
	BuildPath(Path_SM, permissionFile, PLATFORM_MAX_PATH, "data/essential/essential_permission.txt");
	BuildPath(Path_SM, serverAdminFile, PLATFORM_MAX_PATH, "configs/admins.cfg");
}

/* 어드민 설정(추가, 삭제) 메뉴 함수 */
public EssentialAdminAdmSettingMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminAdmSettingMenuHandler);
	SetMenuTitle(menu, "어드민 설정");
	AddMenuItem(menu, "ADD_FAKE_ADMIN", "임시적으로 어드민 권한 추가");
	AddMenuItem(menu, "DELETE_FAKE_ADMIN", "임시적으로 어드민 권한 삭제");
	AddMenuItem(menu, "ADD_ADMIN", "어드민 권한 추가 <admin.cfg에 기록됩니다>");
	AddMenuItem(menu, "DELETE_ADMIN", "어드민 권한 삭제 <admin.cfg에 삭제됩니다>");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	PrintToChat(client, "%s\x07FF4848[주의]\x01어드민 권한 추가 및 삭제 기능을 쓸시 에센셜로 추가한 어드민이 아닌 직접 텍스트로 기록한 어드민일시 기록이 삭제됩니다. < \"Admins\" 내부 기록은 제외 >", ESSENTIAL_PREFIX);
}

/* 어드민 설정 - 임시어드민 추가 메뉴 함수 */
public EssentialAdminAdmSettingAddFakeAdminMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4]; 
	 
	new Handle:menu = CreateMenu(EssentialAdminAdmSettingAddFakeAdminMenuHandler);
	SetMenuTitle(menu, "유저 리스트");
	
	for(new i=1; i<=GetMaxClients(); i++) { // 플레이어 리스트를 메뉴에 등록		
		if(IsClientInGame(i)) { 
			if(IsPlayerAdmin(i)) // 어드민일시 메뉴에 등록을 안시킵니다.
				continue;
			
			IntToString(i, playerIndex, sizeof(playerIndex)); // 이부분에 더 추가할게 있으니 나중에 참조
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);
			
		    /* 1. S 
			    2. Sim
			    3. SimSim 처럼 플레이어들이 메뉴에 등록되는 문장 
			 */
		}
	}
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

/* 어드민 설정 - 임시어드민 삭제 메뉴 함수 */
public EssentialAdminAdmSettingDeleteFakeAdminMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];
	
	new Handle:menu = CreateMenu(EssentialAdminAdmSettingDeleteFakeAdminMenuHandler);
	SetMenuTitle(menu, "임시 어드민 리스트");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i)) {
			if(!IsPlayerAdmin(i)) // 플레이어가 어드민이 아닐시 메뉴등록을 안시킵니다.
				continue;		
			else if(GetUserAdmin(i) != GetPlayerAdminIdList(i)) 	// admin.cfg 파일에 등록된 어드민이라면 제외
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

public EssentialAdminAdmSettingAddAdminMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4]; 
	 
	new Handle:menu = CreateMenu(EssentialAdminAdmSettingAddAdminMenuHandler);
	SetMenuTitle(menu, "유저 리스트 <텍스트에 추가된 어드민이라면 제외>");
	
	for(new i=1; i<=GetMaxClients(); i++) { 		
		if(IsClientInGame(i)) { 
			if(IsExistAdminFilePlayer(i)) 
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

public EssentialAdminAdmSettingDeleteAdminMenuCreate(client) {
	new Handle:keyValue = CreateKeyValues("Admins");
	new Handle:menu = CreateMenu(EssentialAdminAdmSettingDeleteAdminMenuHandler);
	
	SetMenuTitle(menu, "에센셜로 추가한 어드민 리스트");
	
	FileToKeyValues(keyValue, serverAdminFile);
	
	if(KvGotoFirstSubKey(keyValue)) {
		new String:sectionName[32], String:playerName[MAX_NAME_LENGTH];

		do {
			KvGetSectionName(keyValue, sectionName, sizeof(sectionName));
			KvGetString(keyValue, "name", playerName, sizeof(playerName));
			
			AddMenuItem(menu, sectionName, playerName);		
		} while(KvGotoNextKey(keyValue));
	}
	
	CloseHandle(keyValue);
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}

/* 어드민 설정 - 메뉴 핸들러 */
public EssentialAdminAdmSettingMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "ADD_FAKE_ADMIN")) 
			    EssentialAdminAdmSettingAddFakeAdminMenuCreate(param1);
			else if(StrEqual(itemInfo, "DELETE_FAKE_ADMIN")) 
			    EssentialAdminAdmSettingDeleteFakeAdminMenuCreate(param1);
			else if(StrEqual(itemInfo, "ADD_ADMIN"))
				EssentialAdminAdmSettingAddAdminMenuCreate(param1);
			else if(StrEqual(itemInfo, "DELETE_ADMIN"))
				EssentialAdminAdmSettingDeleteAdminMenuCreate(param1);
		}
	}
}

/* 어드민 설정(임시어드민 추가) - 메뉴 핸들러 */
public EssentialAdminAdmSettingAddFakeAdminMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
	    {
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminAdmSettingMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			new target;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(!IsClientInGame(target)) { //해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else { 
				FakeAdminAddPlayer(target);
				PrintToChat(param1, "%s\x01%N님에게 임시 어드민을 부여했습니다.", ESSENTIAL_PREFIX, target);
				PrintToChat(target, "%s\x01당신은 임시 어드민을 부여받았습니다. <맵 체인지시 사라짐>", ESSENTIAL_PREFIX);
			}
		}
	}
}

/* 어드민 설정(임시어드민 삭제) - 메뉴 핸들러 */
public EssentialAdminAdmSettingDeleteFakeAdminMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminAdmSettingMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			new target;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(!IsClientInGame(target)) {
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				FakeAdminDeletePlayer(target);
				PrintToChat(param1, "%s\x01%N님의 임시 어드민 권한을 제거하셨습니다.", ESSENTIAL_PREFIX, target); 
				PrintToChat(target, "%s\x01당신의 임시 어드민 권한은 빼앗기셨습니다.", ESSENTIAL_PREFIX);   
			}	 
		}
	}
}

public EssentialAdminAdmSettingAddAdminMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
	    {
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminAdmSettingMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[4];
			new targetPlayer;
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			targetPlayer = StringToInt(itemInfo);
			
			if(!IsClientInGame(targetPlayer)) {
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else { 
				AdminAddPlayer(targetPlayer);
				PrintToChat(targetPlayer, "%s\x01당신은 어드민 권한을 가지게 되었습니다. < 다음맵부터 적용 >", ESSENTIAL_PREFIX);
			}
		}
	}
}

public EssentialAdminAdmSettingDeleteAdminMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
	    {
			CloseHandle(menu);
		}
		
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminAdmSettingMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			AdminDeletePlayer(itemInfo);
			PrintToChat(param1, "%s\x01[%s]로 기록된 스팀 아이디를 삭제하였습니다.", ESSENTIAL_PREFIX, itemInfo);
		}
	}
}
/* 해당플레이어에게 임시적으로 어드민을 주는 함수  */
public FakeAdminAddPlayer(client) {
	SetPlayerAdminIdList(client, CreateAdmin());
	SetAdminFlag(GetPlayerAdminIdList(client), Admin_Root, true); // 임시어드민을 Admin_Root 로 권한을 줍니다(최고 권한)
	/* 혹시 어드민 최상위권 레벨을 주는게 불만있으시면 밑에 참조하셔서 권한 레벨을 수정하시면 됩니다.
	Admin_Generic 
	Admin_Kick				
	Admin_Ban			
	Admin_Unban,			
	Admin_Slay,				
	Admin_Changemap,		
	Admin_Convars,			
	Admin_Config,			
	Admin_Chat,				
	Admin_Vote,				
	Admin_RCON,				
	Admin_Cheats,			
	Admin_Root = 최상위권 권한
	*/
	SetUserAdmin(client, GetPlayerAdminIdList(client));
}

/* 어드민을 지급받은 해당플레이어의 어드민을 뺏는 함수(client1 = 타겟으로 지정한 클라이언트 client2 = 명령어를 시전한 클라이언트) true = 뺏기완료 / false = 실패 */
stock FakeAdminDeletePlayer(client) {	
	if(IsAimShot(client))
	    PlayerAimShotOnAndOff(client);
	
	if(IsPlayerAdminChat(client))
		SetPlayerAdminChat(client, false);
	
	RemoveAdmin(GetPlayerAdminIdList(client));
}

/* 플레이어가 어드민일시 true 아닐시 fasle */
stock bool:IsPlayerAdmin(client) {
	if(GetUserAdmin(client) != INVALID_ADMIN_ID) 
		return true;
	else 
		return false;
}

stock bool:IsPlayerEssentialPermission(client) {
	new String:playerAccount[32];
	new bool:existPermission;
	new Handle:keyValue = CreateKeyValues("Permission");
	 
	FileToKeyValues(keyValue, permissionFile);
	GetClientAuthId(client, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	if(KvJumpToKey(keyValue, playerAccount)) 
		existPermission = true;
	else 
		existPermission = false;
	
	
	CloseHandle(keyValue);
	return existPermission;
}

stock bool:IsExistAdminFilePlayer(client) {
	new Handle:keyValue = CreateKeyValues("Admins");
	new String:playerAccount[32];
	new bool:existAdmin;
	
	FileToKeyValues(keyValue, serverAdminFile);
	GetClientAuthId(client, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	
	if(KvJumpToKey(keyValue, playerAccount))
		existAdmin = true;
	else
		existAdmin = false;
	
	CloseHandle(keyValue);
	return existAdmin;
}

stock AdminAddPlayer(client) {
	new String:playerAccount[32], String:playerName[MAX_NAME_LENGTH];
	new Handle:keyValue = CreateKeyValues("Admins");
	
	FileToKeyValues(keyValue, serverAdminFile);
	GetClientAuthId(client, AuthId_Steam2, playerAccount, sizeof(playerAccount));
	GetClientName(client, playerName, sizeof(playerName));
	
	KvJumpToKey(keyValue, playerAccount, true);
	
	KvSetString(keyValue, "name", playerName);
	KvSetString(keyValue, "auth", "steam");
	KvSetString(keyValue, "identity", playerAccount);
	KvSetString(keyValue, "flags", "z");
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, serverAdminFile);
	CloseHandle(keyValue);
}

stock AdminDeletePlayer(String:playerAccount[]) {
	new Handle:keyValue = CreateKeyValues("Admins");
	
	FileToKeyValues(keyValue, serverAdminFile);
	KvJumpToKey(keyValue, playerAccount, true);
	KvDeleteThis(keyValue);
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, serverAdminFile);
	CloseHandle(keyValue);	
}

public AdminId:GetPlayerAdminIdList(client) {
    return playerAdminIdList[client];
}

public AdminId:SetPlayerAdminIdList(client, AdminId:id) {
    return playerAdminIdList[client] = id;
}
