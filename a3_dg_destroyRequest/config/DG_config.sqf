
DGDR_MessageName = "[DG DestroyRequest]";

diag_log format["%1 Loading configuration data...", DGDR_MessageName];

if (!isServer) exitWith {
	diag_log format["%1 Failed to load configuration data, as this code is not being executed by the server!", DGDR_MessageName];
};

// Generic
DGDR_DebugMode		= false; // Only for creator. Leave it on false
DGDR_MinOnline		= 1;	// Minimum amount of players required to be online to start the script.
DGDR_MaxMissions	= 2;	// Maximum missions running at the same time.
DGDR_MinDist 		= 20;
DGDR_Water 			= 0;
DGDR_ShoreMode 		= 0;
DGDR_ModType		= "exile"; // exile or epoch
DGDR_CleanUpTime	= 60; // Seconds before the wreck is cleaned
DGDR_FailRadius		= 175; // Radius in which AI will move and mission will be failed.
DGDR_SleepTime		= 60; // Sleep time of the script after spawning a mission
DGDR_UpdateTime		= 2; // Seconds to update the position etc..

/*Exile Toasts Notification Settings*/
DGDR_ExileToasts_Title_Size		= 22;						// Size for Client Exile Toasts  mission titles.
DGDR_ExileToasts_Title_Font		= "puristaMedium";			// Font for Client Exile Toasts  mission titles.
DGDR_ExileToasts_Message_Color	= "#FFFFFF";				// Exile Toasts color for "ExileToast" client notification type.
DGDR_ExileToasts_Message_Size		= 19;						// Exile Toasts size for "ExileToast" client notification type.
DGDR_ExileToasts_Message_Font		= "PuristaLight";			// Exile Toasts font for "ExileToast" client notification type.
/*Exile Toasts Notification Settings*/

// Timers
DGDR_TMin				= 60;		// Minimum time in seconds to spawn the request 
DGDR_TMax				= 60*5;	// Maximum time in seconds to spawn the request 

// AI Setup
DGDR_CanMove			= true; // Why not. They won't move at all (with exception of planes) and will be destroyed after the idle time kicks in.
DGDR_AISide				= EAST;
DGDR_AIBehaviour		= "CARELESS"; // Set the behaviour of the AI moving to the end waypoing. Options are: "UNCHANGED" | "CARELESS" | "SAFE" | "AWARE" | "COMBAT" | "STEALTH"
DGDR_AISpeed			= "NORMAL"; // Set the speed behaviour. Options are: "UNCHANGED" | "LIMITED" | "NORMAL" | "FULL"
DGDR_AIIdleTime 		= 120; 	// The maximum number of seconds of vehicle to be idle. (Could be stuck)
DGDR_LandMaxSpeed		= 100; // Maximum Speed of the land vehicle
DGDR_AirMaxSpeed		= 150; // Maximum Speed of the air vehicle
DGDR_IdleRange			= 75; // Amount in meters before the mission will fail (because AI is not moving anymore)
DGDR_UnitType 			= "O_A_soldier_TL_F";	// Set what kind of enemies you want to be roaming the lands.
DGDR_VehicleAir			=	
						[
							"CUP_B_C47_USA",
							"RwG_Mozzie_Carl_Black",
							"CUP_B_CESSNA_T41_UNARMED_USA",
							"CUP_B_C130J_USMC",
							"CUP_O_AN2_TK",
							"I_Heli_Transport_02_F",
							"CUP_B_MH47E_GB"
						]; // Set what air vehicle you want him to be in.
DGDR_VehicleLand 		= 	
						[
							"B_LSV_01_armed_F",
							"CUP_O_GAZ_Vodnik_Unarmed_RU",
							"rhs_kraz255b1_fuel_msv",
							"CUP_B_M151_HIL",
							"Exile_Car_Ikarus_Red",
							"CUP_O_Volha_SLA",
							"CUP_O_V3S_Covered_TKA",
							"CUP_O_Tractor_SLA",
							"CUP_I_SUV_ION",
							"I_E_Offroad_01_comms_F"
						];	// Set what land vehicle you want him to be in.
DGDR_FlyingHeight		= 150; // If aircraft, they will fly this high
						
DGDR_Uniform 			= "U_O_GhillieSuit";		// Set the uniform for the AI
DGDR_Vest				= "V_PlateCarrier2_rgr_noflag_F";	// Set the vest that the AI will wear
DGDR_Backpack			= "CUP_B_Kord_Tripod_Bag";			// Set the backpack the AI will wear
DGDR_Headgear			= "H_Beret_gen_F";					// Set the Headgear/Hat that the AI will wear

// Marker Setup
DGDR_ShowMarker		= true;
DGDR_MarkerType 		= "mil_warning";		// Set the Marker type.
DGDR_MarkerName			= "Destruction Request";	// Set the text for the marker to be displayed on the map.
DGDR_MarkerColor		= "ColorBlack";			// Set the color of the marker here.

// Music Setup
DGDR_EnableMusic		= true;
DGDR_MusicTracks		= 	
						[
							["DG_Calypso", 682, 1],
							["DG_Ladytron", 342, 1],
							["DG_Gunther", 360, 1],
							["DG_Rainbow", 365, 1],
							["DG_SafriDuo", 330, 1],
							["DG_Snollebollekes", 240, 1],
							["DG_ArabianNights", 279, 1],
							["DG_Oyalele", 339, 1],
							["DG_HaveYouEverBeenMellow", 278, 1],
							["DG_TakeOnMe", 338, 1],
							["DG_LamourToujours", 840, 1],
							["DG_Kabouterdans", 352, 1],
							["DG_GimmeGimmeGimme", 438, 1],
							["DG_Sabaton", 473, 1],
							["DG_BlueDaBa", 564, 1],
							["DG_Erotic", 426, 1],
							["DG_Nikita", 584, 1],
							["DG_TheGreaseMegaMix", 576, 1]
						]; // Sound names  and their length you had to define in CfgSounds
DGDR_MusicRange		= 2000;					// Range around the vehicle the music will be played

// Loot Setup
DGDR_EnableLoot		= true;
DGDR_LootBoxType		= "Exile_Container_SupplyBox";
DGDR_LootWeapons		=	
						[
							"arifle_Katiba_F",
							"arifle_Katiba_C_F",
							"arifle_Katiba_GL_F",
							"arifle_MXC_F",
							"arifle_MX_F",
							"arifle_MX_GL_F",
							"arifle_MXM_F",
							"arifle_SDAR_F",
							"arifle_TRG21_F",
							"arifle_TRG20_F",
							"arifle_TRG21_GL_F",
							"arifle_Mk20_F",
							"arifle_Mk20C_F",
							"arifle_Mk20_GL_F",
							"arifle_Mk20_plain_F",
							"arifle_Mk20C_plain_F",
							"arifle_Mk20_GL_plain_F",
							"srifle_EBR_F",
							"srifle_GM6_F",
							"srifle_LRR_F",
							"srifle_DMR_01_F",
							"CUP_srifle_M107_Desert",
							"CUP_srifle_M107_Pristine",
							"CUP_srifle_M107_Snow",
							"CUP_srifle_M107_Woodland",
							"MMG_02_sand_F",
							"MMG_02_black_F",
							"MMG_02_camo_F",
							"MMG_01_hex_F",
							"MMG_01_tan_F",
							"srifle_DMR_05_blk_F",
							"srifle_DMR_05_hex_F",
							"srifle_DMR_05_tan_F",
							"launch_RPG32_F",
							"rhs_weap_rpg7",
							"launch_I_Titan_short_F",
							"launch_B_Titan_short_tna_F",
							"rhs_weap_igla"
						];				
DGDR_LootVests		=	[
							"V_BandollierB_oli",
							"V_BandollierB_rgr",
							"V_Chestrig_blk",
							"V_PlateCarrier3_rgr",
							"V_PlateCarrierGL_blk"
						];
DGDR_LootBackpacks	=	[
							"B_Carryall_ocamo",
							"B_Carryall_oucamo",
							"B_Carryall_mcamo",
							"B_Carryall_oli",
							"B_Carryall_khk",
							"B_Carryall_cbr"
						];
DGDR_LootMaterial		=	[
							"Exile_Item_PlasticBottleCoffee",
							"Exile_Item_PowerDrink",
							"Exile_Item_PlasticBottleFreshWater",
							"Exile_Item_Beer",
							"Exile_Item_EnergyDrink",
							"Exile_Item_MountainDupe",
							"Exile_Item_EMRE",		
							"Exile_Item_GloriousKnakworst",
							"Exile_Item_Surstromming",
							"Exile_Item_SausageGravy",
							"Exile_Item_Catfood",
							"Exile_Item_ChristmasTinner",
							"Exile_Item_BBQSandwich",
							"Exile_Item_Dogfood",
							"Exile_Item_BeefParts",
							"Exile_Item_Cheathas",
							"Exile_Item_Noodles",
							"Exile_Item_SeedAstics",
							"Exile_Item_Raisins",
							"Exile_Item_Moobar",
							"Exile_Item_InstantCoffee"
						];
DGDR_BuildingMaterials = 	
						[
							"Exile_Item_ExtensionCord",
							"Exile_Item_DuctTape",
							"Exile_Item_LightBulb",
							"Exile_Item_MetalBoard",
							"Exile_Item_MetalPole",
							"Exile_Item_MetalScrews",
							"Exile_Item_Cement",
							"Exile_Item_Sand",
							"Exile_Item_MetalWire",
							"Exile_Item_ExtensionCord",
							"Exile_Item_JunkMetal",
							"BlockConcrete_F_Kit",
							"Exile_ConcreteMixer_Kit",
							"Exile_Item_ConcreteWallKit",
							"Exile_Item_ConcreteFloorKit",
							"Exile_Item_ConcreteGateKit",
							"Land_CncWall4_F_Kit",
							"Land_CargoBox_V1_F_Kit",
							"Exile_Item_WaterBarrelKit",
							"Exile_Item_WaterCanisterDirtyWater",
							"Exile_Item_Foolbox"
						];						
DGDR_LootMedicalItems = 	
						[
							"Exile_Item_InstaDoc",
							"Exile_Item_Bandage",
							"Exile_Item_Vishpirin"
						];
DGDR_LootWeaponAttachments = 	
						[
							"bipod_01_F_snd",
							"bipod_02_F_blk",
							"muzzle_snds_338_black",
							"muzzle_snds_H",
							"muzzle_snds_M",
							"muzzle_snds_B",
							"muzzle_snds_93mmg",
							"muzzle_snds_93mmg_tan",
							"CUP_muzzle_mfsup_Suppressor_M107_Desert",
							"CUP_muzzle_mfsup_Suppressor_M107_Black",
							"CUP_muzzle_mfsup_Suppressor_M107_Snow",
							"CUP_muzzle_mfsup_Suppressor_M107_WoodLand",
							"optic_LRPS",
							"optic_LRPS_tna_F",
							"optic_LRPS_ghex_F",
							"optic_Nightstalker",
							"optic_DMS",
							"RPG32_F",
							"optic_tws",
							"optic_tws_mg"
						];
DGDR_LootRareStuff = 		
						[
							"B_Bergen_dgtl_F",
							"B_Bergen_hex_F",
							"B_Bergen_tna_F",
							"TAC_V_Sherriff_BA_T5",
							"TAC_V_Sherriff_BA_TB5",
							"TAC_V_Sherriff_BA_TC5",
							"H_Helmet0_ViperSP_hex_F",
							"H_Helmet0_ViperSP_ghex_F"
						];				
DGDR_LootCounts 	= 	[16,2,2,5,6,2,10,3]; // Number of items for each array defined above. 
DGDR_LootPoptabsMin = 10000;
DGDR_LootPoptabsMax = 75000;

// Array of starting positions. Chance these for your own good.
DGDR_LandStartPositions = 
						[
							[11765.5,9128.74,0],
							[16773.4,5249.91,0],
							[12252.3,15641.2,0],
							[14552.8,16670.8,0],
							[3325.65,5940.45,0],
							[6689.81,16953.8,0],
							[11030.2,2026.16,0],
							[12374.8,8214.7,0]
						];

DGDR_LandEndPositions = 	
						[
							[9163.18,17667.1,0],
							[3164.46,12145,0],
							[8460.75,998.653,0],
							[9840.57,9938.33,0],
							[11021.5,2014.25,0],
							[12732.3,5279.69,0],
							[10586.3,5016.72,0],
							[18624.6,9491.94,0]
						];
DGDR_AirStartPositions = 
						[
							[468.561,20002.2,200],
							[19776.3,20123.4,200],
							[10708.3,19947.3,200]
						];
DGDR_AirEndPositions = 	
						[
							[476.785,501.99,200],
							[19825.2,584.854,200],
							[11651.7,1025.23,200]
						];

DGDR_UseDynamicPositions = true; // If true, all static positions defined above will be ignored and the script will try loading a random pos.

diag_log format["%1 Configuration loaded", DGDR_MessageName];
