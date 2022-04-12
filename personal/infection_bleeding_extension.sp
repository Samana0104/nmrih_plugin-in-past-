#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.2"

new bool:Infection[MAXPLAYERS+1];
new bool:Bleeding[MAXPLAYERS+1];

// new bool:isPlayerInfection[MAXPLAYERS+1];

new Handle:convar_BleedingMaxTime = INVALID_HANDLE;
new Handle:convar_BleedingMinTime = INVALID_HANDLE;

new Handle:convar_infectionMaxTime = INVALID_HANDLE;
new Handle:convar_infectionMinTime = INVALID_HANDLE;

new isPlayerBloodingTimer[MAXPLAYERS+1];
new isPlayerInfectionTimer[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "Infection&Bleeding Extension",
	author = "ys24ys / 수정자 Samana",
	description = "Infection&Bleeding Notification for NMRiH",
	version = PLUGIN_VERSION,
	url = "http://ys24ys.iptime.org/xpressengine/"
};

public OnPluginStart()
{	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);

	convar_infectionMaxTime = CreateConVar("sm_infection_max_time", "200", "감염 지속시 사망 최소 ~ 시간.");
	convar_infectionMinTime = CreateConVar("sm_infection_min_time", "300", "감염 지속시 사망 ~ 최대 시간.");
	convar_BleedingMaxTime = CreateConVar("sm_bleeding_max_time", "40", "출혈 지속시 사망 최소 ~ 시간.");
	convar_BleedingMinTime = CreateConVar("sm_bleeding_min_time", "80", "출혈 지속시 사망 ~ 최대 시간.");
	AutoExecConfig(true, "extension_timer");
	
	OnStatusTimer();
}

public OnStatusTimer()
{
	for(new client=1; client<=8; client++)
	{
		CreateTimer(0.5, Event_PlayerStatus, client, TIMER_REPEAT);
		CreateTimer(1.0, PlayerBleedingAndInfection, client, TIMER_REPEAT);
	}
}

public Action:Event_PlayerStatus(Handle:timer, any:client)
{
	if(IsClientConnected(client) && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if(IsClientInfected(client) == false) Infection[client] = false;
		
		if(IsClientInfected(client) == true)
		{
			if(Infection[client] == false)
			{
				Infection[client] = true;
				isPlayerInfectionTimer[client] = GetRandomInt(GetConVarInt(convar_infectionMinTime), GetConVarInt(convar_infectionMaxTime));
				PrintToChat(client, "\x04[%N] : \x07#FFFF0머리가 어지럽다 감염된건가...?", client);
			}
		}
		
		if(IsClientBleeding(client) == false) Bleeding[client] = false;
		
		if(IsClientBleeding(client))
		{
			if(Bleeding[client] == false)
			{
				Bleeding[client] = true;
				isPlayerBloodingTimer[client] = GetRandomInt(GetConVarInt(convar_BleedingMinTime), GetConVarInt(convar_BleedingMaxTime));
				PrintToChat(client, "\x04[%N] : \x07#FFFF0피가 너무 많이 난다, 빨리 치료하지 않으면 죽을것 같다.", client);
			}
		}
	}
}

public Action:PlayerBleedingAndInfection(Handle:timer, any:client) {
	if(IsClientConnected(client) && IsClientInGame(client) && IsPlayerAlive(client)) {
		if(IsClientBleeding(client)) {
			if(isPlayerBloodingTimer[client] == 0) {
				ClientCommand(client, "kill");
				PrintToChat(client, "\x04[%N] : \x07#FFFF0당신은 과다출혈로 인해 사망하였습니다.", client);
			} else {
				isPlayerBloodingTimer[client]--;
				
				if(isPlayerBloodingTimer[client] == 10)
					PrintToChat(client, "\x04[%N] : \x07#FFFF0피를 너무 많이 흘려서 몸에 힘이 점점 빠진다.", client);
				}
		}
		
		if(IsClientInfected(client)) {
			if(isPlayerInfectionTimer[client] == 0) {
				ClientCommand(client, "kill");
				PrintToChat(client, "\x04[%N] : \x07#FFFF0당신은 감염으로 인해 사망하였습니다..", client);
			} else {
				isPlayerInfectionTimer[client]--;
				
				if(isPlayerInfectionTimer[client] == 30)
					PrintToChat(client, "\x04[%N] : \x07#FFFF0머리가 깨질듯이 아프다.... 쓰러질것 같다.", client);			    
			}
		}
	}
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(Infection[client] == true) Infection[client] = false;
	if(Bleeding[client] == true) {
	    Bleeding[client] = false;
	}
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(Infection[client] == true) Infection[client] = false;
	if(Bleeding[client] == true) {
	    Bleeding[client] = false;
	}
}

stock bool:IsClientInfected(client)
{
	if(GetEntPropFloat(client, Prop_Send, "m_flInfectionTime") > 0 && GetEntPropFloat(client, Prop_Send, "m_flInfectionDeathTime") > 0) return true;
	else return false;
}

stock bool:IsClientBleeding(client)
{
	if(GetEntProp(client, Prop_Send, "_bleedingOut") == 1) return true;
	else return false;
}

