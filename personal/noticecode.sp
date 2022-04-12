#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CODE_PREFIX "\x07B3FFAA[암호해독기]\x01"

public Plugin:myinfo = {
	name = "NoticeCode",
	author = "사마나",
	description = "코드 따개",
	version = "0.1",
	url = ""
};

public OnPluginStart() {
	HookEvent("keycode_enter", Event_KeyCodeEnter);
	HookEvent("nmrih_round_begin", Event_RoundBegin);	
}

public Action:Event_RoundBegin(Handle:event, const String:name[], bool:dontBroadcast) {
	PrintToChatAll("\x01%s이 서버는 암호해독기를 사용하고 있습니다. \n알고 싶은 비밀번호는 처음에 아무거나 치시면 해독기가 \n분석해서 알려줍니다. by Samana", CODE_PREFIX);
}

public Action:Event_KeyCodeEnter(Handle:event, const String:name[], bool:dontBroadcast) {
	new keypadIdx = GetEventInt(event, "keypad_idx");
	new player = GetEventInt(event, "player");
	new String:inputPassword[32];
	new String:password[32];
	
	GetEventString(event, "code", inputPassword, 32);
	GetEntPropString(keypadIdx, Prop_Data, "m_pszCode", password, 32);
	
	if(strcmp(inputPassword, password) != 0)
		PrintToChat(player, "\x01%s해당 암호의 비밀번호는 \x07FF6C6C%s\x01입니다.", CODE_PREFIX, password); 
}