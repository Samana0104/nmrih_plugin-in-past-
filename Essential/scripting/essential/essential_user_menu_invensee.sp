

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

/* 유저 인벤보기(유저리스트)  메뉴 함수 */
public EssentialUserInvenSeeMenuCreate(client) {
	new String:playerName[MAX_NAME_LENGTH];
	new String:playerIndex[4];    
	
	new Handle:menu = CreateMenu(EssentialUserInvenSeeMenuHandler);
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

/* 유저 인벤보기 메뉴 함수 */
public EssentialUserInvenSeeWeaponListMenuCreate(client, target) {
	new Handle:menu = CreateMenu(EssentialUserInvenSeeWeaponListMenuHandler);
	new weaponOffsetData;
	new String:playerActiveWeaponName[64], String:koreanWeaponName[64];
	
	SetMenuTitle(menu, "%N님의 인벤", target);
	
	weaponOffsetData = FindSendPropOffs("CNMRiH_Player", "m_hMyWeapons"); // 웨폰 오프셋을 얻어옵니다.
	
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

/* 유저 인벤 보기 - 메뉴 핸들러 */
public EssentialUserInvenSeeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
            
			if(IsClientInGame(StringToInt(itemInfo))) 
                EssentialUserInvenSeeWeaponListMenuCreate(param1, StringToInt(itemInfo));
			else
                PrintToChat(param1, "%s\x01해당 플레이어는 존재하지 않습니다.", ESSENTIAL_PREFIX);			
		}
	}
}

/* 유저 인벤 보기<아이템 리스트> - 메뉴 핸들러 */
public EssentialUserInvenSeeWeaponListMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	switch(action) {
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				EssentialUserInvenSeeMenuCreate(param1);
		}
	}
}