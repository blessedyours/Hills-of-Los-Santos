//-----------------------------------------------------------------------------
// Skin Selector
//-----------------------------------------------------------------------------

#define MODEL_SELECTION_CIVIL_SKINS     (1000)
#define MODEL_SELECTION_FYB_SKINS       (1001)
#define MODEL_SELECTION_GSF_SKINS       (1002)
#define MODEL_SELECTION_KTB_SKINS       (1003)
#define MODEL_SELECTION_LSV_SKINS       (1004)
#define MODEL_SELECTION_RHB_SKINS       (1005)
#define MODEL_SELECTION_SBF_SKINS       (1006)
#define MODEL_SELECTION_TDF_SKINS       (1007)
#define MODEL_SELECTION_VLA_SKINS       (1008)
#define MODEL_SELECTION_LSPD_SKINS      (1009)

enum E_SKIN_MENU_DATA
{
    skinModel,
    skinName[48]
};

//-----------------------------------------------------------------------------
// Civilian Skins
//-----------------------------------------------------------------------------

new CivilianSkins[][E_SKIN_MENU_DATA] =
{
    {7,   "Casual Civilian"},
    {14,  "Street Civilian"},
    {15,  "Urban Civilian"},
    {20,  "Young Civilian"},
    {21,  "Casual Male"},
    {22,  "Street Male"},
    {23,  "Hood Civilian"},
    {26,  "Urban Male"},
    {29,  "Street Outfit"},
    {46,  "Casual Female"},
    {59,  "Young Female"},
    {60,  "Urban Female"},
    {72,  "East LS Civilian"},
    {98,  "Casual Worker"},
    {101, "Hood Civilian"},
    {170, "Street Civilian"},
    {188, "Casual Male"}
};

//-----------------------------------------------------------------------------
// Faction Skins - Custom 0.3DL/open.mp Models
//-----------------------------------------------------------------------------

new FYBSkins[][E_SKIN_MENU_DATA] =
{
    {20001, "Front Yard Ballas I"},
    {20002, "Front Yard Ballas II"},
    {20003, "Front Yard Ballas III"},
    {20004, "Front Yard Ballas IV"}
};

new GSFSkins[][E_SKIN_MENU_DATA] =
{
    {20005, "Grove Street Families I"},
    {20007, "Grove Street Families II"},
    {20008, "Grove Street Families III"}
};

new KTBSkins[][E_SKIN_MENU_DATA] =
{
    {20009, "Kilo Tray Ballas I"},
    {20010, "Kilo Tray Ballas II"},
    {20011, "Kilo Tray Ballas III"}
};

new LSVSkins[][E_SKIN_MENU_DATA] =
{
    {20012, "Los Santos Vagos I"},
    {20013, "Los Santos Vagos II"},
    {20014, "Los Santos Vagos III"},
    {20015, "Los Santos Vagos IV"}
};

new RHBSkins[][E_SKIN_MENU_DATA] =
{
    {20016, "Rollin Heights Ballas I"},
    {20017, "Rollin Heights Ballas II"},
    {20018, "Rollin Heights Ballas III"},
    {20019, "Rollin Heights Ballas IV"}
};

new SBFSkins[][E_SKIN_MENU_DATA] =
{
    {20020, "Seville Boulevard Families I"},
    {20021, "Seville Boulevard Families II"},
    {20022, "Seville Boulevard Families III"},
    {20023, "Seville Boulevard Families IV"}
};

new TDFSkins[][E_SKIN_MENU_DATA] =
{
    {20024, "Temple Drive Families I"},
    {20025, "Temple Drive Families II"},
    {20026, "Temple Drive Families III"},
    {20027, "Temple Drive Families IV"}
};

new VLASkins[][E_SKIN_MENU_DATA] =
{
    {20028, "Varrio Los Aztecas I"},
    {20029, "Varrio Los Aztecas II"},
    {20030, "Varrio Los Aztecas III"},
    {20031, "Varrio Los Aztecas IV"}
};

new LSPDSkins[][E_SKIN_MENU_DATA] =
{
    {20032, "LSPD Officer I"},
    {20033, "LSPD Officer II"},
    {20037, "LSPD Officer III"},
    {20046, "LSPD Officer IV"},
    {20054, "LSPD Officer V"},

    {20060, "LSPD Female Officer I"},
    {20064, "LSPD Female Officer II"},
    {20068, "LSPD Female Officer III"},

    {20072, "LSPD Metro Officer I"},
    {20073, "LSPD Metro Officer II"},
    {20074, "LSPD Metro Officer III"},
    {20075, "LSPD Metro Officer IV"},

    {20076, "LSPD Platoon Officer I"},
    {20077, "LSPD Platoon Officer II"},
    {20078, "LSPD Platoon Officer III"},
    {20079, "LSPD Platoon Officer IV"},

    {20080, "LSPD BDU Officer I"},
    {20083, "LSPD BDU Officer II"},
    {20084, "LSPD BDU Officer III"},

    {20085, "LSPD SWAT I"},
    {20086, "LSPD SWAT II"},
    {20088, "LSPD SWAT III"}
};

//-----------------------------------------------------------------------------
// Internal Helper
//-----------------------------------------------------------------------------

stock SkinSelector_AddItems(List:menu, const skins[][E_SKIN_MENU_DATA], size)
{
    for(new i = 0; i < size; i++)
    {
        AddModelMenuItem(menu, skins[i][skinModel], skins[i][skinName]);
    }
    return 1;
}

//-----------------------------------------------------------------------------
// Public Menus
//-----------------------------------------------------------------------------

stock bool:IsRestrictedCivilianSkin(skinid)
{
    switch (skinid)
    {
        // Story / special characters
        case 0, 1, 2, 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 264:
            return true;

        // Grove Street Families
        case 105, 106, 107:
            return true;

        // Ballas
        case 102, 103, 104:
            return true;

        // Los Santos Vagos
        case 108, 109, 110:
            return true;

        // Varrio Los Aztecas
        case 114, 115, 116:
            return true;

        // San Fierro Rifa
        case 173, 174, 175:
            return true;

        // Mafia / triads / gangs
        case 111, 112, 113, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127:
            return true;

        // Police / FBI / SWAT / Army
        case 265, 266, 267, 280, 281, 282, 283, 284, 285, 286, 287, 288:
            return true;

        // Medics
        case 274, 275, 276:
            return true;

        // Firefighters
        case 277, 278, 279:
            return true;
    }

    return false;
}

stock ShowCivilianSkinMenu(playerid)
{
    new List:skins = list_new();
    new itemName[32];

    for (new skinid = 0; skinid <= 311; skinid++)
    {
        if (IsRestrictedCivilianSkin(skinid))
            continue;

        format(itemName, sizeof(itemName), "Civilian Skin %d", skinid);
        AddModelMenuItem(skins, skinid, itemName);
    }

    ShowModelSelectionMenu(playerid, "Create Your Character", MODEL_SELECTION_CIVIL_SKINS, skins);
    return 1;
}

stock ShowFYBSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, FYBSkins, sizeof(FYBSkins));

    ShowModelSelectionMenu(playerid, "Front Yard Ballas Skins", MODEL_SELECTION_FYB_SKINS, skins);
    return 1;
}



stock ShowGSFSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, GSFSkins, sizeof(GSFSkins));

    ShowModelSelectionMenu(playerid, "Grove Street Families Skins", MODEL_SELECTION_GSF_SKINS, skins);
    return 1;
}

stock ShowKTBSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, KTBSkins, sizeof(KTBSkins));

    ShowModelSelectionMenu(playerid, "Kilo Tray Ballas Skins", MODEL_SELECTION_KTB_SKINS, skins);
    return 1;
}

stock ShowLSVSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, LSVSkins, sizeof(LSVSkins));

    ShowModelSelectionMenu(playerid, "Los Santos Vagos Skins", MODEL_SELECTION_LSV_SKINS, skins);
    return 1;
}

stock ShowRHBSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, RHBSkins, sizeof(RHBSkins));

    ShowModelSelectionMenu(playerid, "Rollin Heights Ballas Skins", MODEL_SELECTION_RHB_SKINS, skins);
    return 1;
}

stock ShowSBFSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, SBFSkins, sizeof(SBFSkins));

    ShowModelSelectionMenu(playerid, "Seville Boulevard Families Skins", MODEL_SELECTION_SBF_SKINS, skins);
    return 1;
}

stock ShowTDFSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, TDFSkins, sizeof(TDFSkins));

    ShowModelSelectionMenu(playerid, "Temple Drive Families Skins", MODEL_SELECTION_TDF_SKINS, skins);
    return 1;
}

stock ShowVLASkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, VLASkins, sizeof(VLASkins));

    ShowModelSelectionMenu(playerid, "Varrio Los Aztecas Skins", MODEL_SELECTION_VLA_SKINS, skins);
    return 1;
}

stock ShowLSPDSkinMenu(playerid)
{
    new List:skins = list_new();

    SkinSelector_AddItems(skins, LSPDSkins, sizeof(LSPDSkins));

    ShowModelSelectionMenu(playerid, "LSPD Skins", MODEL_SELECTION_LSPD_SKINS, skins);
    return 1;
}

stock ShowPlayerGangSkinMenu(playerid)
{
    switch(g_PlayerGang[playerid])
    {
        case 0: // GSF
        {
            ShowGSFSkinMenu(playerid);
        }
        case 1: // TDF
        {
            ShowTDFSkinMenu(playerid);
        }
        case 2: // SBF
        {
            ShowSBFSkinMenu(playerid);
        }
        case 3: // FYB
        {
            ShowFYBSkinMenu(playerid);
        }
        case 4: // RHB
        {
            ShowRHBSkinMenu(playerid);
        }
        case 5: // TDB
        {
            SendClientMessage(playerid, -1, "{ff6347}[ ! ]: {FFFFFF}Temple Drive Ballas skins are not available yet.");
        }
        case 6: // KTB
        {
            ShowKTBSkinMenu(playerid);
        }
        case 7: // LSV
        {
            ShowLSVSkinMenu(playerid);
        }
        case 8: // VLA
        {
            ShowVLASkinMenu(playerid);
        }
        case 9: // LSPD
        {
            ShowLSPDSkinMenu(playerid);
        }
        default:
        {
            ShowCivilianSkinMenu(playerid);
        }
    }

    return 1;
}

command(skins, playerid, params[])
{
    #pragma unused params

    ShowPlayerGangSkinMenu(playerid);
    return 1;
}

//-----------------------------------------------------------------------------
// Response
//-----------------------------------------------------------------------------

public OnModelSelectionResponse(playerid, extraid, index, modelid, response)
{
    if(response != MODEL_RESPONSE_SELECT)
    {
        return 1;
    }

    switch(extraid)
    {
        case MODEL_SELECTION_CIVIL_SKINS:
{
    SetPlayerSkin(playerid, modelid);
    SetPVarInt(playerid, "SelectedSkin", modelid);

    if (GetPVarInt(playerid, "SelectingRegisterSkin"))
    {
        DeletePVar(playerid, "SelectingRegisterSkin");

        Account_ShowRegistrationDialog(playerid);
        return 1;
    }

    SendClientMessage(playerid, -1,
        "{33AA33}[ + ]: {FFFFFF}Your appearance has been updated.");

    return 1;
}

        case MODEL_SELECTION_FYB_SKINS,
             MODEL_SELECTION_GSF_SKINS,
             MODEL_SELECTION_KTB_SKINS,
             MODEL_SELECTION_LSV_SKINS,
             MODEL_SELECTION_RHB_SKINS,
             MODEL_SELECTION_SBF_SKINS,
             MODEL_SELECTION_TDF_SKINS,
             MODEL_SELECTION_VLA_SKINS,
             MODEL_SELECTION_LSPD_SKINS:
        {
            SetPlayerSkin(playerid, modelid);

            // PlayerInfo[playerid][pSkin] = modelid;
            // Account_SaveSkin(playerid, modelid);

            SendClientMessage(playerid, -1, "{33AA33}[ + ]: {FFFFFF}You have successfully changed your street appearance.");
            return 1;
        }
    }

    return 1;
}