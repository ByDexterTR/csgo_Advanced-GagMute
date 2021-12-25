public Action Command_PUNMute(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_punmute <Hedef>");
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
	
	pmute.Set(Hedef, "0");
	ClientMute[Hedef] = false;
	UnMute(Hedef);
	BaseComm_SetClientMute(Hedef, false);
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

//

public Action Command_PMute(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_pmute <Hedef> <Sebep>");
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
	pmute.Set(Hedef, "1");
	
	char Arg2[128];
	GetCmdArg(2, Arg2, 128);
	pmutes.Set(Hedef, Arg2);
	Mute(Hedef);
	BaseComm_SetClientMute(Hedef, true);
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