

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new bool:playerBhop[MAXPLAYERS+1] = { false, false, ...};

public EssentialAdminPlayerStateChangeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminPlayerStateChangeMenuHandler);
	
	SetMenuTitle(menu, "플레이어의 상태를 설정합니다.");
	
	AddMenuItem(menu, "PLAYER_INFECT", "플레이어를 감염시키거나 해제합니다.");
	AddMenuItem(menu, "PLAYER_BLEEDING", "플레이어의 출혈을 조정합니다. < 출혈률 낮은 서버 주의 >");
	AddMenuItem(menu, "PLAYER_VACCINER", "플레이어의 감염 면역을 조정합니다.");
	AddMenuItem(menu, "PLAYER_BUNNYHOP", "플레이어의 버니합을 설정합니다.");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 	
}

public EssentialAdminPlayerStateChangePlayerInfectMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminPlayerStateChangePlayerInfectMenuHandler);
	new String:checkInfectPlayer[64], String:playerIndex[4];
	
	SetMenuTitle(menu, "플레이어의 감염을 설정합니다. < 감염 면역이 있을시 제외 >");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i) && !IsPlayerVaccinatedCheck(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex));
			
			if(IsPlayerInfectCheck(i)) {
				Format(checkInfectPlayer, sizeof(checkInfectPlayer), "[%N][감염]", i);
				AddMenuItem(menu, playerIndex, checkInfectPlayer);
			} else {
				Format(checkInfectPlayer, sizeof(checkInfectPlayer), "[%N][감염 아님]", i);
				AddMenuItem(menu, playerIndex, checkInfectPlayer);
			}
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminPlayerStateChangePlayerVaccinerMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminPlayerStateChangePlayerVaccinerMenuHandler);
	new String:checkBleedingPlayer[64], String:playerIndex[4];
	
	SetMenuTitle(menu, "플레이어의 감염 면역을 설정합니다.");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex));
			
			if(IsPlayerVaccinatedCheck(i)) {
				Format(checkBleedingPlayer, sizeof(checkBleedingPlayer), "[%N][면역]", i);
				AddMenuItem(menu, playerIndex, checkBleedingPlayer);
			} else {
				Format(checkBleedingPlayer, sizeof(checkBleedingPlayer), "[%N][면역 아님]", i);
				AddMenuItem(menu, playerIndex, checkBleedingPlayer);
			}
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminPlayerStateChangePlayerBleedingMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminPlayerStateChangePlayerBleedingMenuHandler);
	new String:checkBleedingPlayer[64], String:playerIndex[4];
	
	SetMenuTitle(menu, "플레이어의 출혈을 설정합니다.");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex));
			
			if(IsPlayerBleedingCheck(i)) {
				Format(checkBleedingPlayer, sizeof(checkBleedingPlayer), "[%N][출혈]", i);
				AddMenuItem(menu, playerIndex, checkBleedingPlayer);
			} else {
				Format(checkBleedingPlayer, sizeof(checkBleedingPlayer), "[%N][출혈 아님]", i);
				AddMenuItem(menu, playerIndex, checkBleedingPlayer);
			}
		}
	}
	
	// PrintToChat(client, "%s\x07FF4848[주의]\x01출혈률이 0퍼인 서버에서 쓰시면 어떻게 될지 장담하실수 없습니다.", ESSENTIAL_PREFIX);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminPlayerStateChangePlayerBunnyHopMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminPlayerStateChangePlayerBunnyHopMenuHandler);
	new String:isBhop[64], String:playerIndex[4];
	
	SetMenuTitle(menu, "플레이어의 버니합을 설정합니다. <죽은사람 안뜸>");
	
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) {
			IntToString(i, playerIndex, sizeof(playerIndex));
			
			if(IsPlayerBhop(i)) {
				Format(isBhop, sizeof(isBhop), "[%N][버니합O]", i);
				AddMenuItem(menu, playerIndex, isBhop);
			} else {
				Format(isBhop, sizeof(isBhop), "[%N][버니합X]", i);
				AddMenuItem(menu, playerIndex, isBhop);
			}
		}
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER); 
}

public EssentialAdminPlayerStateChangeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "PLAYER_INFECT"))
				EssentialAdminPlayerStateChangePlayerInfectMenuCreate(param1);
			else if(StrEqual(itemInfo, "PLAYER_VACCINER"))
				EssentialAdminPlayerStateChangePlayerVaccinerMenuCreate(param1);
			else if(StrEqual(itemInfo, "PLAYER_BLEEDING"))
				EssentialAdminPlayerStateChangePlayerBleedingMenuCreate(param1);
			else if(StrEqual(itemInfo, "PLAYER_BUNNYHOP"))
				EssentialAdminPlayerStateChangePlayerBunnyHopMenuCreate(param1);
		}
	}
}

public EssentialAdminPlayerStateChangePlayerInfectMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminPlayerStateChangeMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {	
			new String:itemInfo[32];
			new target;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(IsPlayerInfectCheck(target)) {
				SetPlayerInfecting(target, false);
				PrintToChat(target, "%s\x01당신은 강제로 감염이 멈췄습니다.", ESSENTIAL_PREFIX);
			} else { 			
				SetPlayerInfecting(target, true);
				PrintToChat(target, "%s\x01당신은 강제로 감염에 걸리셨습니다.", ESSENTIAL_PREFIX);
			}
			
			EssentialAdminPlayerStateChangePlayerInfectMenuCreate(param1);
		}
	}
}

public EssentialAdminPlayerStateChangePlayerVaccinerMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminPlayerStateChangeMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {	
			new String:itemInfo[32];
			new target;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(IsPlayerVaccinatedCheck(target)) {
				SetPlayerVaccinated(target, false);
				PrintToChat(target, "%s\x01당신은 감염 면역이 사라졌습니다.", ESSENTIAL_PREFIX);
			} else { 			
				SetPlayerVaccinated(target, true);
				PrintToChat(target, "%s\x01당신은 감염 면역을 가지셨습니다.", ESSENTIAL_PREFIX);
			}
			
			EssentialAdminPlayerStateChangePlayerVaccinerMenuCreate(param1);
		}
	}
}

public EssentialAdminPlayerStateChangePlayerBleedingMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminPlayerStateChangeMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new target;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(IsPlayerBleedingCheck(target)) {
				SetPlayerBleeding(target, false);
				PrintToChat(target, "%s\x01당신은 강제로 출혈이 멈췄습니다.", ESSENTIAL_PREFIX);
			} else { 
				SetPlayerBleeding(target, true);
				PrintToChat(target, "%s\x01당신은 강제로 출혈에 걸리셨습니다.", ESSENTIAL_PREFIX);
			}
			
			EssentialAdminPlayerStateChangePlayerBleedingMenuCreate(param1);
		}
	}
}

public EssentialAdminPlayerStateChangePlayerBunnyHopMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminPlayerStateChangeMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new target;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			target = StringToInt(itemInfo);
			
			if(IsPlayerBhop(target)) {
				SetPlayerBhop(target, false);
				PrintToChat(target, "%s\x01버니합이 중지되었습니다.", ESSENTIAL_PREFIX);
			} else { 
				SetPlayerBhop(target, true);
				PrintToChat(target, "%s\x01버니합이 작동됩니다.", ESSENTIAL_PREFIX);
			}
		
			EssentialAdminPlayerStateChangePlayerBunnyHopMenuCreate(param1);
		}
	}
}

stock bool:IsPlayerBleedingCheck(client) {
	return (GetEntProp(client, Prop_Send, "_bleedingOut") == 1) ? true : false;
}

stock bool:IsPlayerInfectCheck(client) {
	if((GetEntPropFloat(client, Prop_Send, "m_flInfectionTime") > 0) && (GetEntPropFloat(client, Prop_Send, "m_flInfectionDeathTime") > 0)) 
		return true;
	else 
		return false;
}

stock bool:IsPlayerVaccinatedCheck(client) {
	return (GetEntProp(client, Prop_Send, "_vaccinated") == 1) ? true : false;
}

stock SetPlayerBleeding(client, bool:onAndOff) {
	if(onAndOff) {
		new Float:damagePos[3];
		new playerHealth;
		
		playerHealth = GetEntProp(client, Prop_Send, "m_iHealth");
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", damagePos);
		
		while(!IsPlayerBleedingCheck(client)) {
			makedamage(-1, client, 1, DMG_RADIATION, 1.0, damagePos);
			SetEntProp(client, Prop_Send, "m_iHealth", playerHealth);
		}	
	} else {
		SetEntProp(client, Prop_Send, "_bleedingOut", 0);
	}
}

stock SetPlayerInfecting(client, bool:onAndOff) {
	if(onAndOff) {
		new Float:damagePos[3];
		new playerHealth;
		
		playerHealth = GetEntProp(client, Prop_Send, "m_iHealth");	
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", damagePos);
		
		while(!IsPlayerInfectCheck(client)) {
			makedamage(-1, client, 1, DMG_NERVEGAS, 1.0, damagePos);
			SetEntProp(client, Prop_Send, "m_iHealth", playerHealth);
		}
		
		SetPlayerBleeding(client, false);
	} else {
		SetEntPropFloat(client, Prop_Send, "m_flInfectionTime", -1.0);
		SetEntPropFloat(client, Prop_Send, "m_flInfectionDeathTime", -1.0);
		SetEntProp(client, Prop_Send, "_bloodinessLevel", 0);
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);	
		CreateTimer(0.1, PlayerViewResetTimer, client); // 그냥 바로할시 화면이 초기화되지 않음.
	}
}

stock bool:SetPlayerVaccinated(client, bool:onAndOff) {
	if(onAndOff) {
		SetEntProp(client, Prop_Send, "_vaccinated", 1);
		SetPlayerInfecting(client, false);
	} else {
		SetEntProp(client, Prop_Send, "_vaccinated", 0);
	}
}


// * 타이머 라인 *
stock Action:PlayerViewResetTimer(Handle:timer, any:client) {
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", client);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
}

stock PlayerActionBunnyHop(client) {
	if(GetEntityFlags(client) & FL_ONGROUND) {
		new Float:fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = 267.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	}
}

public bool:IsPlayerBhop(client) {
	return playerBhop[client];
}

public SetPlayerBhop(client, bool:onAndOff) {
	playerBhop[client] = onAndOff;
}

