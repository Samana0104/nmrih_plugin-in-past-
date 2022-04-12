

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

#define ZOMBIE_TYPE_NULL 0
#define ZOMBIE_TYPE_SHAMBLER 1
#define ZOMBIE_TYPE_RUNNER 2
#define ZOMBIE_TYPE_KID 3

#define ZOMBIE_BASE_HEALTH 100
#define ZOMBIE_BASE_SIZE 1.0

#define RGB_WHITE 0
#define RGB_RED 1
#define RGB_ORANGE 2
#define RGB_YELLOW 3
#define RGB_GREEN 4 
#define RGB_BLUE 5
#define RGB_PURPLE 6
#define RGB_PALE_BLACK 7
#define RGB_EMERALD 8

#define RGB_COLOR_LIST 9

new rgbColorType[RGB_COLOR_LIST][3] = { 
	{ 255, 255, 255 }, 
	{ 255, 72, 72 }, 
	{ 255, 130, 36 }, 
	{ 255, 228, 0 }, 
	{ 125, 254, 116 }, 
	{ 103, 153, 255 }, 
	{ 255, 119, 251 }, 
	{ 79, 79, 79 },
	{ 79, 201, 222 }
};

new playerChooseZombieType[MAXPLAYERS+1] = { ZOMBIE_TYPE_NULL, ZOMBIE_TYPE_NULL, ...};
new playerChooseZombieHealth[MAXPLAYERS+1] = { ZOMBIE_BASE_HEALTH, ZOMBIE_BASE_HEALTH, ...};
new playerChooseZombieColor[MAXPLAYERS+1] = { RGB_WHITE, RGB_WHITE, RGB_WHITE, ...};
new Float:playerChooseZombieSize[MAXPLAYERS+1] = { ZOMBIE_BASE_SIZE, ZOMBIE_BASE_SIZE, ZOMBIE_BASE_SIZE, ...};

new Float:playerChooseZombieSpawnPos[MAXPLAYERS+1][3];

public EssentialAdminZombieSpawnerMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminZombieSpawnerMenuHandler);
	new String:zombieType[64], String:isSpawnPosition[64], String:zombieColor[64];
	
	switch(GetPlayerChooseZombieType(client)) {
		case ZOMBIE_TYPE_NULL:
		{
			Format(zombieType, sizeof(zombieType), "스폰 시킬 좀비 엔티티 설정[존재안함]");
		}
		case ZOMBIE_TYPE_SHAMBLER:
		{
			Format(zombieType, sizeof(zombieType), "스폰 시킬 좀비 엔티티 설정[셈블러]");
		}
		case ZOMBIE_TYPE_RUNNER:
		{
			Format(zombieType, sizeof(zombieType), "스폰 시킬 좀비 엔티티 설정[러너]");
		}
		case ZOMBIE_TYPE_KID: 
		{
			Format(zombieType, sizeof(zombieType), "스폰 시킬 좀비 엔티티 설정[키드]");
		}
	}
	
	switch(GetPlayerChooseZombieColor(client)) {
		case RGB_WHITE:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[화이트]");
		}
		case RGB_RED:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[빨강]");
		}
		case RGB_ORANGE:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[주황]");
		}
		case RGB_YELLOW: 
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[노랑]");
		}
		case RGB_GREEN:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[초록]");
		}
		case RGB_BLUE:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[파랑]");
		}
		case RGB_PURPLE:
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[보라]");
		}
		case RGB_PALE_BLACK: 
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[연한 검정]");
		}
		case RGB_EMERALD: 
		{
			Format(zombieColor, sizeof(zombieColor), "스폰 시킬 좀비 색깔[에메랄드]");
		}
	}
	
	if((playerChooseZombieSpawnPos[client][0] == 0.0 && playerChooseZombieSpawnPos[client][1] == 0.0 && playerChooseZombieSpawnPos[client][2] == 0.0))
		Format(isSpawnPosition, sizeof(isSpawnPosition), "현재 있는 자리에 좌표설정[미설정]");
	else
		Format(isSpawnPosition, sizeof(isSpawnPosition), "현재 있는 자리에 좌표설정[설정 완료]");
					
	SetMenuTitle(menu, "입맛에 맞게 좀비를 만들어 봅시다.");
	AddMenuItem(menu, "SET_ZOMBIE_SHAPE", zombieType);
	AddMenuItem(menu, "SET_ZOMBIE_SPAWN_POSTION", isSpawnPosition);
	
	if(!(GetPlayerChooseZombieType(client) == ZOMBIE_TYPE_NULL)) {
		AddMenuItem(menu, "SET_ZOMBIE_HEALTH", "스폰 시킬 좀비 체력 설정");
		AddMenuItem(menu, "SET_ZOMBIE_COLOR", zombieColor);
		AddMenuItem(menu, "SET_ZOMBIE_SIZE", "스폰 시킬 좀비 사이즈 설정");
		
		if(!(playerChooseZombieSpawnPos[client][0] == 0.0 && playerChooseZombieSpawnPos[client][1] == 0.0 && playerChooseZombieSpawnPos[client][2] == 0.0))
			AddMenuItem(menu, "SET_ZOMBIE_SPAWNER", "좀비를 설정시킨 좌표에 스폰시킵니다.");
			
		AddMenuItem(menu, "SET_ZOMBIE_ANGLE_SPAWN", "좀비를 눈앞에 소환 시킵니다. <주의 좀비랑 낄수 있어요>");
	}
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminZombieSpawnerSetZombieShapeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminZombieSpawnerSetZombieShapeMenuHandler);
	new String:zombieTypeShambler[4], String:zombieTypeRunner[4], String:zombieTypeKid[4];

	IntToString(ZOMBIE_TYPE_SHAMBLER, zombieTypeShambler, sizeof(zombieTypeShambler));
	IntToString(ZOMBIE_TYPE_RUNNER, zombieTypeRunner, sizeof(zombieTypeRunner));
	IntToString(ZOMBIE_TYPE_KID, zombieTypeKid, sizeof(zombieTypeKid));
	
	SetMenuTitle(menu, "소환시킬 좀비의 엔티티를 선택하세요.");
	AddMenuItem(menu, zombieTypeShambler, "셈블러 좀비");
	AddMenuItem(menu, zombieTypeRunner, "러너 좀비");
	AddMenuItem(menu, zombieTypeKid, "키드 좀비");	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}

public EssentialAdminZombieSpawnerSetZombieHealthMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminZombieSpawnerSetZombieHealthMenuHandler);
	
	SetMenuTitle(menu, "현재 설정된 좀비의 체력[%d]", GetPlayerChooseZombieHealth(client));
	AddMenuItem(menu, "1", "좀비의 체력[+1]");
	AddMenuItem(menu, "10", "좀비의 체력[+10]");
	AddMenuItem(menu, "100", "좀비의 체력[+100]");	
	AddMenuItem(menu, "1000", "좀비의 체력[+1000]");	
	AddMenuItem(menu, "10000", "좀비의 체력[+10000]");	
	AddMenuItem(menu, "100000", "좀비의 체력[+100000]");	
	AddMenuItem(menu, "사마나님 최고 어캐 이런걸 만듬 앙 사마나띠", "다음페이지로 넘기시면 -로 나옵니다.", ITEMDRAW_DISABLED);	
	AddMenuItem(menu, "-1", "좀비의 체력[-1]");
	AddMenuItem(menu, "-10", "좀비의 체력[-10]");
	AddMenuItem(menu, "-100", "좀비의 체력[-100]");	
	AddMenuItem(menu, "-1000", "좀비의 체력[-1000]");	
	AddMenuItem(menu, "-10000", "좀비의 체력[-10000]");	
	AddMenuItem(menu, "-100000", "좀비의 체력[-100000]");	
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminZombieSpawnerSetZombieColorMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminZombieSpawnerSetZombieColorMenuHandler);
	new String:colorTypeWhite[4], String:colorTypeRed[4], String:colorTypeOrange[4], String:colorTypeYellow[4], String:colorTypeGreen[4], String:colorTypeBlue[4];
	new String:colorTypePurple[4], String:colorTypePaleBlack[4], String:colorTypeEmerald[4];
	IntToString(RGB_WHITE, colorTypeWhite, sizeof(colorTypeWhite));
	IntToString(RGB_RED, colorTypeRed, sizeof(colorTypeRed));
	IntToString(RGB_ORANGE, colorTypeOrange, sizeof(colorTypeOrange));
	IntToString(RGB_YELLOW, colorTypeYellow, sizeof(colorTypeYellow));
	IntToString(RGB_GREEN, colorTypeGreen, sizeof(colorTypeGreen));
	IntToString(RGB_BLUE, colorTypeBlue, sizeof(colorTypeBlue));
	IntToString(RGB_PURPLE, colorTypePurple, sizeof(colorTypePurple));
	IntToString(RGB_PALE_BLACK, colorTypePaleBlack, sizeof(colorTypePaleBlack));
	IntToString(RGB_EMERALD, colorTypeEmerald, sizeof(colorTypeEmerald));
	
	SetMenuTitle(menu, "좀비의 컬러 선택");
	AddMenuItem(menu, colorTypeWhite, "화이트");
	AddMenuItem(menu, colorTypeRed, "빨강");
	AddMenuItem(menu, colorTypeOrange, "주황");	
	AddMenuItem(menu, colorTypeYellow, "노랑");	
	AddMenuItem(menu, colorTypeGreen, "초록");	
	AddMenuItem(menu, colorTypeBlue, "파랑");	
	AddMenuItem(menu, colorTypePurple, "보라");	
	AddMenuItem(menu, colorTypePaleBlack, "연한 검정");
	AddMenuItem(menu, colorTypeEmerald, "에메랄드");
	
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminZombieSpawnerSetZombieSizeMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminZombieSpawnerSetZombieSizeMenuHandler);
	
	SetMenuTitle(menu, "설정된 좀비 사이즈[%f]ㅣ기본[%f]", GetPlayerChooseZombieSize(client), ZOMBIE_BASE_SIZE);
	AddMenuItem(menu, "0.01", "좀비의 사이즈[+0.01]");
	AddMenuItem(menu, "0.05", "좀비의 사이즈[+0.05]");
	AddMenuItem(menu, "0.1", "좀비의 사이즈[+0.1]");	
	AddMenuItem(menu, "0.5", "좀비의 사이즈[+0.5]");	
	AddMenuItem(menu, "1", "좀비의 사이즈[+1]");	
	AddMenuItem(menu, "5", "좀비의 사이즈[+5]");	
	AddMenuItem(menu, "사마나님 최고 어캐 이런걸 만듬 앙 사마나띠", "다음페이지로 넘기시면 -로 나옵니다.", ITEMDRAW_DISABLED);	
	AddMenuItem(menu, "-0.01", "좀비의 사이즈[-0.01]");
	AddMenuItem(menu, "-0.05", "좀비의 사이즈[-0.05]");
	AddMenuItem(menu, "-0.1", "좀비의 사이즈[-0.1]");	
	AddMenuItem(menu, "-0.5", "좀비의 사이즈[-0.5]");	
	AddMenuItem(menu, "-1", "좀비의 사이즈[-1]");	
	AddMenuItem(menu, "-5", "좀비의 사이즈[-5]");	

	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public EssentialAdminZombieSpawnerMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "SET_ZOMBIE_SHAPE")) {
				EssentialAdminZombieSpawnerSetZombieShapeMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_SPAWN_POSTION")) {
				new Float:position[3];
				
				GetEntPropVector(param1, Prop_Send, "m_vecOrigin", position);
				position[2] += 3.0;
				SetPlayerChooseZombieSpawnPos(param1, position);
				EssentialAdminZombieSpawnerMenuCreate(param1);
				PrintToChat(param1, "%s\x01해당 포지션이 설정되었습니다.", ESSENTIAL_PREFIX);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_HEALTH")) {
				EssentialAdminZombieSpawnerSetZombieHealthMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_COLOR")) {
				EssentialAdminZombieSpawnerSetZombieColorMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_SIZE")) {
				EssentialAdminZombieSpawnerSetZombieSizeMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_SPAWNER")) {
				new Float:position[3];
				new color[3];
				
				GetPlayerChooseZombieSpawnPos(param1, position);
				GetRgbColorType(param1, color);
				
				InGameZombieSpawn(GetPlayerChooseZombieType(param1), GetPlayerChooseZombieHealth(param1), position, GetPlayerChooseZombieSize(param1), color[0], color[1], color[2]);
				EssentialAdminZombieSpawnerMenuCreate(param1);
			} else if(StrEqual(itemInfo, "SET_ZOMBIE_ANGLE_SPAWN")) {
				new Float:position[3];
				new color[3];
				
				PlayerEyeAngleFrontPosition(param1, position, NULL_VECTOR);
				position[2] -= 10;
				GetRgbColorType(param1, color);
				
				InGameZombieSpawn(GetPlayerChooseZombieType(param1), GetPlayerChooseZombieHealth(param1), position, GetPlayerChooseZombieSize(param1), color[0], color[1], color[2]);
				EssentialAdminZombieSpawnerMenuCreate(param1);				
			}
		}
	}
}

public EssentialAdminZombieSpawnerSetZombieShapeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminZombieSpawnerMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[4];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
				
			SetPlayerChooseZombieType(param1, StringToInt(itemInfo));
			EssentialAdminZombieSpawnerMenuCreate(param1);
		}
	}
}

public EssentialAdminZombieSpawnerSetZombieHealthMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminZombieSpawnerMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new zombieHealth, setHealth;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			zombieHealth = GetPlayerChooseZombieHealth(param1);
			setHealth = zombieHealth+StringToInt(itemInfo);
			
			SetPlayerChooseZombieHealth(param1, setHealth);
			PrintToChat(param1, "%s\x01스폰될 좀비의 체력이 [%d]로 지정됩니다.", ESSENTIAL_PREFIX, setHealth);
			EssentialAdminZombieSpawnerSetZombieHealthMenuCreate(param1);
			
		}
	}
}

public EssentialAdminZombieSpawnerSetZombieColorMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminZombieSpawnerMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));

			SetPlayerChooseZombieColor(param1, StringToInt(itemInfo));
			EssentialAdminZombieSpawnerMenuCreate(param1);		
		}
	}
}

public EssentialAdminZombieSpawnerSetZombieSizeMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
    switch(action) {
	    case MenuAction_End:
		{
			CloseHandle(menu);
		}

		case MenuAction_Cancel:
		{
		    if(param2 == MenuCancel_ExitBack)
			    EssentialAdminZombieSpawnerMenuCreate(param1);
		}
		
		case MenuAction_Select:
	    {
			new String:itemInfo[32];
			new Float:zombieSize;
			GetMenuItem(menu, param2, itemInfo, sizeof(itemInfo));
			
			zombieSize = GetPlayerChooseZombieSize(param1) + StringToFloat(itemInfo);
			
			if(zombieSize > 0.0 && zombieSize < 10.0) {
				SetPlayerChooseZombieSize(param1, zombieSize);
				PrintToChat(param1, "%s\x01스폰될 좀비의 사이즈가 [%f]로 지정됩니다.", ESSENTIAL_PREFIX, zombieSize);
				EssentialAdminZombieSpawnerSetZombieSizeMenuCreate(param1);		
			} else {
				PrintToChat(param1, "%s\x01스폰될 좀비의 사이즈를 0.0 이상 10.0 미만으로만 설정 가능합니다.", ESSENTIAL_PREFIX);
				EssentialAdminZombieSpawnerSetZombieSizeMenuCreate(param1);	
			}
		}
	}
}

stock InGameZombieSpawn(zombieType, zombieHealth, Float:spawnPosition[3], Float:modelSize, r, g, b) {
	new entity;
	new String:zombieTypeEntityName[32];
	
	switch(zombieType) {
		case ZOMBIE_TYPE_SHAMBLER:
		{
			Format(zombieTypeEntityName, sizeof(zombieTypeEntityName), "npc_nmrih_shamblerzombie");
		}
		case ZOMBIE_TYPE_RUNNER:
		{
			Format(zombieTypeEntityName, sizeof(zombieTypeEntityName), "npc_nmrih_runnerzombie");
		}
		case ZOMBIE_TYPE_KID:
		{
			Format(zombieTypeEntityName, sizeof(zombieTypeEntityName), "npc_nmrih_kidzombie");
		}
	}
	
	entity = CreateEntityByName(zombieTypeEntityName);
	SetEntPropVector(entity, Prop_Send, "m_vecOrigin", spawnPosition);
	SetEntityRenderColor(entity, r, g, b);
	SetEntPropFloat(entity, Prop_Data, "m_flModelScale", modelSize);
	
	DispatchSpawn(entity);
	SetEntProp(entity, Prop_Data, "m_iHealth", zombieHealth);
}

public SetPlayerChooseZombieType(client, type) {
	playerChooseZombieType[client] = type;
}

public SetPlayerChooseZombieSpawnPos(client, Float:setPoint[3]) {
	playerChooseZombieSpawnPos[client][0] = setPoint[0];
	playerChooseZombieSpawnPos[client][1] = setPoint[1];
	playerChooseZombieSpawnPos[client][2] = setPoint[2];
}

public SetPlayerChooseZombieHealth(client, health) {
	playerChooseZombieHealth[client] = health;
}

public SetPlayerChooseZombieColor(client, color) {
	playerChooseZombieColor[client] = color;
}

public SetPlayerChooseZombieSize(client, Float:size) {
	playerChooseZombieSize[client] = size;
}

public GetPlayerChooseZombieType(client) {
	return playerChooseZombieType[client];
}

public GetPlayerChooseZombieSpawnPos(client, Float:setPoint[3]) {
	setPoint[0] = playerChooseZombieSpawnPos[client][0];
	setPoint[1] = playerChooseZombieSpawnPos[client][1];
	setPoint[2] = playerChooseZombieSpawnPos[client][2];
}

public GetPlayerChooseZombieHealth(client) {
	return playerChooseZombieHealth[client];
}

public GetPlayerChooseZombieColor(client) {
	return playerChooseZombieColor[client];
}


public GetRgbColorType(client, color[3]) {
	color[0] = rgbColorType[GetPlayerChooseZombieColor(client)][0];
	color[1] = rgbColorType[GetPlayerChooseZombieColor(client)][1];
	color[2] = rgbColorType[GetPlayerChooseZombieColor(client)][2];
}

public Float:GetPlayerChooseZombieSize(client) {
	return playerChooseZombieSize[client];
}