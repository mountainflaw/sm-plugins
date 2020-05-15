#include <sourcemod>
#include <system2>

// kicks lagbots and cheaters

public Plugin myinfo = {
	name = "Name Filter",
	author = "mountainflaw",
	description = "Kicks bots matching known cheater patterns and names which normally cannot be obtained.",
	version = "0.2c",
	url = "micsnobs.com"
};

#define KICK_ERROR "Steam auth ticket has been canceled" // kick error for offending player#define STRING_SEARCH 3 // amt of entries in g_NameCheck
#define STRING_SEARCH 4 // amt of entries in g_NameCheck
stock bool:IsClientValid(id){if(id > 0 && id <= MAXPLAYERS && IsClientInGame(id)){return true;}	return false;}

new String:g_NameCheck[][] = { // add entries here
	"valve",
	"nigger",
	"tacobot",
	"MYG)T",
}

public void ExecuteCallback(bool success, const char[] command, System2ExecuteOutput output, any data) {
	if (!success || output.ExitStatus != 0) {
		PrintToServer("Couldn't execute commands %s successfully", command);
	} else {
		char outputString[128];
		output.GetOutput(outputString, sizeof(outputString));
		PrintToServer("Output of the command %s: %s", command, outputString);
	}
}

public void CheckClientName(int client) {
	if (IsClientValid(client)) {
		new String:s_Client[48]; // 32 is the actual limit but let's be safe
		GetClientName(client, s_Client, 48);
		for (int i = 0; i < STRING_SEARCH; i++) {
			if (StrContains(s_Client, g_NameCheck[i], false) != -1 || (StrContains(s_Client, "twilight", false) != -1 && StrContains(s_Client, "sparkle", false) != -1)) { // don't let inbetween characters fuck us
				LogAction(client, -1, "%L was kicked for having an illegal name.", client);
				BanClient(client, 0, BANFLAG_AUTO, "illegal username", KICK_ERROR);
				System2_ExecuteThreaded(ExecuteCallback, "/bin/sh /home/kayeff/server_temp/apply_bans.sh all"); // make bans network wide
			}
		}
	}
}

public Action:CheckClientConnectedNames(Handle:timer) {
	for (int i = 1; i <= MaxClients; i++) {
		CheckClientName(i);
	}
	return Plugin_Continue;
}

public void OnClientAuthorized(int client, const char[] auth) {
	CheckClientName(client);
}

public void OnPluginStart() {
	CreateTimer(2.5, CheckClientConnectedNames, _, TIMER_REPEAT);
}
