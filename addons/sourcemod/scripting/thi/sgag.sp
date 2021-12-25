public Action Command_SGag(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sgag <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, true);
	
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
	BaseComm_SetClientGag(Hedef, true);
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
			BaseComm_SetClientGag(client, false);
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

//

public Action Command_SUNGag(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sungag <Hedef>");
		return Plugin_Handled;
	}
	
	char Arg1[128];
	GetCmdArg(1, Arg1, 128);
	
	int Hedef = FindTarget(client, Arg1, true, true);
	
	if (Hedef == -1 || !IsValidClient(Hedef))
	{
		ReplyToCommand(client, "[SM] Geçersiz bir hedef.");
		return Plugin_Handled;
	}
	
	sgag.Set(Hedef, "-3");
	ClientGag[Hedef] = false;
	BaseComm_SetClientGag(Hedef, false);
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