SetupKD()
{
		self thread KD();
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
			if(self.score < 0)
			{
				self.kd.label = &"^5K/D: ^2";
				self.kd setValue(self.score);
			}
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