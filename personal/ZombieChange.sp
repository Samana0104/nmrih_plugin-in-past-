#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:zombieChange = INVALID_HANDLE; // 

public Plugin:myinfo =
{
	name = "zombie change",
	author = "사마나",
	description = "일반좀비를 러너로 바꿈.",
	version = "0.0",
	url = "."	
};

public OnMapStart() {
    zombieChange = CreateTimer(1.0, ChangeZombies, _, TIMER_REPEAT);
}

public OnMapEnd() {
    KillTimer(zombieChange);
}

public Action:ChangeZombies(Handle:timer, any:client) {
    new entity;
	new Float:spawnPosition[3];
	
	while((entity = FindEntityByClassname(entity, "npc_nmrih_shamblerzombie")) != -1) {
	    new spawnZombie = CreateEntityByName("npc_nmrih_runnerzombie");
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", spawnPosition);
		AcceptEntityInput(entity, "kill");
		DispatchSpawn(spawnZombie);
		TeleportEntity(spawnZombie, spawnPosition, NULL_VECTOR, NULL_VECTOR);
	}
	
	return Plugin_Continue;
}
