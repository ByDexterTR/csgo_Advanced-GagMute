#include <sourcemod>
#include <clientprefs>
#include <sdktools_voice>
#include <discord>
#include <basecomm>

#pragma semicolon 1
#pragma newdecls required

ConVar g_dc_webhook = null;
Cookie pgag = null, pmute = null, sgag = null, smute = null, 
pgags = null, pmutes = null, sgags = null, smutes = null;

bool ClientGag[65] = { false, ... }, ClientMute[65] = { false, ... };

#include "thi/pgag.sp"
#include "thi/pmute.sp"
#include "thi/psilence.sp"

#include "thi/sgag.sp"
#include "thi/smute.sp"

public Plugin myinfo = 
{
	name = "Gelişmiş Basecomm", 
	author = "ByDexter", 
	description = "", 
	version = "1.6", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1))

public void OnPluginStart()
{
	sgag = new Cookie("dex-sgag", "", CookieAccess_Protected);
	smute = new Cookie("dex-smute", "", CookieAccess_Protected);
	pgag = new Cookie("dex-pgag", "", CookieAccess_Protected);
	pmute = new Cookie("dex-pmute", "", CookieAccess_Protected);
	
	sgags = new Cookie("dex-sgags", "", CookieAccess_Protected);
	smutes = new Cookie("dex-smutes", "", CookieAccess_Protected);
	pgags = new Cookie("dex-pgags", "", CookieAccess_Protected);
	pmutes = new Cookie("dex-pmutes", "", CookieAccess_Protected);
	
	RegAdminCmd("sm_pmute", Command_PMute, ADMFLAG_CUSTOM5, "");
	RegAdminCmd("sm_pgag", Command_PGag, ADMFLAG_CUSTOM5, "");
	
	RegAdminCmd("sm_smute", Command_SMute, ADMFLAG_CUSTOM3, "");
	RegAdminCmd("sm_sgag", Command_SGag, ADMFLAG_CUSTOM3, "");
	
	RegAdminCmd("sm_punmute", Command_PUNMute, ADMFLAG_CUSTOM5, "");
	RegAdminCmd("sm_pungag", Command_PUNGag, ADMFLAG_CUSTOM5, "");
	
	RegAdminCmd("sm_sunmute", Command_SUNMute, ADMFLAG_CUSTOM3, "");
	RegAdminCmd("sm_sungag", Command_SUNGag, ADMFLAG_CUSTOM3, "");
	
	RegAdminCmd("sm_psilence", Command_PSilence, ADMFLAG_CUSTOM5, "");
	RegAdminCmd("sm_punsilence", Command_PUNSilence, ADMFLAG_CUSTOM5, "");
	
	RegConsoleCmd("sm_ceza", Command_Ceza, "");
	RegConsoleCmd("sm_cezalar", Command_Ceza, "");
	RegConsoleCmd("sm_sdurum", Command_Ceza, "");
	
	AddCommandListener(Filter_Voicerecord, "+voicerecord");
	
	LoadTranslations("common.phrases");
	
	g_dc_webhook = CreateConVar("sm_exbasecomm_webhook", "https://discord.com/api/webhooks/.........../.............", "Discord webhook linkiniz");
	AutoExecConfig(true, "Ex-basecomm", "ByDexter");
	
	LoopClients(i)
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnClientPostAdminCheck(int client)
{
	char sBuffer[20];
	pgag.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) == 1)
	{
		BaseComm_SetClientGag(client, true);
		ClientGag[client] = true;
	}
	else
	{
		ClientGag[client] = false;
		pgag.Set(client, "0");
	}
	pmute.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) == 1)
	{
		Mute(client);
		ClientMute[client] = true;
		BaseComm_SetClientMute(client, true);
	}
	else
	{
		ClientMute[client] = false;
		pmute.Set(client, "0");
	}
	sgag.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		CreateTimer(60.0, SGagAzalt, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		ClientGag[client] = true;
		BaseComm_SetClientGag(client, true);
	}
	else
	{
		ClientGag[client] = false;
		sgag.Set(client, "0");
	}
	smute.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		CreateTimer(60.0, SMuteAzalt, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		Mute(client);
		BaseComm_SetClientMute(client, true);
	}
	else
	{
		ClientMute[client] = false;
		smute.Set(client, "0");
	}
}

public Action Command_Ceza(int client, int args)
{
	if (args == 0)
	{
		Panel panel = new Panel();
		panel.SetTitle("★ Cezaların\n__________________________\n ");
		char sBuffer[128], MenuFormat[128];
		sgag.Get(client, sBuffer, 20);
		if (StringToInt(sBuffer) > 0)
		{
			Format(MenuFormat, 128, "Süreli Gag: %s Dakika", sBuffer);
			panel.DrawText(MenuFormat);
			sgags.Get(client, sBuffer, 128);
			Format(MenuFormat, 128, "Sebep: %s\n ", sBuffer);
			panel.DrawText(MenuFormat);
		}
		else
		{
			panel.DrawText("Süreli Gag: Yok");
		}
		smute.Get(client, sBuffer, 20);
		if (StringToInt(sBuffer) > 0)
		{
			Format(MenuFormat, 128, "Süreli Mute: %s Dakika", sBuffer);
			panel.DrawText(MenuFormat);
			smutes.Get(client, sBuffer, 128);
			Format(MenuFormat, 128, "Sebep: %s\n ", sBuffer);
			panel.DrawText(MenuFormat);
		}
		else
		{
			panel.DrawText("Süreli Mute: Yok");
		}
		panel.DrawText(" ");
		pgag.Get(client, sBuffer, 20);
		if (StringToInt(sBuffer) > 0)
		{
			pgags.Get(client, sBuffer, 128);
			Format(MenuFormat, 128, "Perma Gag: Var\nSebep: %s\n ", sBuffer);
			panel.DrawText(MenuFormat);
		}
		else
		{
			panel.DrawText("Perma Gag: Yok");
		}
		pmute.Get(client, sBuffer, 20);
		if (StringToInt(sBuffer) > 0)
		{
			pmutes.Get(client, sBuffer, 128);
			Format(MenuFormat, 128, "Perma Mute: Var\nSebep: %s\n ", sBuffer);
			panel.DrawText(MenuFormat);
		}
		else
		{
			Format(MenuFormat, 128, "Perma Mute: Yok\n ");
			panel.DrawText(MenuFormat);
		}
		panel.DrawItem("Kapat");
		panel.Send(client, Panel_CallBack, 0);
		delete panel;
		return Plugin_Handled;
	}
	char arg1[128]; GetCmdArg(1, arg1, 128);
	int Hedef = FindTarget(client, arg1, true, true);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	Panel panel = new Panel();
	Format(arg1, 128, "★ %N kişisinin Cezaları\n__________________________\n ", Hedef);
	panel.SetTitle(arg1);
	char sBuffer[128], MenuFormat[128];
	sgag.Get(Hedef, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		Format(MenuFormat, 128, "Süreli Gag: %s Dakika", sBuffer);
		panel.DrawText(MenuFormat);
		sgags.Get(Hedef, sBuffer, 128);
		Format(MenuFormat, 128, "Sebep: %s\n ", sBuffer);
		panel.DrawText(MenuFormat);
	}
	else
	{
		panel.DrawText("Süreli Gag: Yok");
	}
	smute.Get(Hedef, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		Format(MenuFormat, 128, "Süreli Mute: %s Dakika", sBuffer);
		panel.DrawText(MenuFormat);
		smutes.Get(Hedef, sBuffer, 128);
		Format(MenuFormat, 128, "Sebep: %s\n ", sBuffer);
		panel.DrawText(MenuFormat);
	}
	else
	{
		panel.DrawText("Süreli Mute: Yok");
	}
	panel.DrawText(" ");
	pgag.Get(Hedef, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		pgags.Get(Hedef, sBuffer, 128);
		Format(MenuFormat, 128, "Perma Gag: Var\nSebep: %s\n ", sBuffer);
		panel.DrawText(MenuFormat);
	}
	else
	{
		panel.DrawText("Perma Gag: Yok");
	}
	pmute.Get(Hedef, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		pmutes.Get(Hedef, sBuffer, 128);
		Format(MenuFormat, 128, "Perma Mute: Var\nSebep: %s\n ", sBuffer);
		panel.DrawText(MenuFormat);
	}
	else
	{
		Format(MenuFormat, 128, "Perma Mute: Yok\n ");
		panel.DrawText(MenuFormat);
	}
	panel.DrawItem("Kapat");
	panel.Send(client, Panel_CallBack, 0);
	delete panel;
	return Plugin_Handled;
}

public int Panel_CallBack(Menu panel, MenuAction action, int client, int position)
{
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

bool GetCommunityID(char[] AuthID, char[] FriendID, int size)
{
	if (strlen(AuthID) < 11 || AuthID[0] != 'S' || AuthID[6] == 'I')
	{
		FriendID[0] = 0;
		return false;
	}
	int iUpper = 765611979;
	int iFriendID = StringToInt(AuthID[10]) * 2 + 60265728 + AuthID[8] - 48;
	int iDiv = iFriendID / 100000000;
	int iIdx = 9 - (iDiv ? iDiv / 10 + 1:0);
	iUpper += iDiv;
	IntToString(iFriendID, FriendID[iIdx], size - iIdx);
	iIdx = FriendID[9];
	IntToString(iUpper, FriendID, size);
	FriendID[9] = iIdx;
	return true;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (ClientGag[client])
	{
		PrintToChat(client, "[SM] Cezalı olduğun için yazı yazamazsın.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Filter_Voicerecord(int client, const char[] command, int argc)
{
	if (ClientMute[client])
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void UnMute(int client)
{
	static ConVar cvDeadTalk = null;
	
	if (cvDeadTalk == null) {
		cvDeadTalk = FindConVar("sm_deadtalk");
	}
	
	if (cvDeadTalk == null) {
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
	else {
		if (cvDeadTalk.IntValue == 1 && !IsPlayerAlive(client)) {
			SetClientListeningFlags(client, VOICE_LISTENALL);
		}
		else if (cvDeadTalk.IntValue == 2 && !IsPlayerAlive(client)) {
			SetClientListeningFlags(client, VOICE_TEAM);
		}
		else {
			SetClientListeningFlags(client, VOICE_NORMAL);
		}
	}
	BaseComm_SetClientMute(client, false);
	ClientMute[client] = false;
}

void Mute(int client)
{
	SetClientListeningFlags(client, VOICE_MUTED);
	BaseComm_SetClientMute(client, true);
	ClientMute[client] = true;
} 