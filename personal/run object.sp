#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo =
{
	name 		= "Run Object",
	author 		= "사마나",
	description 	= "물체 들고 달려라",
	version 		= "1",
	url 			= "없으므"
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2]) {
	if (IsClientInGame(client) && IsPlayerAlive(client))
		{
				SetEntProp(client, Prop_Send, "m_bSprintEnabled", 1);			
		}
}