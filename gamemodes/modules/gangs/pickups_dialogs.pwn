public ShowLSPDRecruitmentDialog(playerid)
{
    new dialogText[2048];

    strcat(dialogText, "{1E90FF}Los Santos Police Department{FFFFFF}\n\n", sizeof(dialogText));

    strcat(dialogText, "To join the {1E90FF}Los Santos Police Department{FFFFFF},\nyou must first obtain an {FFFF00}LSPD Permit{FFFFFF}.\n\n", sizeof(dialogText));

    strcat(dialogText, "{36906B}How do I obtain it?{FFFFFF}\n\n", sizeof(dialogText));

    strcat(dialogText, "Join our Discord server and create a ticket:\n\n", sizeof(dialogText));

    strcat(dialogText, "{5865F2}discord.gg/67aCuxAC7w{FFFFFF}\n{A9A9A9}Tickets > Create Ticket{FFFFFF}\n\n", sizeof(dialogText));

    strcat(dialogText, "A senior staff member will assist you and\nguide you through the application process.\nA small contribution is required to obtain the permit.\n\n", sizeof(dialogText));

    strcat(dialogText, "{36906B}Benefits of an LSPD Permit{FFFFFF}\n\n", sizeof(dialogText));
    strcat(dialogText, "- Free access to the LSPD weapon category.\n", sizeof(dialogText));
    strcat(dialogText, "- Arrest players with an active criminal record.\n", sizeof(dialogText));
    strcat(dialogText, "- Immunity from arrest by other LSPD officers.\n", sizeof(dialogText));
    strcat(dialogText, "- Access to exclusive police vehicles.\n", sizeof(dialogText));
    strcat(dialogText, "- Participate in police operations and events.\n", sizeof(dialogText));
    strcat(dialogText, "- Earn rewards while serving as an officer.\n\n", sizeof(dialogText));

    strcat(dialogText, "{A9A9A9}Thank you for helping keep Los Santos safe.{FFFFFF}", sizeof(dialogText));

    ShowPlayerDialog(
        playerid,
        1100,
        DIALOG_STYLE_MSGBOX,
        "LSPD Recruitment",
        dialogText,
        "OK",
        ""
    );

    return 1;
}