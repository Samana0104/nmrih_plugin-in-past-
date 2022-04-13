#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "0.1"

public Plugin:myinfo = {
	name = "StaminaHud",
	author = "Samana",
	description = "플러그인 신청작.",
	version = PLUGIN_VERSION,
	url = ""
};

new Handle:showHudTimer = INVALID_HANDLE;

public OnPluginStart() {
    showHudTimer = CreateTimer(1.0, staminaHud, INVALID_HANDLE, TIMER_REPEAT); // 플러그인이 시작될시 타이머를 실행시킵니다.
}

public Action:staminaHud(Handle:timer, any:data) {
    for(new i = 1; i<=GetMaxClients(); i++) { // GetMaxClients는 서버의 최대 접속 가능인원이 몇명인지 나타내주는 함수입니다.
	    if(IsClientInGame(i) && IsPlayerAlive(i)) { // 해당 클라이언트가 접속중이고 또 플레이어가 살경우에 이 조건이 실행됩니다.
		    new stamina = RoundToCeil(GetEntPropFloat(i, Prop_Send, "m_flStamina")); // 스태미너를 구합니다.
			new maxStamina = GetConVarInt(FindConVar("sv_max_stamina")); // 스태미를 설정한 값을 불러옵니다.
			new staminaPercent = RoundToCeil((float(stamina) / float(maxStamina)) * 100); // 스태미너를 백분율로 처리합니다.
		    SetHudTextParams(-1.0, 1.0, 1.0, 71, 200, 62, 0); // 허드바 위치를 만듭니다. R = 71 / G = 200 / B = 62
			
			if(staminaPercent <= 10) // 스태미너 퍼센트가 10퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ○ ○ ○ ○ ○ ○");
			else if(staminaPercent <= 25) // 스태미너 퍼센트가 25퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ○ ○ ○ ○ ○");
			else if(staminaPercent <= 40) // 스태미너 퍼센트가 40퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ● ○ ○ ○ ○");
			else if(staminaPercent <= 55) // 스태미너 퍼센트가 55퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ● ● ○ ○ ○");			
			else if(staminaPercent <= 70) // 스태미너 퍼센트가 70퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ● ● ● ○ ○");	
			else if(staminaPercent <= 85) // 스태미너 퍼센트가 85퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ● ● ● ● ○");	
			else if(staminaPercent <= 100) // 스태미너 퍼센트가 100퍼센트보다 작을시
			ShowHudText(i, -1, "Stamina : ● ● ● ● ● ●");	
		}
	}
}
