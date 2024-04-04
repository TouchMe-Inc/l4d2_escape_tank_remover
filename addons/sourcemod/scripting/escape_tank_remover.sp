#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <left4dhooks>


public Plugin myinfo = {
	name = "EscapeTankRemover",
	author = "TouchMe",
	description = "The plugin prevents tanks from appearing after the vehicle arrives",
	version = "build0000",
	url = "https://github.com/TouchMe-Inc/l4d2_escape_tank_remover"
}


/*
 * Team.
 */
#define TEAM_INFECTED           3

/*
 * Special infected class.
 */
#define SI_CLASS_TANK           8


bool g_bFinaleVehicleIncoming = false;


public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_incoming", Event_FinaleVehicleIncoming, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_ready", Event_FinaleVehicleIncoming, EventHookMode_PostNoCopy);
}

public void Event_RoundStart(Event event, const char[] sEventName, bool bDontBroadcast) {
	g_bFinaleVehicleIncoming = false;
}

void Event_FinaleVehicleIncoming(Event event, const char[] sEventName, bool bDontBroadcast)
{
	g_bFinaleVehicleIncoming = true;

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer ++)
	{
		if (!IsClientInGame(iPlayer)
		|| !IsFakeClient(iPlayer)
		|| !IsClientInfected(iPlayer)
		|| !IsPlayerAlive(iPlayer)
		|| !IsClientTank(iPlayer)) {
			continue;
		}

		KickClient(iPlayer);
	}
}

public Action L4D_OnSpawnTank(const float vOrigin[3], const float vAngle[3])
{
	if (g_bFinaleVehicleIncoming) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnTryOfferingTankBot(int iTank, bool &bEnterStasis)
{
	if (g_bFinaleVehicleIncoming) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

/**
 * Infected team player?
 */
bool IsClientInfected(int iClient) {
	return (GetClientTeam(iClient) == TEAM_INFECTED);
}

/**
 * Gets the client L4D1/L4D2 zombie class id.
 *
 * @param client     Client index.
 * @return L4D1      1=SMOKER, 2=BOOMER, 3=HUNTER, 4=WITCH, 5=TANK, 6=NOT INFECTED
 * @return L4D2      1=SMOKER, 2=BOOMER, 3=HUNTER, 4=SPITTER, 5=JOCKEY, 6=CHARGER, 7=WITCH, 8=TANK, 9=NOT INFECTED
 */
int GetClientClass(int iClient) {
	return GetEntProp(iClient, Prop_Send, "m_zombieClass");
}

bool IsClientTank(int iClient) {
	return (GetClientClass(iClient) == SI_CLASS_TANK);
}
