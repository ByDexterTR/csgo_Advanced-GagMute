public Action Command_SUNMute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_sunmute <Hedef>");
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
	
	smute.Set(Hedef, "-3");
	ClientMute[Hedef] = false;
	UnMute(Hedef);
	BaseComm_SetClientMute(Hedef, false);
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

//

public Action Command_SMute(int client, int args)
{
	if (args < 3)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_smute <Hedef> <Dakika> <Sebep>");
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
		ReplyToCommand(client, "[SM] Kullanım: sm_smute <Hedef> <Dakika> <Sebep>");
		return Plugin_Handled;
	}
	
	Format(Arg2, 20, "%d", StringToInt(Arg2));
	smute.Set(Hedef, Arg2);
	
	char Arg3[256];
	GetCmdArgString(Arg3, 256);
	ReplaceString(Arg3, 256, Arg1, "", false);
	ReplaceString(Arg3, 256, Arg2, "", false);
	smutes.Set(Hedef, Arg3);
	
	Mute(Hedef);
	ClientMute[client] = true;
	BaseComm_SetClientMute(Hedef, true);
	CreateTimer(60.0, SMuteAzalt, GetClientUserId(Hedef), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	PrintToChatAll("[SM] \x10%N\x01, \x10%N \x01tarafından \x0E%s nedeniyle \x04%d Dakika \x01Mute yedi", Hedef, client, Arg3, StringToInt(Arg2));
	SendDiscordSMute(client, Hedef, StringToInt(Arg2), Arg3);
	return Plugin_Handled;
}

void SendDiscordSMute(int client, int target, int Arg2, char Arg3[256])
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
			ClientMute[client] = false;
			UnMute(client);
			BaseComm_SetClientMute(client, false);
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