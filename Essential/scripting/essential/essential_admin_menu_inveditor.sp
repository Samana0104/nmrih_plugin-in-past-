

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

#define AMMO_9MM 1
#define AMMO_45ACP 2
#define AMMO_357 3
#define AMMO_12GAUGE 4
#define AMMO_22LR 5
#define AMMO_308 6
#define AMMO_556 7
#define AMMO_762MM 8
#define AMMO_ARROW 9
#define AMMO_BOARD 10
#define AMMO_FUEL 11
#define AMMO_FLARE 12


new playerGiveItemTarget[MAXPLAYERS+1][1]; // 인벤 에디터<아이템 주기> 메뉴창에 플레이어가 지정한 아이템 주기 대상을 저장하는 변수
new playerGiveAmmoTarget[MAXPLAYERS+1][1]; // 인벤 에디터<총알 주기> 메뉴창에 플레이어가 지정한 총알 주는 대상을 저장하는 변수

new String:weaponKrFile[PLATFORM_MAX_PATH]; // 웨폰<한글번역> 파일
new String:weaponMenuFile[PLATFORM_MAX_PATH]; // 웨폰 메뉴 파일
new String:weaponBanFile[PLATFORM_MAX_PATH]; // 웨폰 블록 파일

stock SetWeaponBuildPathFile() {
	BuildPath(Path_SM, weaponKrFile, PLATFORM_MAX_PATH, "data/essential/essential_krweapon.txt");															
	BuildPath(Path_SM, weaponMenuFile, PLATFORM_MAX_PATH, "data/essential/essential_weaponmenu.txt");
	BuildPath(Path_SM, weaponBanFile, PLATFORM_MAX_PATH, "data/essential/essential_weaponban.txt");
}

/* 어드민 인벤 에디터 메뉴 함수 */
public EssentialAdminInvenEditorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorMenuHandler);
	
	SetMenuTitle(menu, "인벤 에디터!");
	AddMenuItem(menu, "GIVE_ITEM", "해당 플레이어에게 아이템 주기");
	AddMenuItem(menu, "GIVE_AMMO", "해당 플레이어에게 총알을 주기");
	AddMenuItem(menu, "CLEAR_INVEN", "해당 플레이어의 인벤을 초기화");
	AddMenuItem(menu, "INVEN_SEE", "해당 플레이어의 인벤을 봅니다.");
	AddMenuItem(menu, "WEAPON_BAN", "서버 금지 무기로 설정할 무기를 나열함");
	AddMenuItem(menu, "ITEM_CODE", "자신의 인벤에 있는 아이템의 코드를 보여줌");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

/* 어드민 인벤 에디터 - 플레이어 아이템 주기 메뉴 함수 */
public EssentialAdminInvenEditorGiveItemMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorGiveItemMenuHandler);
	SetMenuTitle(menu, "유저 리스트(죽은사람은 뜨지 않습니다.)");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 인벤 에디터 - 아이템 리스트 메뉴 함수 */
public EssentialAdminInvenEditorGiveItemWeaponMenuCreate(client) {
	new Handle:keyValue = CreateKeyValues("weapon");
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorGiveItemWeaponMenuHandler);
	
	SetMenuTitle(menu, "%N님에게 줄 무기!", client);
	
	FileToKeyValues(keyValue, weaponMenuFile);
	if(KvGotoFirstSubKey(keyValue)) {
		new String:sectionName[64]; // 아이템 대상 찾고 그다음 나올 문장 / 라이플 / 권총 등등 띄울 변수

		do {
			KvGetSectionName(keyValue, sectionName, sizeof(sectionName));
			AddMenuItem(menu, sectionName, sectionName);		
		} while(KvGotoNextKey(keyValue));
	}
	
	CloseHandle(keyValue);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 인벤 에디터 - 아이템 리스트<무기 나열> 메뉴 함수 */
public EssentialAdminInvenEditorGiveItemWeaponListMenuCreate(client, const String:key[]) {
	new Handle:keyValue = CreateKeyValues("weapon");
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorGiveItemWeaponListMenuHandler);
	
	SetMenuTitle(menu, "%s 리스트!", key);
	
	FileToKeyValues(keyValue, weaponMenuFile);
	KvJumpToKey(keyValue, key);
	
	if(KvGotoFirstSubKey(keyValue)) {
		new String:weaponName[64]; // weapon 코드를 찾는 변수
		new String:koreanWeaponName[64]; // 그 찾은 코드를 한글로 번역해주는 변수
		
		do {
			KvGetSectionName(keyValue, weaponName, sizeof(weaponName));
			TranslateWeaponName(weaponName, koreanWeaponName, sizeof(koreanWeaponName));
			AddMenuItem(menu, weaponName, koreanWeaponName);
		} while(KvGotoNextKey(keyValue)); 	
	}
	
	CloseHandle(keyValue);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 인벤 에디터 - 플레이어 총알 주기 메뉴 함수 */
public EssentialAdminInvenEditorGiveAmmoMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorGiveAmmoMenuHandler);
	SetMenuTitle(menu, "유저 리스트(죽은사람은 뜨지 않습니다.)");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);  	
}

public EssentialAdminInvenEditorGiveAmmoListMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorGiveAmmoListMenuHandler);
	new String:ammoType9mm[4], String:ammoType45acp[4], String:ammoType357[4], String:ammoType12gauge[4], String:ammoType22lr[4], String:ammoType308[4];
	new String:ammoType556[4], String:ammoType762mm[4], String:ammoTypearrow[4], String:ammoTypeboard[4], String:ammoTypefuel[4], String:ammoTypeflare[4];
	IntToString(AMMO_9MM, ammoType9mm, sizeof(ammoType9mm));
	IntToString(AMMO_45ACP, ammoType45acp, sizeof(ammoType45acp));
	IntToString(AMMO_357, ammoType357, sizeof(ammoType357));
	IntToString(AMMO_12GAUGE, ammoType12gauge, sizeof(ammoType12gauge));
	IntToString(AMMO_22LR, ammoType22lr, sizeof(ammoType22lr));
	IntToString(AMMO_308, ammoType308, sizeof(ammoType308));
	IntToString(AMMO_556, ammoType556, sizeof(ammoType556));
	IntToString(AMMO_762MM, ammoType762mm, sizeof(ammoType762mm));
	IntToString(AMMO_ARROW, ammoTypearrow, sizeof(ammoTypearrow));
	IntToString(AMMO_BOARD, ammoTypeboard, sizeof(ammoTypeboard));
	IntToString(AMMO_FUEL, ammoTypefuel, sizeof(ammoTypefuel));
	IntToString(AMMO_FLARE, ammoTypeflare, sizeof(ammoTypeflare));
	
	
	SetMenuTitle(menu, "총알을 골라주세요 < 최대치로만 소환 가능함. >");
	AddMenuItem(menu, ammoType9mm, "9mm 탄약[10발]");
	AddMenuItem(menu, ammoType45acp, "45acp 탄약[10발]");
	AddMenuItem(menu, ammoType357, "357 탄약[12발]");
	AddMenuItem(menu, ammoType12gauge, "12gauge 탄약[10발]");
	AddMenuItem(menu, ammoType22lr, "22lr 탄약[20발]");
	AddMenuItem(menu, ammoType308, "308 탄약[10발]");
	AddMenuItem(menu, ammoType556, "5.56mm 탄약[15발]");
	AddMenuItem(menu, ammoType762mm, "7.62mm 탄약[10발]");
	AddMenuItem(menu, ammoTypearrow, "arrow 탄약[10발]");
	AddMenuItem(menu, ammoTypeboard, "board 탄약[1발]");
	AddMenuItem(menu, ammoTypefuel, "fuel 탄약[50발]");
	AddMenuItem(menu, ammoTypeflare, "flare 탄약[4발]");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}

/* 어드민 인벤 에디터 - 플레이어 인벤 초기화 메뉴 함수 */
public EssentialAdminInvenEditorClearInvenMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorClearInvenMenuHandler);
	SetMenuTitle(menu, "유저 리스트(죽은사람은 뜨지 않습니다.)");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 인벤 에디터(유저리스트) - 플레이어 인벤 보기 메뉴 함수 */
public EssentialAdminInvenEditorInvenSeeMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorInvenSeeMenuHandler);
	SetMenuTitle(menu, "인벤을 볼 대상(죽은사람은 뜨지 않습니다.)");
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex)); 
			GetClientName(i, playerName, MAX_NAME_LENGTH);
			AddMenuItem(menu, playerIndex, playerName);		    
		}
	}
	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/*어드민 인벤에디터 - 플레이어 인벤 보기 메뉴 함수 */
public EssentialAdminInvenEditorInvenSeeWeaponListMenuCreate(client, target) {
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorInvenSeeWeaponListMenuHandler);
	new weaponOffsetData;
	new String:playerActiveWeaponName[64], String:koreanWeaponName[64];
	
	SetMenuTitle(menu, "%N님의 인벤", target);
	weaponOffsetData = FindSendPropOffs("CNMRiH_Player", "m_hMyWeapons");
	
	// 자신이 들고있는 아이템을 추가시킵니다. ( 그냥 이방법없이 밑에다가 다 추가하면 한 무기가 두개씩 추가되서 보이는 오류가 발생되므로 이렇게 만듬! )
	PlayerHandEquipWeaponName(target, playerActiveWeaponName, sizeof(playerActiveWeaponName));
	TranslateWeaponName(playerActiveWeaponName, koreanWeaponName, sizeof(koreanWeaponName));
		
	AddMenuItem(menu, playerActiveWeaponName, koreanWeaponName, ITEMDRAW_DISABLED);
	
	if(weaponOffsetData != -1) { // 해당 인벤에 있는 아이템을 추가시킵니다.
		for(new i=0; i<=192; i+=4) {
			new weaponData = GetEntDataEnt2(target, weaponOffsetData + i);
						
			if(weaponData > 0) {
				new String:weaponName[64]; // 웨폰 이름을 따올 문자열을 선언합니다.
				
				GetEntityClassname(weaponData, weaponName, sizeof(weaponName)); // 해당 엔티티의 이름을 따옵니다.
				
				if(StrEqual(weaponName, "item_zippo") || StrEqual(weaponName, "me_fists"))  // 웨폰이름이 주먹 또는 라이터라면 건너뜀
					continue;
				else if(StrEqual(weaponName, playerActiveWeaponName)) // 불러온 무기의 이름이 들고있는 무기의 이름과 같을시 패스
					continue;
				
				TranslateWeaponName(weaponName, koreanWeaponName, sizeof(koreanWeaponName));	
				
				AddMenuItem(menu, weaponName, koreanWeaponName, ITEMDRAW_DISABLED);
			}
		}
	}	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 금지무기 메뉴 설정 함수 */
public EssentialAdminInvenEditorWeaponBanMenuCreate(client) {
	new Handle:keyValue = CreateKeyValues("weapon_block");
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorWeaponBanMenuHandler);

	FileToKeyValues(keyValue, weaponBanFile);
	
	if(KvGotoFirstSubKey(keyValue)) {
		new bool:isWeaponBan;
		new String:weaponName[64], String:koreanWeaponName[64], String:weaponSettingInfo[128];
				
		do {
			isWeaponBan = (KvGetNum(keyValue, "ban") == 1) ? true : false;
			
			KvGetSectionName(keyValue, weaponName, sizeof(weaponName));
			TranslateWeaponName(weaponName, koreanWeaponName, sizeof(koreanWeaponName));	
	
			if(isWeaponBan) 
				Format(weaponSettingInfo, sizeof(weaponSettingInfo), "%s[금지무기]", koreanWeaponName);
			else
				Format(weaponSettingInfo, sizeof(weaponSettingInfo), "%s[사용가능]", koreanWeaponName);
				
			AddMenuItem(menu, weaponName, weaponSettingInfo);
		} while(KvGotoNextKey(keyValue)); 
	}
	
	CloseHandle(keyValue);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);  
}

/*어드민 인벤에디터 - 자신이 소지한 아이템의 코드를 보는 메뉴 함수 */
public EssentialAdminInvenEditorInvenItemcodeMenuCreate(client) {
	new offsetData;
	new String:playerActiveWeaponName[64];
	new Handle:menu = CreateMenu(EssentialAdminInvenEditorInvenItemcodeMenuHandler);
	
	SetMenuTitle(menu, "소유하고 있는 아이템의 코드");
	
	offsetData = FindSendPropOffs("CNMRiH_Player", "m_hMyWeapons"); // 웨폰 오프셋을 얻어옵니다.
	
	// 자신이 들고있는 아이템을 추가시킵니다. ( 그냥 이방법없이 밑에다가 다 추가하면 한 무기가 두개씩 추가되서 보이는 오류가 발생되므로 이렇게 만듬! )
	PlayerHandEquipWeaponName(client, playerActiveWeaponName, sizeof(playerActiveWeaponName));	
	AddMenuItem(menu, playerActiveWeaponName, playerActiveWeaponName, ITEMDRAW_DISABLED);
	
	if(offsetData != -1) { // 해당 인벤에 있는 아이템을 추가시킵니다.
		for(new i=0; i<=192; i+=4) {
			new weaponData = GetEntDataEnt2(client, offsetData + i);
						
			if(weaponData > 0) {
				new String:weaponName[64]; // 웨폰 이름을 따올 문자열을 선언합니다.
				
				GetEntityClassname(weaponData, weaponName, sizeof(weaponName)); // 해당 엔티티의 이름을 따옵니다.
				
				if(StrEqual(weaponName, "item_zippo") || StrEqual(weaponName, "me_fists"))  // 웨폰이름이 주먹 또는 라이터라면 건너뜀
					continue;
				else if(StrEqual(weaponName, playerActiveWeaponName)) // 불러온 무기의 이름이 들고있는 무기의 이름과 같을시 패스
					continue;
							
				AddMenuItem(menu, weaponName, weaponName, ITEMDRAW_DISABLED);
			}
		}
	}

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    	
}

/*  어드민 인벤에디터 - 메뉴 핸들러 */
public EssentialAdminInvenEditorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "GIVE_ITEM"))
				EssentialAdminInvenEditorGiveItemMenuCreate(param1);
			else if(StrEqual(itemInfo, "GIVE_AMMO"))
				EssentialAdminInvenEditorGiveAmmoMenuCreate(param1);
			else if(StrEqual(itemInfo, "CLEAR_INVEN"))
				EssentialAdminInvenEditorClearInvenMenuCreate(param1);
			else if(StrEqual(itemInfo, "INVEN_SEE"))
                EssentialAdminInvenEditorInvenSeeMenuCreate(param1);
			else if(StrEqual(itemInfo, "WEAPON_BAN"))
				EssentialAdminInvenEditorWeaponBanMenuCreate(param1);
			else if(StrEqual(itemInfo, "ITEM_CODE"))
				EssentialAdminInvenEditorInvenItemcodeMenuCreate(param1);
		}
	}
}
/* 어드민 인벤에디터(아이템 주기) - 메뉴 핸들러 */
public EssentialAdminInvenEditorGiveItemMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminInvenEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
 			if(!IsClientInGame(StringToInt(itemInfo))) {//해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				SetPlayerGiveItemTarget(param1, StringToInt(itemInfo));
				EssentialAdminInvenEditorGiveItemWeaponMenuCreate(param1);
			}
		}
	}
}

/* 어드민 인벤에디터(아이템 리스트) - 메뉴 핸들러 */
public EssentialAdminInvenEditorGiveItemWeaponMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorGiveItemMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			EssentialAdminInvenEditorGiveItemWeaponListMenuCreate(param1, itemInfo); // pram1 = 대상,  itemInfo = 키밸류에서 찾을 키
		}
	}
}

/* 어드민 인벤에디터(아이템 리스트<무기 나열>) - 메뉴 핸들러 */
public EssentialAdminInvenEditorGiveItemWeaponListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorGiveItemWeaponMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			if(IsClientInGame(GetPlayerGiveItemTarget(param1)) && IsPlayerAlive(GetPlayerGiveItemTarget(param1))) {
				PlayerGiveItem(GetPlayerGiveItemTarget(param1), itemInfo);
				EssentialAdminInvenEditorGiveItemWeaponMenuCreate(param1);
			} else { 
				PrintToChat(param1, "%s\x01해당 플레이어가 존재하거나 또는 생존중이 아닙니다.", ESSENTIAL_PREFIX);   
			}
		}
	}
}

/* 어드민 인벤에디터(총알 주기) - 메뉴 핸들러 */
public EssentialAdminInvenEditorGiveAmmoMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminInvenEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
 			if(!IsClientInGame(StringToInt(itemInfo))) {//해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				SetPlayerGiveAmmoTarget(param1, StringToInt(itemInfo));
				EssentialAdminInvenEditorGiveAmmoListMenuCreate(param1);
			}
		}
	}
}

public EssentialAdminInvenEditorGiveAmmoListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialAdminInvenEditorGiveAmmoMenuCreate(param1);
		}
		
		case MenuAction_Select:
		{
			new String:itemInfo[8]; // 총알 타입
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
 			if(!GetPlayerGiveAmmoTarget(param1)) {//해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01총알을 줄 타겟이 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				PlayerGiveAmmo(GetPlayerGiveAmmoTarget(param1), StringToInt(itemInfo));
				EssentialAdminInvenEditorGiveAmmoListMenuCreate(param1);
			}			
		}
	}
}

/* 어드민 인벤에디터(인벤 초기화) - 메뉴 핸들러 */
public EssentialAdminInvenEditorClearInvenMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
 			if(!IsClientInGame(StringToInt(itemInfo))) { //해당 플레이어가 없을시
				PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);
			} else {
				new targetPlayer = StringToInt(itemInfo);
				PlayerAllRemoveItems(targetPlayer); 
				PrintToChat(targetPlayer, "%s\x01당신의 인벤이 초기화 되버렸습니다.", ESSENTIAL_PREFIX);
            }		
		}
	}
}

/* 어드민 인벤에디터(인벤보기<유저리스트>) - 메뉴 핸들러 */
public EssentialAdminInvenEditorInvenSeeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
            
			if(IsClientInGame(StringToInt(itemInfo))) 
                EssentialAdminInvenEditorInvenSeeWeaponListMenuCreate(param1, StringToInt(itemInfo));
			else
                PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);			
		}
	}
}

/* 어드민 인벤에디터(인벤보기) - 메뉴 핸들러 */
public EssentialAdminInvenEditorInvenSeeWeaponListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorInvenSeeMenuCreate(param1);
		}
	}
}

/* 금지무기 메뉴 핸들러 */
public EssentialAdminInvenEditorWeaponBanMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:weaponName[64], String:koreanWeaponName[64];
			GetMenuItem(menu, param2, weaponName, sizeof(weaponName));
			TranslateWeaponName(weaponName, koreanWeaponName, sizeof(koreanWeaponName));
			
			if(EssentialInvenEditiorWeaponBanGetFlag(weaponName, "ban")) {
				EssentialInvenEditiorWeaponBanSetFlag(weaponName, "ban", 0);
				PrintToChatAll("%s\x01%s무기는 이제부터 서버에서 사용가능 합니다.", ESSENTIAL_PREFIX, koreanWeaponName);
			} else {
				EssentialInvenEditiorWeaponBanSetFlag(weaponName, "ban", 1);
				PrintToChatAll("%s\x01%s무기는 이제부터 서버 금지무기로 설정되었습니다.", ESSENTIAL_PREFIX, koreanWeaponName);
			}
			
			EssentialAdminInvenEditorWeaponBanMenuCreate(param1);
		}
	}
}


/* 어드민 인벤에디터(아이템코드 보기) - 메뉴 핸들러 */
public EssentialAdminInvenEditorInvenItemcodeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminInvenEditorMenuCreate(param1);
		}
	}
}

stock TranslateWeaponName(const String:weaponCode[], String:koreanWeaponName[], koreanWeaponNameStr) {
	new Handle:keyValue = CreateKeyValues("weapon");
	
	FileToKeyValues(keyValue, weaponKrFile);
	KvJumpToKey(keyValue, "WeaponList");
	KvGetString(keyValue, weaponCode, koreanWeaponName, koreanWeaponNameStr);
	
	CloseHandle(keyValue);	
}

stock PlayerGiveItem(player, const String:itemName[]) {	
	new itemEntity = CreateEntityByName(itemName);
	new Float:itemSpawnPos[3], Float:itemSpawnPos2[3];
	PlayerEyeAngleFrontPosition(player, itemSpawnPos, itemSpawnPos2);
	
	if(StrEqual(itemName, "item_inventory_box"))
		itemSpawnPos[2] -= 80.0;
	else if(StrEqual(itemName, "nmrih_health_station_location"))
		itemSpawnPos[2] -= 40.0;
	else if(StrEqual(itemName, "nmrih_safezone_supply"))
		itemSpawnPos[2] -= 70.0;
		
	DispatchSpawn(itemEntity);
	TeleportEntity(itemEntity, itemSpawnPos, itemSpawnPos2, NULL_VECTOR);
	ActivateEntity(itemEntity);
}

// CItem_AmmoBox
stock PlayerGiveAmmo(player, ammoType) {
	new ammo;
	new Float:ammoSpawnPos[3];
	ammo = CreateEntityByName("random_spawner");
	
	DispatchKeyValue(ammo, "ammo_fill_pct_min", "1000000000000"); // 총알이 나올 최소 갯수
	DispatchKeyValue(ammo, "ammo_fill_pct_max", "1000000000000"); // 총알이 나올 최대 갯수
	SetEntityFlags(ammo, 2);
	
	switch(ammoType) {
		case AMMO_9MM: 
		{
			DispatchKeyValue(ammo, "ammobox_9mm", "1000000000000");
		}
		case AMMO_45ACP:
		{
			DispatchKeyValue(ammo, "ammobox_45acp", "1000000000000");
		}
		case AMMO_357:
		{
			DispatchKeyValue(ammo, "ammobox_357", "1000000000000");
		}
		case AMMO_12GAUGE:
		{
			DispatchKeyValue(ammo, "ammobox_12gauge", "1000000000000");
		}
		case AMMO_22LR:
		{
			DispatchKeyValue(ammo, "ammobox_22lr", "1000000000000");
		}
		case AMMO_308:
		{
			DispatchKeyValue(ammo, "ammobox_308", "1000000000000");
		}
		case AMMO_556:
		{
			DispatchKeyValue(ammo, "ammobox_556", "1000000000000");
		}
		case AMMO_762MM:
		{
			DispatchKeyValue(ammo, "ammobox_762mm", "1000000000000");
		}
		case AMMO_ARROW:
		{
			DispatchKeyValue(ammo, "ammobox_arrow", "1000000000000");
		}
		case AMMO_BOARD:
		{
			DispatchKeyValue(ammo, "ammobox_board", "1000000000000");
		}
		case AMMO_FUEL:
		{
			DispatchKeyValue(ammo, "ammobox_fuel", "1000000000000");
		}
		case AMMO_FLARE:
		{
			DispatchKeyValue(ammo, "ammobox_flare", "1000000000000");
		}
	}	
	
	PlayerEyeAngleFrontPosition(player, ammoSpawnPos, NULL_VECTOR);
	DispatchKeyValueVector(ammo, "Origin", ammoSpawnPos);
	DispatchSpawn(ammo);	
}

stock PlayerAllRemoveItems(target) {
	new itemZippo, weaponFists;
	new offsetData = FindSendPropOffs("CNMRiH_Player", "m_hMyWeapons"); //웨폰 오프셋을 얻어옵니다.
				
				
	if(offsetData != -1) {
		for(new i=0; i<=192; i+=4) {
			new weaponData = GetEntDataEnt2(target, offsetData + i);
						
			if(weaponData > 0) {
				new String:weaponName[64]; // 웨폰 이름을 따올 문자열을 선언합니다.
				GetEntityClassname(weaponData, weaponName, sizeof(weaponName)); // 해당 엔티티의 이름을 따옵니다.		
								
				RemovePlayerItem(target, weaponData);
				RemoveEdict(weaponData);
			}
		}
	}
	itemZippo = GivePlayerItem(target, "item_zippo");
	weaponFists = GivePlayerItem(target, "me_fists");
				
	AcceptEntityInput(itemZippo, "use", target);
	AcceptEntityInput(weaponFists, "use", target);
				
	SetEntProp(target, Prop_Send, "_carriedWeight", 0); // 플레이어의 중량을 없애버립니다.
	EquipPlayerWeapon(target, weaponFists);
}

stock PlayerHandEquipWeaponName(player, String:weaponName[], weaponStr) { // 자신이 들고있는 아이템의 이름을 불러옵니다.
	new playerActiveWeapon;
	playerActiveWeapon = GetEntPropEnt(player, Prop_Send, "m_hActiveWeapon"); // 자신이 들고있는 아이템의 값을 얻어옵니다.
	
	if(playerActiveWeapon > 0)
		GetEntityClassname(playerActiveWeapon, weaponName, weaponStr);
}

stock EssentialInvenEditiorWeaponBanGetFlag(const String:weaponName[], const String:flag[]) { // ban 플래그 반환시 1 = true 아니면 0 = false
	new Handle:keyValue = CreateKeyValues("weapon_block");
	new flagData;
	
	FileToKeyValues(keyValue, weaponBanFile);
	KvJumpToKey(keyValue, weaponName);	
	flagData = KvGetNum(keyValue, flag);
	
	CloseHandle(keyValue);
	return flagData;
}

stock EssentialInvenEditiorWeaponBanSetFlag(const String:weaponName[], const String:flag[], setFlag) { // ban 플래그 반환시 1 = true 아니면 0 = false
	new Handle:keyValue = CreateKeyValues("weapon_block");
	
	FileToKeyValues(keyValue, weaponBanFile);
	KvJumpToKey(keyValue, weaponName);	
	KvSetNum(keyValue, flag, setFlag);
	
	KvRewind(keyValue);
	KeyValuesToFile(keyValue, weaponBanFile);
	CloseHandle(keyValue);
}

public GetPlayerGiveItemTarget(client){
    return playerGiveItemTarget[client][0];
}

public GetPlayerGiveAmmoTarget(client){
    return playerGiveAmmoTarget[client][0];
}

public SetPlayerGiveItemTarget(client, target) {
    playerGiveItemTarget[client][0] = target;
}

public SetPlayerGiveAmmoTarget(client, target){
    playerGiveAmmoTarget[client][0] = target;
}

