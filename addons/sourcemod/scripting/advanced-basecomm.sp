#include <sourcemod>
#include <sdktools_voice>
#include <basecomm>
#include <discord>

#pragma semicolon 1
#pragma newdecls required

char sPath[256];
bool Muted[65] = { false, ... }, Gagged[65] = { false, ... };
char webhook[256]; ConVar _webhook = null; public void _webhookchange(ConVar convar, const char[] oldValue, const char[] newValue) { _webhook.GetString(webhook, 256); }

public Plugin myinfo = 
{
	name = "Gelişmiş Gag/Mute İşlemleri", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
	
	RegConsoleCmd("sm_ceza", Command_ceza, "sm_ceza");
	
	RegAdminCmd("sm_sgag", Command_sgag, ADMFLAG_SLAY, "sm_sgag <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sungag", Command_sungag, ADMFLAG_SLAY, "sm_sungag <#userid|name>");
	
	RegAdminCmd("sm_pgag", Command_pgag, ADMFLAG_BAN, "sm_pgag <#userid|name> [sebep]");
	RegAdminCmd("sm_pungag", Command_pungag, ADMFLAG_BAN, "sm_pungag <#userid|name>");
	
	RegAdminCmd("sm_smute", Command_smute, ADMFLAG_SLAY, "sm_smute <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sunmute", Command_sunmute, ADMFLAG_SLAY, "sm_sunmute <#userid|name>");
	
	RegAdminCmd("sm_pmute", Command_pmute, ADMFLAG_BAN, "sm_pmute <#userid|name> [sebep]");
	RegAdminCmd("sm_punmute", Command_punmute, ADMFLAG_BAN, "sm_punmute <#userid|name>");
	
	RegAdminCmd("sm_ssilence", Command_ssilence, ADMFLAG_SLAY, "sm_ssilence <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sunsilence", Command_sunsilence, ADMFLAG_SLAY, "sm_sunsilence <#userid|name>");
	
	RegAdminCmd("sm_psilence", Command_psilence, ADMFLAG_BAN, "sm_psilence <#userid|name> [sebep]");
	RegAdminCmd("sm_punsilence", Command_punsilence, ADMFLAG_BAN, "sm_punmute <#userid|name>");
	
	BuildPath(Path_SM, sPath, 256, "data/advanced-basecomm.ini");
	
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
	{
		OnClientPostAdminCheck(i);
	}
	
	_webhook = CreateConVar("advanced-basecomm_dc_webhook", "https://discord.com/api/webhooks/................./.................");
	_webhook.GetString(webhook, 256);
	_webhook.AddChangeHook(_webhookchange);
	
	AutoExecConfig(true, "Advanced-Basecomm", "ByDexter");
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnClientPostAdminCheck(int client)
{
	Gagged[client] = false; Muted[client] = false;
	char format[128];
	GetClientAuthId(client, AuthId_Steam2, format, 128);
	BaseComm_SetClientGag(client, false); BaseComm_SetClientMute(client, false);
	
	KeyValues kv = new KeyValues("ByDexter");
	kv.ImportFromFile(sPath);
	
	kv.JumpToKey(format, true);
	
	GetClientName(client, format, 128);
	kv.SetString("lastname", format);
	
	FormatTime(format, 128, "%T - %F", GetTime());
	kv.SetString("lastjoin", format);
	
	int time = kv.GetNum("pgag", 0);
	if (time >= 1)
	{
		Gagged[client] = true;
		BaseComm_SetClientGag(client, true);
	}
	else
	{
		kv.SetNum("pgag", 0);
	}
	
	if (!Gagged[client])
	{
		time = kv.GetNum("gagtime", 0);
		if (time >= 1)
		{
			Gagged[client] = true;
			BaseComm_SetClientGag(client, true);
			CreateTimer(60.0, GagTimer, client, TIMER_REPEAT);
		}
		else
		{
			kv.SetNum("gagtime", 0);
		}
	}
	
	time = kv.GetNum("pmute", 0);
	if (time >= 1)
	{
		Muted[client] = true;
		Mute(client);
	}
	else
	{
		kv.SetNum("pmute", 0);
	}
	
	if (!Muted[client])
	{
		time = kv.GetNum("mutetime", 0);
		if (time >= 1)
		{
			Muted[client] = true;
			Mute(client);
			CreateTimer(60.0, MuteTimer, client, TIMER_REPEAT);
		}
		else
		{
			kv.SetNum("mutetime", 0);
		}
	}
	
	kv.Rewind();
	kv.ExportToFile(sPath);
	delete kv;
}

public Action Command_ceza(int client, int args)
{
	int target;
	Panel panel = new Panel();
	if (args == 0)
	{
		target = client;
		panel.SetTitle("★ Cezaların\n__________________________\n ");
	}
	else
	{
		char arg[256];
		GetCmdArgString(arg, 256);
		target = FindTarget(client, arg, true, false);
		if (target == -1)
		{
			return Plugin_Handled;
		}
		GetClientName(target, arg, 256);
		FixText(arg, 256);
		Format(arg, 256, "★ %s Cezaları\n__________________________\n ", arg);
		panel.SetTitle(arg);
	}
	char format[128];
	GetClientAuthId(target, AuthId_Steam2, format, 128);
	
	KeyValues kv = new KeyValues("ByDexter");
	kv.ImportFromFile(sPath);
	
	kv.JumpToKey(format, true);
	
	GetClientName(target, format, 128);
	kv.SetString("lastname", format);
	
	FormatTime(format, 128, "%T - %F", GetTime());
	kv.SetString("lastjoin", format);
	
	int time = kv.GetNum("pgag", 0);
	if (time >= 1)
	{
		kv.GetString("pgagreason", format, 128);
		Format(format, 128, "Perma Gag: Var\nSebep: %s\n ", format);
		panel.DrawText(format);
	}
	else
	{
		time = kv.GetNum("gagtime", 0);
		if (time >= 1)
		{
			kv.GetString("gagreason", format, 128);
			Format(format, 128, "Süreli Gag: %d dakika\nSebep: %s\n ", time, format);
			panel.DrawText(format);
		}
		else
		{
			panel.DrawText("Perma/Süreli Gag: Yok\n ");
		}
	}
	
	time = kv.GetNum("pmute", 0);
	if (time >= 1)
	{
		kv.GetString("pmutereason", format, 128);
		Format(format, 128, "Perma Mute: Var\nSebep: %s\n ", format);
		panel.DrawText(format);
	}
	else
	{
		time = kv.GetNum("mutetime", 0);
		if (time >= 1)
		{
			kv.GetString("mutereason", format, 128);
			Format(format, 128, "Süreli Mute: %d dakika\nSebep: %s\n ", time, format);
			panel.DrawText(format);
		}
		else
		{
			panel.DrawText("Perma/Süreli Mute: Yok\n ");
		}
	}
	panel.DrawItem("Kapat");
	panel.Send(client, Panel_CallBack, 15);
	delete panel;
	return Plugin_Handled;
}

public int Panel_CallBack(Menu panel, MenuAction action, int client, int position)
{
}

public Action Command_sgag(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sgag <#userid|name> <dakika|1> [sebep]");
		return Plugin_Handled;
	}
	
	int len, next_len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	char s_time[12];
	if ((next_len = BreakString(Arguments[len], s_time, sizeof(s_time))) != -1)
	{
		len += next_len;
	}
	else
	{
		len = 0;
		Arguments[0] = '0';
	}
	
	int time = StringToInt(s_time);
	if (time <= 0)
	{
		time = 1;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika gag yedi.", target, Arguments[len], time);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika gag yedi.", target, client, Arguments[len], time);
	
	CezaVer(target, client, time, Arguments[len], 1, false);
	return Plugin_Handled;
}

public Action Command_sungag(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sungag <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından süreli gagı kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından süreli gagı kaldırıldı.", target, client);
	
	CezaAl(target, client, 1, false);
	return Plugin_Handled;
}

public Action Command_pgag(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pgag <#userid|name> [sebep]");
		return Plugin_Handled;
	}
	
	int len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01gag yedi.", target, Arguments[len]);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01gag yedi.", target, client, Arguments[len]);
	
	CezaVer(target, client, 0, Arguments[len], 1, true);
	return Plugin_Handled;
}

public Action Command_pungag(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pungag <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından perma gagı kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından perma gagı kaldırıldı.", target, client);
	
	CezaAl(target, client, 1, true);
	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (Gagged[client])
	{
		PrintToChat(client, "[SM] \x07Hata: \x01Cezalı olduğu için mesaj iletilmedi. \x10!ceza");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action GagTimer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		char format[128];
		GetClientAuthId(client, AuthId_Steam2, format, 128);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(format, true);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		int time = kv.GetNum("gagtime", 0);
		time--;
		kv.SetNum("gagtime", time);
		if (time <= 0)
		{
			Gagged[client] = false;
			if (time == 0)
			{
				PrintToChatAll("[SM] \x10%N \x01süreli gagı sona erdi.", client);
				DiscordWebHook hook = new DiscordWebHook(webhook);
				hook.SlackMode = true;
				
				MessageEmbed Embed = new MessageEmbed();
				Embed.SetColor("#fb9c31");
				Embed.SetTitleLink("https://steamcommunity.com/groups/SiriusJB");
				Embed.SetTitle("Gag");
				char format2[256], steamid[32];
				GetClientName(client, format, 128);
				FixText(format, 128);
				GetClientAuthId(client, AuthId_Steam2, steamid, 32);
				GetCommunityID(steamid, format2, 256);
				Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
				Embed.AddField(":partying_face: Masum", format2, true);
				hook.Embed(Embed);
				hook.Send();
				delete hook;
				kv.Rewind();
				kv.ExportToFile(sPath);
				delete kv;
				BaseComm_SetClientGag(client, false);
			}
			return Plugin_Stop;
		}
		else
		{
			if (time % 5 == 0)
			{
				PrintToChat(client, "[SM] Süreli gagın bitmesine \x04%d dakika\x01sı kaldı.", time);
			}
			Gagged[client] = true;
			BaseComm_SetClientGag(client, true);
		}
		
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Command_smute(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_smute <#userid|name> <dakika|1> [sebep]");
		return Plugin_Handled;
	}
	
	int len, next_len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	char s_time[12];
	if ((next_len = BreakString(Arguments[len], s_time, sizeof(s_time))) != -1)
	{
		len += next_len;
	}
	else
	{
		len = 0;
		Arguments[0] = '0';
	}
	
	int time = StringToInt(s_time);
	if (time <= 0)
	{
		time = 1;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika mute yedi.", target, Arguments[len], time);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika mute yedi.", target, client, Arguments[len], time);
	
	CezaVer(target, client, time, Arguments[len], 2, false);
	return Plugin_Handled;
}

public Action Command_sunmute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sunmute <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından süreli mutesi kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından süreli mutesi kaldırıldı.", target, client);
	
	CezaAl(target, client, 2, false);
	return Plugin_Handled;
}

public Action Command_pmute(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pmute <#userid|name> [sebep]");
		return Plugin_Handled;
	}
	
	int len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01mute yedi.", target, Arguments[len]);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01mute yedi.", target, client, Arguments[len]);
	
	CezaVer(target, client, 0, Arguments[len], 2, true);
	return Plugin_Handled;
}

public Action Command_punmute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_punmute <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından perma mutesi kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından perma mutesi kaldırıldı.", target, client);
	
	CezaAl(target, client, 2, true);
	return Plugin_Handled;
}

public Action MuteTimer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		char format[128];
		GetClientAuthId(client, AuthId_Steam2, format, 128);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(format, true);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		int time = kv.GetNum("mutetime", 0);
		time--;
		kv.SetNum("mutetime", time);
		if (time <= 0)
		{
			Muted[client] = false;
			UnMute(client);
			if (time == 0)
			{
				PrintToChatAll("[SM] \x10%N \x01süreli mutesi sona erdi.", client);
				DiscordWebHook hook = new DiscordWebHook(webhook);
				hook.SlackMode = true;
				
				MessageEmbed Embed = new MessageEmbed();
				Embed.SetColor("#fb9c31");
				Embed.SetTitleLink("https://steamcommunity.com/groups/SiriusJB");
				Embed.SetTitle("Mute");
				char format2[256], steamid[32];
				GetClientName(client, format, 128);
				FixText(format, 128);
				GetClientAuthId(client, AuthId_Steam2, steamid, 32);
				GetCommunityID(steamid, format2, 256);
				Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
				Embed.AddField(":partying_face: Masum", format2, true);
				hook.Embed(Embed);
				hook.Send();
				delete hook;
				kv.Rewind();
				kv.ExportToFile(sPath);
				delete kv;
			}
			return Plugin_Stop;
		}
		else
		{
			if (time % 5 == 0)
			{
				PrintToChat(client, "[SM] Süreli mutenin bitmesine \x04%d dakika\x01sı kaldı.", time);
			}
			Muted[client] = true;
			Mute(client);
		}
		
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Command_psilence(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_psilence <#userid|name> [sebep]");
		return Plugin_Handled;
	}
	
	int len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01silence yedi.", target, Arguments[len]);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04Kalıcı \x01silence yedi.", target, client, Arguments[len]);
	
	CezaVer(target, client, 0, Arguments[len], 3, true);
	return Plugin_Handled;
}

public Action Command_punsilence(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_punsilence <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından perma silenceı kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından perma silenceı kaldırıldı.", target, client);
	
	CezaAl(target, client, 3, true);
	return Plugin_Handled;
}

public Action Command_ssilence(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_ssilence <#userid|name> <dakika|1> [sebep]");
		return Plugin_Handled;
	}
	
	int len, next_len;
	char Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));
	
	char arg[65];
	len = BreakString(Arguments, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	char s_time[12];
	if ((next_len = BreakString(Arguments[len], s_time, sizeof(s_time))) != -1)
	{
		len += next_len;
	}
	else
	{
		len = 0;
		Arguments[0] = '0';
	}
	
	int time = StringToInt(s_time);
	if (time <= 0)
	{
		time = 1;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika silence yedi.", target, Arguments[len], time);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s \x01nedeniyle \x04%d \x01dakika silence yedi.", target, client, Arguments[len], time);
	
	CezaVer(target, client, time, Arguments[len], 3, false);
	return Plugin_Handled;
}

public Action Command_sunsilence(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sunsilence <#userid|name>");
		return Plugin_Handled;
	}
	
	char arg[65];
	GetCmdArgString(arg, 65);
	
	int target = FindTarget(client, arg, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	if (client == 0)
		PrintToChatAll("[SM] \x10%N\x01, \x10Panel \x01tarafından süreli silenceı kaldırıldı.", target);
	else
		PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından süreli silenceı kaldırıldı.", target, client);
	
	CezaAl(target, client, 3, false);
	return Plugin_Handled;
}

void CezaVer(int client, int admin, int time, const char[] reason, int ceza, bool perma = false)
{
	if (IsValidClient(client))
	{
		DiscordWebHook hook = new DiscordWebHook(webhook);
		hook.SlackMode = true;
		
		MessageEmbed Embed = new MessageEmbed();
		Embed.SetColor("#cc00ff");
		Embed.SetTitleLink("https://steamcommunity.com/groups/SiriusJB");
		
		char format[128], steamid[32];
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(steamid, true);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		if (ceza == 1) // Gag
		{
			if (perma)
			{
				Embed.SetTitle("PermaGag");
				kv.SetNum("pgag", 1);
				kv.SetString("pgagreason", reason);
			}
			else
			{
				Embed.SetTitle("Gag");
				kv.SetNum("gagtime", time);
				kv.SetString("gagreason", reason);
			}
		}
		else if (ceza == 2) // Mute
		{
			if (perma)
			{
				Embed.SetTitle("PermaMute");
				kv.SetNum("pmute", 1);
				kv.SetString("pmutereason", reason);
			}
			else
			{
				Embed.SetTitle("Mute");
				kv.SetNum("mutetime", time);
				kv.SetString("mutereason", reason);
			}
		}
		else if (ceza == 3) // Silence
		{
			if (perma)
			{
				Embed.SetTitle("PermaSilence");
				kv.SetNum("pgag", 1);
				kv.SetString("pgagreason", reason);
				kv.SetNum("pmute", 1);
				kv.SetString("pmutereason", reason);
			}
			else
			{
				Embed.SetTitle("Silence");
				kv.SetNum("gagtime", time);
				kv.SetString("gagreason", reason);
				kv.SetNum("mutetime", time);
				kv.SetString("mutereason", reason);
			}
		}
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
		
		char format2[256];
		if (admin == 0)
		{
			Embed.AddField(":beginner: Admin", "[Panel](https://store.steampowered.com/app/730/CounterStrike_Global_Offensive/)\n```BOT```", true);
		}
		else
		{
			GetClientAuthId(admin, AuthId_Steam2, steamid, 32);
			GetCommunityID(steamid, format2, 256);
			GetClientName(admin, format, 128);
			FixText(format, 128);
			Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
			Embed.AddField(":beginner: Admin", format2, true);
		}
		
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		GetCommunityID(steamid, format2, 256);
		GetClientName(client, format, 128);
		FixText(format, 128);
		Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
		Embed.AddField(":no_pedestrians: Suçlu", format2, true);
		
		Embed.AddField("", "", false);
		
		Format(format2, 256, "```%s```", reason);
		Embed.AddField(":dart: Sebep", format2, true);
		
		if (time >= 1)
		{
			Format(format2, 256, "```%d dakika```", time);
			Embed.AddField(":clock1: Süre", format2, true);
		}
		else
		{
			Format(format2, 256, "```Kalıcı```", time);
			Embed.AddField(":clock1: Süre", format2, true);
		}
		
		hook.Embed(Embed);
		hook.Send();
		delete hook;
		OnClientPostAdminCheck(client);
	}
}

void CezaAl(int client, int admin, int ceza, bool perma = false)
{
	if (IsValidClient(client))
	{
		DiscordWebHook hook = new DiscordWebHook(webhook);
		hook.SlackMode = true;
		
		MessageEmbed Embed = new MessageEmbed();
		Embed.SetColor("#31fb31");
		Embed.SetTitleLink("https://steamcommunity.com/groups/SiriusJB");
		
		char format[128], steamid[32];
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(steamid, true);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		if (ceza == 1) // Gag
		{
			if (perma)
			{
				Embed.SetTitle("PermaUnGag");
				kv.SetNum("pgag", 0);
			}
			else
			{
				Embed.SetTitle("UnGag");
				kv.SetNum("gagtime", -1);
			}
		}
		else if (ceza == 2) // Mute
		{
			if (perma)
			{
				Embed.SetTitle("PermaUnMute");
				kv.SetNum("pmute", 0);
			}
			else
			{
				Embed.SetTitle("UnMute");
				kv.SetNum("mutetime", -1);
			}
		}
		else if (ceza == 3) // Silence
		{
			if (perma)
			{
				Embed.SetTitle("PermaUnSilence");
				kv.SetNum("pgag", 0);
				kv.SetNum("pmute", 0);
			}
			else
			{
				Embed.SetTitle("UnSilence");
				kv.SetNum("gagtime", -1);
				kv.SetNum("mutetime", -1);
			}
		}
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
		
		char format2[256];
		if (admin == 0)
		{
			Embed.AddField(":beginner: Admin", "[Panel](https://store.steampowered.com/app/730/CounterStrike_Global_Offensive/)\n```BOT```", true);
		}
		else
		{
			GetClientAuthId(admin, AuthId_Steam2, steamid, 32);
			GetCommunityID(steamid, format2, 256);
			GetClientName(admin, format, 128);
			FixText(format, 128);
			Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
			Embed.AddField(":beginner: Admin", format2, true);
		}
		
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		GetCommunityID(steamid, format2, 256);
		GetClientName(client, format, 128);
		FixText(format, 128);
		Format(format2, 256, "[%s](http://steamcommunity.com/profiles/%s)\n```%s```", format, format2, steamid);
		Embed.AddField(":no_pedestrians: Suçlu", format2, true);
		
		Embed.AddField("", "", false);
		
		hook.Embed(Embed);
		hook.Send();
		delete hook;
		OnClientPostAdminCheck(client);
	}
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

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

void Mute(int client)
{
	SetClientListeningFlags(client, VOICE_MUTED);
	BaseComm_SetClientMute(client, true);
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
}

public void BaseComm_OnClientMute(int client, bool muteState)
{
	if (!muteState && Muted[client])
	{
		Mute(client);
		PrintToChatAll("[SM] \x07Hata\x01: %N kişisinin mutesi açılamadı, cezasıbulunmakta.\x10!ceza", client);
	}
}

public void BaseComm_OnClientGag(int client, bool gagState)
{
	if (!gagState && Gagged[client])
	{
		BaseComm_SetClientGag(client, true);
		PrintToChatAll("[SM] \x07Hata\x01: %N kişisinin gagı açılamadı, cezasıbulunmakta.\x10!ceza", client);
	}
}

bool FixText(char[] Fix, int size)
{
	if (size <= 0)
	{
		return false;
	}
	ReplaceString(Fix, size, "/", "", false);
	ReplaceString(Fix, size, "`", "", false);
	ReplaceString(Fix, size, "*", "", false);
	ReplaceString(Fix, size, "[", "", false);
	ReplaceString(Fix, size, "]", "", false);
	ReplaceString(Fix, size, "(", "", false);
	ReplaceString(Fix, size, ")", "", false);
	ReplaceString(Fix, size, "|", "", false);
	ReplaceString(Fix, size, "_", "", false);
	ReplaceString(Fix, size, "\"", "'", false);
	ReplaceString(Fix, size, "\\", "", false);
	ReplaceString(Fix, size, "~", "", false);
	return true;
}