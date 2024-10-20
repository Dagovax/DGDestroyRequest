class CfgPatches {
	class a3_dg_destroyRequest {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};
class CfgFunctions {
	class DGDestroyRequest {
		tag = "DGDestroyRequest";
		class Main {
			file = "\x\addons\a3_dg_destroyRequest\init";
			class init {
				postInit = 1;
			};
		};
		class compileFunctions {
			file = "x\addons\a3_dg_destroyRequest\functions";
			class selectMagazine {};
		};
	};
};

