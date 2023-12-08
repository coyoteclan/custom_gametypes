
GGSetup()
{
	//Precache strings
	precacheString(&"^5Level:^2  ");
	precacheString (&"^5K/D:^2 --"); //Ditto
	precacheString (&"^5K/D: ^2"); //Figure it out: score == kd
	precacheString (&"^5K/D: ^21"); //Score = deaths
	precacheString (&"^5K/D: ^20."); //Float or Double
	precacheString (&"^5K/D: ^21."); //1. something... case 1
	precacheString (&"^5K/D: ^22.");// 2. something... case 2
	precacheString (&"^5K/D: ^23.");// 3. something... case 3
	precacheString (&"^5K/D: ^24.");// 4. something... case 4
	precacheString (&"^5K/D: ^25.");// 5. something... case 5
	
	//precache guns
	precacheItem("m1carbine_mp");
	precacheItem("m1carbine_mp");
	precacheItem("luger_mp");
	precacheItem("colt_mp");
	precacheItem("m1garand_mp");
	precacheItem("sten_mp");
	precacheItem("thompson_mp");
	precacheItem("ppsh_mp");
	precacheItem("bren_mp");
	precacheItem("bar_mp");
	precacheItem("enfield_mp");
	precacheItem("mosin_nagant_mp");
	precacheItem("fg42_mp");
	precacheItem("mosin_nagant_sniper_mp");
	precacheItem("springfield_mp");
	precacheItem("panzerfaust_mp");
	precacheItem("fraggrenade_mp");
}

GGGiveGun()
{
	if(!self.gglevel == 0)
		self iprintlnbold(self.name + " ^7is on ^2[^7Level "+self.gglevel+"^2]^5!");
	else
		self iprintlnbold(self.name + "^3 killed ^7himself.");
	if(self.gglevel == 0)
	{
		self.gglevel = 1;
	}
	if(self.gglevel==1)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("colt_mp");
		wait 0.05;
		self giveMaxAmmo("colt_mp");
		wait 0.05;
		self switchtoweapon("colt_mp");
		
		
	}
	else if(self.gglevel==2)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("luger_mp");
		wait 0.05;
		self giveMaxAmmo("luger_mp");
		wait 0.05;
		self switchtoweapon("luger_mp");
	}
	else if(self.gglevel==3)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1carbine_mp");
		wait 0.05;
		self giveMaxAmmo("m1carbine_mp");
		wait 0.05;
		self switchtoweapon("m1carbine_mp");
	}
	else if(self.gglevel==4)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1garand_mp");
		wait 0.05;
		self giveMaxAmmo("m1garand_mp");
		wait 0.05;
		self switchtoweapon("m1garand_mp");
	}
	else if(self.gglevel==5)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("sten_mp");
		wait 0.05;
		self giveMaxAmmo("sten_mp");
		wait 0.05;
		self switchtoweapon("sten_mp");
	}
	else if(self.gglevel==6)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp40_mp");
		wait 0.05;
		self giveMaxAmmo("mp40_mp");
		wait 0.05;
		self switchtoweapon("mp40_mp");
	}
	else if(self.gglevel==7)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("thompson_mp");
		wait 0.05;
		self giveMaxAmmo("thompson_mp");
		wait 0.05;
		self switchtoweapon("thompson_mp");
	}
	else if(self.gglevel==8)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("ppsh_mp");
		wait 0.05;
		self giveMaxAmmo("ppsh_mp");
		wait 0.05;
		self switchtoweapon("ppsh_mp");
	}
	else if(self.gglevel==9)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bren_mp");
		wait 0.05;
		self giveMaxAmmo("bren_mp");
		wait 0.05;
		self switchtoweapon("bren_mp");
	}
	else if(self.gglevel==10)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bar_mp");
		wait 0.05;
		self giveMaxAmmo("bar_mp");
		wait 0.05;
		self switchtoweapon("bar_mp");
	}
	else if(self.gglevel==11)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp44_mp");
		wait 0.05;
		self giveMaxAmmo("mp44_mp");
		wait 0.05;
		self switchtoweapon("mp44_mp");
	}
	else if(self.gglevel==12)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("enfield_mp");
		wait 0.05;
		self giveMaxAmmo("enfield_mp");
		wait 0.05;
		self switchtoweapon("enfield_mp");
	}
	else if(self.gglevel==13)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_mp");
		wait 0.05;
		self switchtoweapon("kar98k_mp");
	}
	else if(self.gglevel==14)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_mp");
	}
	else if(self.gglevel==15)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fg42_mp");
		wait 0.05;
		self giveMaxAmmo("fg42_mp");
		wait 0.05;
		self switchtoweapon("fg42_mp");
	}
	else if(self.gglevel==16)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_sniper_mp");
		wait 0.05;
		self switchtoweapon("kar98k_sniper_mp");
	}
	else if(self.gglevel==17)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_sniper_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_sniper_mp");
	}
	else if(self.gglevel==18)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("springfield_mp");
		wait 0.05;
		self giveMaxAmmo("springfield_mp");
		wait 0.05;
		self switchtoweapon("springfield_mp");
	}
	else if(self.gglevel==19)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("panzerfaust_mp");
		wait 0.05;
		self giveMaxAmmo("panzerfaust_mp");
		wait 0.05;
		self switchtoweapon("panzerfaust_mp");
	   self GiveWeapon("luger_mp",0);
	   wait 0.05;
	}
	else if(self.gglevel==20)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fraggrenade_mp");
		wait 0.05;
		self giveMaxAmmo("fraggrenade_mp");
		wait 0.05;
		self switchtoweapon("fraggrenade_mp");
		maps\mp\gametypes\gungame::checkScores();
	}
	self notify("gg_update_hud");
}

GGManageHUD()
{
	self.gg_hud_update = newClientHudElem(self);
	self.gg_hud_update.archived = false;
	self.gg_hud_update.x = 559.5;
	self.gg_hud_update.y = 402;
	self.gg_hud_update.alignX = "left";
	self.gg_hud_update.alignY = "top";
	self.gg_hud_update.sort = 1;
	self.gg_hud_update.fontScale = 1;
	self.gg_hud_update.label = &"^5Level:^2  ";;
	
    while ( isAlive( self ) )
    {
        wait 0.05;
        self.gg_hud_update setValue( self.gglevel );
    }	
	self.gg_hud_update destroy();	
}

//Made by Indy
KD()
{
    self.kd = newclientHudElem(self);
	self.kd.archived = false;
    self.kd.fontScale = 1;
    self.kd.alignX = "left";
    self.kd.alignY = "top";
    self.kd.horzAlign = "left";
    self.kd.vertAlign = "top";
    self.kd.sort = 1;
    self.kd.x = 559.5;// test 25
    self.kd.y = 390; // test 120

    while( isAlive( self ) )
    {
		wait 0.05; //DO NOT REMOVE
    
		if((self.deaths) == 0 && self.score == 0)
			self.kd.label = &"^5K/D:^2 --";
		else 
		{
			if(self.deaths == self.score) //Score==Deaths
			{
				self.kd.label = &"^5K/D: ^21";
			}
			if(self.deaths == 1 && self.score != 0) //score == Kd
			{
				self.kd.label = &"^5K/D: ^2";
				self.kd setValue(self.score);
			}    
			if(self.score < self.deaths) //Double-FLoat
			{
				ratio = (self.score*100) / self.deaths; //READ THE RATIO AND CONVERT IT
				self.kd.label = &"^5K/D: ^20.";
				self.kd setValue(ratio);
			}
			else if ( self.score > self.deaths && self.deaths != 0)
			//Thanks to Jona for help with this =)
			{
				var1 = self.score / self.deaths;
				var2 = ((self.score*100) / self.deaths)-(var1*100);
				switch(var1)
				{
					case 1:
						self.kd.label = &"^5K/D: ^21."; //Normal
						break;
					case 2:
						self.kd.label = &"^5K/D: ^22."; //20 <
						break;
					case 3:
						self.kd.label = &"^5K/D: ^23."; //30 <
						break;
					case 4:
						self.kd.label = &"^5K/D: ^24."; //40 <
						break;
					case 5:
						self.kd.label = &"^5K/D: ^25."; //50 <
						break;					
				}
					self.kd setValue(var2);
			}
		}
    }
	self.kd destroy();
}