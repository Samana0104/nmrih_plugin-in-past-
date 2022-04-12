

#define ESSENTIAL_PREFIX "\x077DFE74[Essential]"

new bool:playerChatOn = true; // 전체챗이 얼려져있는지 
new bool:playerVoiceMuteOn = true; // 보이스가 켜져있는지

/* 어드민 전체관리 메뉴 함수 */
public EssentialAdminAllControlMenuCreate(client) {
	new Handle:menu = CreateMenu(EssentialAdminAllControlMenuHandler);
	new String:isAllChat[32];
	new String:isVoiceMute[32];
	
	if(IsPlayerChatOn())
	    Format(isAllChat, sizeof(isAllChat), "전체채팅[가능]");
	else
	    Format(isAllChat, sizeof(isAllChat), "전체채팅[불가능]");
	
	if(IsPlayerVoiceMuteOn())
	    Format(isVoiceMute, sizeof(isVoiceMute), "전체보이스[가능]");
	else
	    Format(isVoiceMute, sizeof(isVoiceMute), "전체보이스[불가능]");
		
	SetMenuTitle(menu, "어드민 전체 관리");
	
	if(EssentialSettingFunctionGetFlag("chat_function")) 
	    AddMenuItem(menu, "ALL_CHAT", isAllChat);
		
	AddMenuItem(menu, "VOICE_MUTE", isVoiceMute);
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);    
}

/* 어드민 전체 관리 - 메뉴 핸들러 */
public EssentialAdminAllControlMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
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
			
			if(StrEqual(itemInfo, "ALL_CHAT")) {				
			    if(IsPlayerChatOn()) {
					SetPlayerChatOn(false);
					PrintToChatAll("%s\x01어드민이 전체채팅을 얼렸습니다.", ESSENTIAL_PREFIX);
				} else {
					SetPlayerChatOn(true);
					PrintToChatAll("%s\x01어드민이 전체채팅을 활성화 시켰습니다.", ESSENTIAL_PREFIX);
				}
			} else if(StrEqual(itemInfo, "VOICE_MUTE")) {
			    if(IsPlayerVoiceMuteOn()) {
					SetPlayerVoiceMuteOn(false);
					
					for(new i=1; i<=GetMaxClients(); i++) {
						if(IsClientInGame(i)) {
							if(IsPlayerAdmin(i))
								continue;
							
							SetClientListeningFlags(i, VOICE_MUTED);
						}
					}
					
					PrintToChatAll("%s\x01어드민이 전체보이스를 꺼버렸습니다.", ESSENTIAL_PREFIX);
				} else {
					SetPlayerVoiceMuteOn(true);
					
					for(new i=1; i<=GetMaxClients(); i++) {
					    if(IsClientInGame(i))
						    SetClientListeningFlags(i, VOICE_NORMAL);
					}
					
					PrintToChatAll("%s\x01어드민이 전체보이스를 켰습니다.", ESSENTIAL_PREFIX);
				}
			}
			
			EssentialAdminAllControlMenuCreate(param1);
		}
	}
}

public bool:IsPlayerChatOn() {
    return playerChatOn;
}

public bool:IsPlayerVoiceMuteOn() {
    return playerVoiceMuteOn;
}

public SetPlayerChatOn(bool:onAndOff) {
    playerChatOn = onAndOff
}

public SetPlayerVoiceMuteOn(bool:onAndOff) {
    playerVoiceMuteOn = onAndOff
}