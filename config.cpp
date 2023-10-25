class CfgPatches 
{
	class FA_point
	{
		name = "FA Point";
		author[] = {"Costno","NikkoJT"};
		authorUrl = "folkarps.com";
		units[] = {};
		weapons[] = {};
	};
};

class CfgFunctions
{
	class FA_point
	{
		class functions
		{
			class Init { 
				postInit=1;
				file = "\fa_point\init.sqf";
			};
		};
	};
};
