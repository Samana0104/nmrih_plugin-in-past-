

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new bool:aimShot[MAXPLAYERS+1] = { false, ... }; // 에임샷
new bool:hudAim[MAXPLAYERS+1] = { false, ... }; // 허드줌

new Handle:aimShotTimer = INVALID_HANDLE; // 에임샷 타이머
new Handle:hudAimTimer = INVALID_HANDLE; // 허드줌 타이머

/* 어드민 도구(허드줌, 에임샷 , FOV, 접두사) 메뉴 함수 */
public EssentialAdminToolsMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminToolsMenuHandler);
	new String:aimShotOnAndOff[32];
	new String:hudAimOnAndOff[32];
	
	if(IsAimShot(client))
		Format(aimShotOnAndOff, sizeof(aimShotOnAndOff), "에임샷[적용]");
	else
		Format(aimShotOnAndOff, sizeof(aimShotOnAndOff), "에임샷[비적용]");
	
	if(IsHudAim(client))
		Format(hudAimOnAndOff, sizeof(hudAimOnAndOff), "줌[적용]");
	else
		Format(hudAimOnAndOff, sizeof(hudAimOnAndOff), "줌[비적용]");
		
	SetMenuTitle(menu, "어드민 도구 모음");
	AddMenuItem(menu, "AIM_SHOT", aimShotOnAndOff);
	AddMenuItem(menu, "HUD_AIM", hudAimOnAndOff);
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
}

/* 어드민 도구 - 메뉴 핸들러 */
public EssentialAdminToolsMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "AIM_SHOT")) 
			    PlayerAimShotOnAndOff(param1);
			else if(StrEqual(itemInfo, "HUD_AIM"))
			    PlayerHudAimOnAndOff(param1);
			    
			EssentialAdminToolsMenuCreate(param1);
		}
	}
}

stock PlayerAimShotOnAndOff(client) { // 에임샷 관련 on off
	new bool:IsAimShotOn = false; // 에임샷이 켜져있는 유저가 있는지 확인하는 변수
	
	if(IsAimShot(client)) { // 해당유저가 에임샷이 켜져있다면
		for(new i=1; i<=GetMaxClients(); i++) { // 에임샷을 킨 어드민이 존재하는지 확인
			if(!IsClientInGame(i))
				continue;
				
			if(i == client)
				continue;
			
			if(IsAimShot(i)) { // 만약 존재한다면 그냥 에임샷을 그냥 끔!
				IsAimShotOn = true;
				SetAimShot(client, false);
				break;
			}
		}
		
		if(!IsAimShotOn) { // 에임샷을 쓰는 유저가 없다면 타이머를 없앰.
			SetAimShot(client, false);
			KillTimer(aimShotTimer);
	    }
		
		PrintToChat(client, "%s\x01에임샷을 껏습니다.", ESSENTIAL_PREFIX);
	} else {
		for(new i=1; i<=GetMaxClients(); i++) { // 에임샷을 킨 어드민이 존재하는지 확인
			if(!IsClientInGame(i))
				continue;
				
			if(IsAimShot(i)) { // 만약 존재한다면 그냥 에임샷을 그냥 킴!
				IsAimShotOn = true;
				SetAimShot(client, true);
				break;
			}
		}
		
		if(!IsAimShotOn) { // 에임샷을 쓰는 유저가 없다면 타이머를 새롭게 만듬
			SetAimShot(client, true);
			aimShotTimer = CreateTimer(0.1, AimShotTime, client, TIMER_REPEAT);
		}
		PrintToChat(client, "%s\x01에임샷을 켰습니다.", ESSENTIAL_PREFIX);
		PrintToChat(client, "%s\x07FF4848[주의]\x01에임샷의 기능을 쓰실경우 맨하탄(도전과제)이 날라가실수도 있습니다.", ESSENTIAL_PREFIX);
	}
}

stock PlayerHudAimOnAndOff(client) { // 허드줌 관련 on off
	new bool:IsHudAimOn = false; // 허드줌이 켜져있는 유저가 있는지 확인하는 변수
	
	if(IsHudAim(client)) { // 해당유저가 줌이 켜져있다면
		for(new i=1; i<=GetMaxClients(); i++) { // 허드줌을 킨 유저가 존재하는지 확인
			if(!IsClientInGame(i) || i == client)
				continue;
			
			if(IsHudAim(i)) { // 만약 존재한다면 그냥 허드줌을 그냥 끔!
				IsHudAimOn = true;
				SetHudAim(client, false);
				break;
			}
		}
		
		if(!IsHudAimOn) { // 허드줌을 쓰는 유저가 없다면 타이머를 없앰.
			SetHudAim(client, false);
			KillTimer(hudAimTimer);
	    }
		
		PrintToChat(client, "%s\x01줌을 껏습니다.", ESSENTIAL_PREFIX);
	} else {
		for(new i=1; i<=GetMaxClients(); i++) { // 허드줌을 킨 사람이 존재하는지 확인
			if(!IsClientInGame(i) || i == client)
				continue;
				
			if(IsHudAim(i)) { // 만약 존재한다면 그냥 허드줌을 그냥 킴!
				IsHudAimOn = true;
				SetHudAim(client, true);
				break;
			}
		}
		
		if(!IsHudAimOn) { // 허드줌을 쓰는 유저가 없다면 타이머를 새롭게 만듬
			SetHudAim(client, true);
			hudAimTimer = CreateTimer(1.0, HudAimTime, INVALID_HANDLE, TIMER_REPEAT);
		}
		
		PrintToChat(client, "%s\x01줌을 켰습니다.", ESSENTIAL_PREFIX);
	}
}

/* 타이머 라인 */
public Action:AimShotTime(Handle:timer, any:client) {
	for(new i=1; i<=GetMaxClients(); i++) {
		if(IsClientInGame(i) && IsPlayerAlive(i)) { 
			if(IsAimShot(i)) { // 에임샷이 켜져있다면
				new target = GetClientAimTarget(i, false); 
				new String:targetClassName[256];
				
				if(IsValidEntity(target)) { // 가리키는 에임 타겟이 존재하는 엔디티라면 
					GetEdictClassname(target, targetClassName, sizeof(targetClassName));
					
					if(StrContains(targetClassName, "npc_n", false) == 0) { // 가리키는 엔디티가 좀비라면 없애버림 ( 헬기도 포함 )
						new Float:zombiePosition[3];
						new String:playerWeaponName[64];
						
						GetEntPropVector(target, Prop_Send, "m_vecOrigin", zombiePosition);
						PlayerHandEquipWeaponName(i, playerWeaponName, sizeof(playerWeaponName));
						makedamage(i, target, 999999999, DMG_BULLET, 1.0, zombiePosition, playerWeaponName);
						
						/*
						new entity = CreateEntityByName("env_entity_dissolver");
						
						DispatchKeyValue(target, "targetname", "dissolveZombie");
						DispatchKeyValue(entity, "target", "dissolveZombie");
						DispatchKeyValue(entity, "dissolvetype", "3");
						AcceptEntityInput(entity, "Dissolve");
						AcceptEntityInput(entity, "Kill");
					
						*/
					}
				}
		    }
		}
	}
	return Plugin_Continue;
}

public Action:HudAimTime(Handle:timer, any:data) {
    for(new i=1; i<=GetMaxClients(); i++) {
	    if(IsClientInGame(i) && IsPlayerAlive(i)) { 
		    if(IsHudAim(i)) { // 줌이 켜져있다면
			    SetHudTextParams(-1.0, 0.48, 1.0, 255, 72, 72, 0); // 0.48
			    ShowHudText(i, -1, "+");
		    }
		}
	}
	
    return Plugin_Continue;
}

public SetAimShot(client, bool:onAndOff) {
    aimShot[client] = onAndOff
}

public SetHudAim(client, bool:onAndOff) {
    hudAim[client] = onAndOff
}

public bool:IsAimShot(client) {
    return aimShot[client];
}

public bool:IsHudAim(client) {
    return hudAim[client];
}