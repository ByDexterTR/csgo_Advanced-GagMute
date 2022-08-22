#include <sourcemod>
#include <steamworks>
#include <basecomm>

#pragma semicolon 1
#pragma newdecls required

Handle TimerGag[65] = { null, ... }, TimerMute[65] = { null, ... };
char sPath[256];
bool Muted[65] = { false, ... }, Gagged[65] = { false, ... };
char webhook[256]; ConVar _webhook = null; public void _webhookchange(ConVar convar, const char[] oldValue, const char[] newValue) { _webhook.GetString(webhook, 256); }

public Plugin myinfo = 
{
	name = "Gelişmiş Gag/Mute İşlemleri", 
	author = "ByDexter", 
	description = "", 
	version = "1.2", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("sm_ceza", Command_ceza, "sm_ceza <#userid|name>");
	
	RegAdminCmd("sm_sgag", Command_sgag, ADMFLAG_CHAT, "sm_sgag <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sungag", Command_sungag, ADMFLAG_CHAT, "sm_sungag <#userid|name>");
	
	RegAdminCmd("sm_pgag", Command_pgag, ADMFLAG_CHAT, "sm_pgag <#userid|name> [sebep]");
	RegAdminCmd("sm_pungag", Command_pungag, ADMFLAG_CHAT, "sm_pungag <#userid|name>");
	
	RegAdminCmd("sm_smute", Command_smute, ADMFLAG_CHAT, "sm_smute <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sunmute", Command_sunmute, ADMFLAG_CHAT, "sm_sunmute <#userid|name>");
	
	RegAdminCmd("sm_pmute", Command_pmute, ADMFLAG_CHAT, "sm_pmute <#userid|name> [sebep]");
	RegAdminCmd("sm_punmute", Command_punmute, ADMFLAG_CHAT, "sm_punmute <#userid|name>");
	
	RegAdminCmd("sm_ssilence", Command_ssilence, ADMFLAG_CHAT, "sm_ssilence <#userid|name> <dakika|1> [sebep]");
	RegAdminCmd("sm_sunsilence", Command_sunsilence, ADMFLAG_CHAT, "sm_sunsilence <#userid|name>");
	
	RegAdminCmd("sm_psilence", Command_psilence, ADMFLAG_CHAT, "sm_psilence <#userid|name> [sebep]");
	RegAdminCmd("sm_punsilence", Command_punsilence, ADMFLAG_CHAT, "sm_punmute <#userid|name>");
	
	BuildPath(Path_SM, sPath, 256, "data/advanced-basecomm.ini");
	
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
	{
		OnClientPostAdminCheck(i);
	}
	
	_webhook = CreateConVar("advanced-basecomm_dc_webhook", "https://discord.com/api/webhooks/..................../..................", "", FCVAR_PROTECTED);
	_webhook.GetString(webhook, 256);
	_webhook.AddChangeHook(_webhookchange);
	
	AutoExecConfig(true, "Advanced-Basecomm", "ByDexter");
}

public void OnMapStart()
{
	char sBuffer[32];
	KeyValues kv = new KeyValues("ByDexter");
	kv.ImportFromFile(sPath);
	if (kv.GotoFirstSubKey())
	{
		do
		{
			if (kv.GetSectionName(sBuffer, 32))
			{
				kv.JumpToKey(sBuffer, false);
				if (kv.GetNum("pgag", 0) <= 0)
				{
					if (kv.GetNum("gagtime", 0) <= 0)
					{
						if (kv.GetNum("pmute", 0) <= 0)
						{
							if (kv.GetNum("mutetime", 0) <= 0)
							{
								kv.Rewind();
								kv.JumpToKey(sBuffer, false);
								kv.DeleteThis();
							}
						}
					}
				}
			}
		}
		while (kv.GotoNextKey());
	}
	kv.Rewind();
	kv.ExportToFile(sPath);
	delete kv;
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
	if (TimerGag[client] != null)
	{
		delete TimerGag[client];
		TimerGag[client] = null;
	}
	if (TimerMute[client] != null)
	{
		delete TimerMute[client];
		TimerMute[client] = null;
	}
	Gagged[client] = false;
	Muted[client] = false;
	char format[128];
	GetClientAuthId(client, AuthId_Steam2, format, 128);
	BaseComm_SetClientGag(client, false);
	BaseComm_SetClientMute(client, false);
	
	KeyValues kv = new KeyValues("ByDexter");
	kv.ImportFromFile(sPath);
	
	if (kv.JumpToKey(format, false))
	{
		GetClientName(client, format, 128);
		FixText(format, 128);
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
				TimerGag[client] = CreateTimer(60.0, GagTimer, client, TIMER_REPEAT);
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
			BaseComm_SetClientMute(client, true);
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
				BaseComm_SetClientMute(client, true);
				TimerMute[client] = CreateTimer(60.0, MuteTimer, client, TIMER_REPEAT);
			}
			else
			{
				kv.SetNum("mutetime", 0);
			}
		}
		kv.Rewind();
		kv.ExportToFile(sPath);
	}
	delete kv;
}

public Action Command_ceza(int client, int args)
{
	char format[128];
	int target;
	if (args == 0)
	{
		target = client;
	}
	else
	{
		GetCmdArgString(format, 128);
		target = FindTarget(client, format, true, false);
		if (target == -1)
		{
			return Plugin_Handled;
		}
	}
	
	Panel panel = new Panel();
	GetClientName(target, format, 128);
	FixText(format, 128);
	
	Format(format, 256, "★ %s Cezaları\n__________________________\n ", format);
	panel.SetTitle(format);
	
	if (!Gagged[target] && !Muted[target])
	{
		panel.DrawText("Perma/Süreli Gag: Yok\n ");
		panel.DrawText("Perma/Süreli Mute: Yok\n ");
		panel.DrawItem("Kapat");
		panel.Send(client, Panel_CallBack, 15);
		delete panel;
		return Plugin_Handled;
	}
	
	GetClientAuthId(target, AuthId_Steam2, format, 128);
	
	KeyValues kv = new KeyValues("ByDexter");
	kv.ImportFromFile(sPath);
	
	if (kv.JumpToKey(format, false))
	{
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
		kv.Rewind();
		delete kv;
		panel.DrawItem("Kapat");
		panel.Send(client, Panel_CallBack, 15);
		delete panel;
		return Plugin_Handled;
	}
	
	kv.Rewind();
	delete kv;
	panel.DrawText("Perma/Süreli Gag: Yok\n ");
	panel.DrawText("Perma/Süreli Mute: Yok\n ");
	panel.DrawItem("Kapat");
	panel.Send(client, Panel_CallBack, 15);
	delete panel;
	return Plugin_Handled;
}

public int Panel_CallBack(Menu panel, MenuAction action, int client, int position)
{
	return 0;
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
		char format[128], steamid[32];
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(steamid, true);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		int time = kv.GetNum("gagtime", 0);
		if (time >= 1)
			time--;
		
		kv.SetNum("gagtime", time);
		if (time <= 0)
		{
			Gagged[client] = false;
			if (time == 0)
			{
				PrintToChatAll("[SM] \x10%N \x01süreli gagı sona erdi.", client);
				kv.Rewind();
				kv.ExportToFile(sPath);
				delete kv;
				BaseComm_SetClientGag(client, false);
				
				char message[2000];
				Format(message, 2000, ":tada: **Gag** - Süre sona erdi.\n> **Suçlu**: `%s | %s`", format, steamid);
				SendToDiscord(message);
			}
			TimerGag[client] = null;
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
		TimerGag[client] = null;
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
		char format[128], steamid[32];
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		
		KeyValues kv = new KeyValues("ByDexter");
		kv.ImportFromFile(sPath);
		
		kv.JumpToKey(steamid, true);
		
		FormatTime(format, 128, "%T - %F", GetTime());
		kv.SetString("lastjoin", format);
		
		GetClientName(client, format, 128);
		FixText(format, 128);
		kv.SetString("lastname", format);
		
		int time = kv.GetNum("mutetime", 0);
		if (time >= 1)
			time--;
		
		kv.SetNum("mutetime", time);
		if (time <= 0)
		{
			Muted[client] = false;
			BaseComm_SetClientMute(client, false);
			if (time == 0)
			{
				PrintToChatAll("[SM] \x10%N \x01süreli mutesi sona erdi.", client);
				kv.Rewind();
				kv.ExportToFile(sPath);
				delete kv;
				
				char message[2000];
				Format(message, 2000, ":tada: **Mute** - Süre sona erdi.\n> **Suçlu**: `%s | %s`", format, steamid);
				SendToDiscord(message);
			}
			
			TimerMute[client] = null;
			return Plugin_Stop;
		}
		else
		{
			if (time % 5 == 0)
			{
				PrintToChat(client, "[SM] Süreli mutenin bitmesine \x04%d dakika\x01sı kaldı.", time);
			}
			Muted[client] = true;
			BaseComm_SetClientMute(client, true);
		}
		
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
	}
	else
	{
		TimerMute[client] = null;
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
		char message[2000], format[128], steamid[32];
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
				Format(message, 2000, ":no_mobile_phones: **PermaGag**");
				kv.SetNum("pgag", 1);
				kv.SetString("pgagreason", reason);
			}
			else
			{
				Format(message, 2000, ":no_mobile_phones: **Gag**");
				kv.SetNum("gagtime", time);
				kv.SetString("gagreason", reason);
			}
		}
		else if (ceza == 2) // Mute
		{
			if (perma)
			{
				Format(message, 2000, ":no_mobile_phones: **PermaMute**");
				kv.SetNum("pmute", 1);
				kv.SetString("pmutereason", reason);
			}
			else
			{
				Format(message, 2000, ":no_mobile_phones: **Mute**");
				kv.SetNum("mutetime", time);
				kv.SetString("mutereason", reason);
			}
		}
		else // Silence
		{
			if (perma)
			{
				Format(message, 2000, ":no_mobile_phones: **PermaSilence**");
				kv.SetNum("pgag", 1);
				kv.SetString("pgagreason", reason);
				kv.SetNum("pmute", 1);
				kv.SetString("pmutereason", reason);
			}
			else
			{
				Format(message, 2000, ":no_mobile_phones: **Silence**");
				kv.SetNum("gagtime", time);
				kv.SetString("gagreason", reason);
				kv.SetNum("mutetime", time);
				kv.SetString("mutereason", reason);
			}
		}
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
		
		if (admin == 0)
		{
			Format(message, 2000, "%s\n> **Admin**: `Panel`", message);
		}
		else
		{
			GetClientAuthId(admin, AuthId_Steam2, steamid, 32);
			GetClientName(admin, format, 128);
			FixText(format, 128);
			Format(message, 2000, "%s\n> **Admin**: `%s | %s`", message, format, steamid);
		}
		
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		GetClientName(client, format, 128);
		FixText(format, 128);
		
		if (time >= 1)
		{
			Format(message, 2000, "%s\n> **Suçlu**: `%s | %s`\n> **Sebep**: `%s`\n> **Süre**: `%d dakika`", message, format, steamid, reason, time);
		}
		else
		{
			Format(message, 2000, "%s\n> **Suçlu**: `%s | %s`\n> **Sebep**: `%s`\n> **Süre**: `Kalıcı`", message, format, steamid, reason, time);
		}
		
		OnClientPostAdminCheck(client);
		SendToDiscord(message);
	}
}

void CezaAl(int client, int admin, int ceza, bool perma = false)
{
	if (IsValidClient(client))
	{
		char message[2000], format[128], steamid[32];
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
				Format(message, 2000, ":children_crossing: **PermaUnGag**");
				kv.SetNum("pgag", 0);
			}
			else
			{
				Format(message, 2000, ":children_crossing: **UnGag**");
				kv.SetNum("gagtime", -1);
			}
		}
		else if (ceza == 2) // Mute
		{
			if (perma)
			{
				Format(message, 2000, ":children_crossing: **PermaUnMute**");
				kv.SetNum("pmute", 0);
			}
			else
			{
				Format(message, 2000, ":children_crossing: **UnMute**");
				kv.SetNum("mutetime", -1);
			}
		}
		else if (ceza == 3) // Silence
		{
			if (perma)
			{
				Format(message, 2000, ":children_crossing: **PermaUnSilence**");
				kv.SetNum("pgag", 0);
				kv.SetNum("pmute", 0);
			}
			else
			{
				Format(message, 2000, ":children_crossing: **UnSilence**");
				kv.SetNum("gagtime", -1);
				kv.SetNum("mutetime", -1);
			}
		}
		kv.Rewind();
		kv.ExportToFile(sPath);
		delete kv;
		
		if (admin == 0)
		{
			Format(message, 2000, "%s\n> **Admin**: `Panel`", message);
		}
		else
		{
			GetClientAuthId(admin, AuthId_Steam2, steamid, 32);
			GetClientName(admin, format, 128);
			FixText(format, 128);
			Format(message, 2000, "%s\n> **Admin**: `%s | %s`", message, format, steamid);
		}
		
		GetClientAuthId(client, AuthId_Steam2, steamid, 32);
		GetClientName(client, format, 128);
		FixText(format, 128);
		
		Format(message, 2000, "%s\n> **Suçlu**: `%s | %s`", message, format, steamid);
		
		OnClientPostAdminCheck(client);
		SendToDiscord(message);
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

public void BaseComm_OnClientMute(int client, bool muteState)
{
	if (!muteState && Muted[client])
	{
		BaseComm_SetClientMute(client, true);
		PrintToChatAll("[SM] \x07Hata\x01: %N kişisinin mutesi açılamadı, cezalı. \x10!ceza #%d", client, GetClientUserId(client));
	}
}

public void BaseComm_OnClientGag(int client, bool gagState)
{
	if (!gagState && Gagged[client])
	{
		BaseComm_SetClientGag(client, true);
		PrintToChatAll("[SM] \x07Hata\x01: %N kişisinin gagı açılamadı, cezalı. \x10!ceza #%d", client, GetClientUserId(client));
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
	ReplaceString(Fix, size, "^", "", false);
	ReplaceString(Fix, size, "'", "", false);
	return true;
}

public void SendToDiscord(const char[] message)
{
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, webhook);
	
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "content", message);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Content-Type", "application/x-www-form-urlencoded");
	
	if (request == null || !SteamWorks_SetHTTPCallbacks(request, Callback_SendToDiscord) || !SteamWorks_SendHTTPRequest(request))
	{
		PrintToServer("[Steamworks Discord] Hata!");
		delete request;
	}
}

public int Callback_SendToDiscord(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
	if (!bFailure && bRequestSuccessful)
	{
		if (eStatusCode != k_EHTTPStatusCode200OK && eStatusCode != k_EHTTPStatusCode204NoContent)
		{
			LogError("[Steamworks Discord] Hata kodu: [%i]", eStatusCode);
			SteamWorks_GetHTTPResponseBodyCallback(hRequest, Callback_Response);
		}
	}
	delete hRequest;
	return 0;
}

public int Callback_Response(const char[] sData)
{
	PrintToServer("[Steamworks Discord] %s", sData);
	return 0;
} 