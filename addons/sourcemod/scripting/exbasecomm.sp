#include <sourcemod>
#include <clientprefs>
#include <sdktools_voice>
#include <discord>

#pragma semicolon 1
#pragma newdecls required

ConVar g_dc_webhook = null;
Cookie pgag = null, pmute = null, sgag = null, smute = null, 
pgags = null, pmutes = null, sgags = null, smutes = null;

bool ClientGag[65] = { false, ... };

public Plugin myinfo = 
{
	name = "Gelişmiş Basecomm", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
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
	
	LoadTranslations("common.phrases");
	
	g_dc_webhook = CreateConVar("sm_exbasecomm_webhook", "https://discord.com/api/webhooks/.........../.............", "Discord webhook linkiniz");
	AutoExecConfig(true, "Ex-basecomm", "ByDexter");
	
	LoopClients(i)
	{
		OnClientPostAdminCheck(i);
	}
}

public Action Command_PUNSilence(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_punsilence <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	pgag.Set(Hedef, "0");
	pmute.Set(Hedef, "0");
	ClientGag[Hedef] = false;
	UnMute(Hedef);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından PSilenceı kalktı.", Hedef, client);
	SendDiscordPUNSilence(client, Hedef);
	return Plugin_Handled;
}

void SendDiscordPUNSilence(int client, int target)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Silence");
	
	hook.Send();
	delete hook;
}

public Action Command_PSilence(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_psilence <Hedef> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	pmute.Set(Hedef, "1");
	pgag.Set(Hedef, "1");
	
	char Arg2[128];
	GetCmdArg(2, Arg2, 128);
	pmutes.Set(Hedef, Arg2);
	pgags.Set(Hedef, Arg2);
	Mute(Hedef);
	ClientGag[Hedef] = true;
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x01PSilence yedi", Hedef, client, Arg2);
	SendDiscordPSilence(client, Hedef, Arg2);
	return Plugin_Handled;
}

void SendDiscordPSilence(int client, int target, char Arg2[128])
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", Arg2, true);
	Embed.AddField(":globe_with_meridians: Süre:", "Kalıcı", true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Silence");
	
	hook.Send();
	delete hook;
}

public Action Command_Ceza(int client, int args)
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

public int Panel_CallBack(Menu panel, MenuAction action, int client, int position)
{
}

public Action Command_SUNGag(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sungag <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	sgag.Set(Hedef, "-3");
	ClientGag[Hedef] = false;
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından SGagı kalktı.", Hedef, client);
	SendDiscordSUNGag(client, Hedef);
	return Plugin_Handled;
}

void SendDiscordSUNGag(int client, int target)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Gag");
	
	hook.Send();
	delete hook;
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

public Action Command_SUNMute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sunmute <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	smute.Set(Hedef, "-3");
	UnMute(Hedef);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından SMutesi kalktı.", Hedef, client);
	SendDiscordSUNMute(client, Hedef);
	return Plugin_Handled;
}

void SendDiscordSUNMute(int client, int target)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Mute");
	
	hook.Send();
	delete hook;
}

public Action Command_PUNMute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_punmute <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	pmute.Set(Hedef, "0");
	UnMute(Hedef);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından PMutesi kalktı.", Hedef, client);
	SendDiscordPUNMute(client, Hedef);
	return Plugin_Handled;
}

void SendDiscordPUNMute(int client, int target)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Mute");
	
	hook.Send();
	delete hook;
}

public Action Command_PUNGag(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pungag <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	pgag.Set(Hedef, "0");
	ClientGag[Hedef] = false;
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından PGagı kalktı.", Hedef, client);
	SendDiscordPUNGag(client, Hedef);
	return Plugin_Handled;
}

void SendDiscordPUNGag(int client, int target)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#00a3ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Cezası Kaldırılan:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Gag");
	
	hook.Send();
	delete hook;
}

public Action Command_PGag(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pgag <Hedef> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	pgag.Set(Hedef, "1");
	
	char Arg2[128];
	GetCmdArg(2, Arg2, 128);
	pgags.Set(Hedef, Arg2);
	ClientGag[Hedef] = true;
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x01PGag yedi", Hedef, client, Arg2);
	SendDiscordPGag(client, Hedef, Arg2);
	return Plugin_Handled;
}

void SendDiscordPGag(int client, int target, char Arg2[128])
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", Arg2, true);
	Embed.AddField(":globe_with_meridians: Süre:", "Kalıcı", true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Gag");
	
	hook.Send();
	delete hook;
}

public Action Command_PMute(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pmute <Hedef> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	pmute.Set(Hedef, "1");
	
	char Arg2[128];
	GetCmdArg(2, Arg2, 128);
	pmutes.Set(Hedef, Arg2);
	Mute(Hedef);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x01PMute yedi", Hedef, client, Arg2);
	SendDiscordPMute(client, Hedef, Arg2);
	return Plugin_Handled;
}

void SendDiscordPMute(int client, int target, char Arg2[128])
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", Arg2, true);
	Embed.AddField(":globe_with_meridians: Süre:", "Kalıcı", true);
	hook.Embed(Embed);
	hook.SetUsername("Perma Mute");
	
	hook.Send();
	delete hook;
}

public Action Command_SGag(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sgag <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1)
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	char Arg2[20];
	GetCmdArg(2, Arg2, 20);
	if (StringToInt(Arg2) <= 0)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sgag <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	Format(Arg2, 20, "%d", StringToInt(Arg2));
	sgag.Set(Hedef, Arg2);
	
	char Arg3[128];
	GetCmdArg(3, Arg3, 128);
	sgags.Set(Hedef, Arg3);
	
	ClientGag[Hedef] = true;
	CreateTimer(60.0, SGagAzalt, GetClientUserId(Hedef), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x04%d Dakika \x01Gag yedi", Hedef, client, Arg3, StringToInt(Arg2));
	SendDiscordSGag(client, Hedef, StringToInt(Arg2), Arg3);
	return Plugin_Handled;
}

void SendDiscordSGag(int client, int target, int Arg2, char Arg3[128])
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", Arg3, true);
	Format(EmbedFormat, 256, "%d Dakika", Arg2);
	Embed.AddField(":globe_with_meridians: Süre:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Gag");
	
	hook.Send();
	delete hook;
}

public Action SGagAzalt(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client))
	{
		char sBuffer[20];
		sgag.Get(client, sBuffer, 20);
		int Sure = StringToInt(sBuffer);
		Sure--;
		if (Sure <= 0)
		{
			PrintToChat(client, "[SM] \x04Süreli Gagın \x01sona erdi.");
			if (Sure > -2)
				FinishGag(client);
			
			sgag.Set(client, "-3");
			ClientGag[client] = false;
			return Plugin_Stop;
		}
		else
		{
			FormatEx(sBuffer, 20, "%d", Sure);
			sgag.Set(client, sBuffer);
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Stop;
	}
}

void FinishGag(int client)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#ebd234");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_orange_diamond: Cezası Biten:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Gag");
	
	hook.Send();
	delete hook;
}

public Action Command_SMute(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_smute <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, false);
	
	if (Hedef == -1)
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	char Arg2[20];
	GetCmdArg(2, Arg2, 20);
	if (StringToInt(Arg2) <= 0)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_smute <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	Format(Arg2, 20, "%d", StringToInt(Arg2));
	smute.Set(Hedef, Arg2);
	
	char Arg3[128];
	GetCmdArg(3, Arg3, 128);
	smutes.Set(Hedef, Arg3);
	
	Mute(Hedef);
	CreateTimer(60.0, SMuteAzalt, GetClientUserId(Hedef), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x04%d Dakika \x01Mute yedi", Hedef, client, Arg3, StringToInt(Arg2));
	SendDiscordSMute(client, Hedef, StringToInt(Arg2), Arg3);
	return Plugin_Handled;
}

void SendDiscordSMute(int client, int target, int Arg2, char Arg3[128])
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	
	char TargetSteamid[128];
	GetClientAuthId(target, AuthId_Steam2, TargetSteamid, 128);
	char TargetName[128];
	GetClientName(target, TargetName, 128);
	char TargetSteam[128];
	GetCommunityID(TargetSteamid, TargetSteam, 128);
	Format(TargetSteam, 128, "http://steamcommunity.com/profiles/%s", TargetSteam);
	
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#a300ff");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_blue_diamond: Yetkili:", EmbedFormat, true);
	Format(EmbedFormat, 256, "%s \n [%s](%s)", TargetName, TargetSteamid, TargetSteam);
	Embed.AddField(":small_orange_diamond: Ceza Alan:", EmbedFormat, true);
	Embed.AddField(" ", " ", false);
	Embed.AddField(":receipt: Sebep:", Arg3, true);
	Format(EmbedFormat, 256, "%d Dakika", Arg2);
	Embed.AddField(":globe_with_meridians: Süre:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Mute");
	
	hook.Send();
	delete hook;
}

public Action SMuteAzalt(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client))
	{
		char sBuffer[20];
		smute.Get(client, sBuffer, 20);
		int Sure = StringToInt(sBuffer);
		Sure--;
		if (Sure <= 0)
		{
			PrintToChat(client, "[SM] \x04Süreli Muten \x01sona erdi.");
			if (Sure > -2)
				FinishMute(client);
			
			smute.Set(client, "-3");
			UnMute(client);
			return Plugin_Stop;
		}
		else
		{
			FormatEx(sBuffer, 20, "%d", Sure);
			smute.Set(client, sBuffer);
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Stop;
	}
}

void FinishMute(int client)
{
	char webhook[1024];
	g_dc_webhook.GetString(webhook, sizeof(webhook));
	
	char ClientSteamid[128];
	GetClientAuthId(client, AuthId_Steam2, ClientSteamid, 128);
	char ClientName[128];
	GetClientName(client, ClientName, 128);
	char ClientSteam[128];
	GetCommunityID(ClientSteamid, ClientSteam, 128);
	Format(ClientSteam, 128, "http://steamcommunity.com/profiles/%s", ClientSteam);
	char EmbedFormat[256];
	DiscordWebHook hook = new DiscordWebHook(webhook);
	hook.SlackMode = true;
	MessageEmbed Embed = new MessageEmbed();
	Embed.SetColor("#ebd234");
	Embed.SetFooter("-ByDexter");
	Format(EmbedFormat, 256, "%s \n [%s](%s)", ClientName, ClientSteamid, ClientSteam);
	Embed.AddField(":small_orange_diamond: Cezası Biten:", EmbedFormat, true);
	hook.Embed(Embed);
	hook.SetUsername("Süreli Mute");
	
	hook.Send();
	delete hook;
}

public void OnClientPostAdminCheck(int client)
{
	char sBuffer[20];
	pgag.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		ClientGag[client] = true;
	}
	else
	{
		pgag.Set(client, "0");
	}
	pmute.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		Mute(client);
	}
	else
	{
		pmute.Set(client, "0");
	}
	sgag.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		CreateTimer(60.0, SGagAzalt, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		ClientGag[client] = true;
	}
	else
	{
		sgag.Set(client, "0");
	}
	smute.Get(client, sBuffer, 20);
	if (StringToInt(sBuffer) > 0)
	{
		CreateTimer(60.0, SMuteAzalt, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		Mute(client);
	}
	else
	{
		smute.Set(client, "0");
	}
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
}

void Mute(int client)
{
	SetClientListeningFlags(client, VOICE_MUTED);
} 