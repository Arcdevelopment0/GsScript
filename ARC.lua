
ARC = {
	['SB'] = function(str)
		strtab = {}
		for i = 1 , #str do
		  strtab[i] = (string.byte(str,i))..';'
		  if i == #str then strtab[i] = (string.byte(str,i))..';0::'..tostring(#str+1) break; end
		end
		return (table.concat(strtab))
	end,
	['Split'] = function (s, delimiter)
        local result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end,
	['hex'] = function (val,hx)
		local val1 = string.format('%08X', val):sub(-8)
		local val2 = tostring(val1)
		if hx == true then return '0x'..tostring(val2) elseif hx == false then
		return tostring(val2)..'h'
		else return tostring(val2)
		end
	end,
	['DT'] = function(val)
    local result= {[1] = ''}
    local splited = {};
    for match in (val..';'):gmatch("(.-)"..';') do
        table.insert(splited, match);
    end
    for i,v in pairs(splited) do 
    local chk = #tostring(splited[i])
    local v1 = math.floor(splited[i]/65536)
    local v2 = splited[i]-(65536*v1)
    local c1 = utf8.char(v2,v1)
    if chk < 7 then table.insert(result,1,result[1]..utf8.char(splited[i])) end
    if chk == 7 then table.insert(result,1,result[1]..c1) end
    if chk > 7 then table.insert(result,1,"Sorry this is not a readable string.") break end
    end
    return result[1] 
    end,
	['CL'] = function(str)
	local s = string.gsub(str, "public const string ", '')
	local s_ = string.gsub(s, " = ", "\n")
	local s__ = string.gsub(s_, ";", "")
	local _s = string.gsub(s__, '"', "")
	local _, count = str:gsub('\n', '\n')
	local t1 = {}
	local t2 ={}
	local t3 = {}
	local final = {}
	for match in (_s..'\n'):gmatch("(.-)"..'\n') do
	table.insert(t1, match);
	end
	local p = 1
	for i = 1 ,#t1 , 2 do
	  t2[p] = t1[i]
	  p = p + 1
	end
	p = 1
	for i = 2 ,#t1 , 2 do
	  t3[p] = t1[i]
	  p = p + 1
	end
	for i = 1 , count do
	  final[i] = { ['Mark'] = tostring(t2[i]):gsub("(%l)(%u)", "%1 %2"),
		['ID'] = tostring(t3[i]),['Pointer'] = nil,['FS'] = '',update = function(self)
					if self.Pointer ~= nil then self.FS = 'Fast ►  ' else
					self.FS = 'Slow ►  '
					end
		  end,}
	end
	return final
    end,
	['TD'] = function(text,order)
	local junk = {[1]=''}
	local stln = #text
	if stln%2 ~= 0 then stln = stln+1 end
  
	for i = 1,stln/2 do 
	  local v1 = (string.byte(text,i%stln*2-1))
	  local v2 = (string.byte(text,i%stln*2))
	  if v2 == nil then v2 = 0 end
	  local v3 = 65536*v2+v1
	  if #text > 2 then table.insert(junk,1,junk[1]..';'..v3) 
	  elseif #text <= 2 then
		table.insert(junk,1,v3) end
	end
	local function repeats(s,c)
	  local _,n = s:gsub(c,"")
	  return n
  end
	local ord = ''
	if order == true and stln > 2 then  ord = ('::'..repeats(tostring(junk[1]:sub(2)),';') * 4 + 5) end
	
  if #text > 2 then
	return junk[1]:sub(2)..ord else return junk[1]..ord end
    end,
    ['MH'] = function(method_name,class_name,edit)
		method_name_edit = {}
		for i = 1 ,edit do 
			method_name_edit[i] = {address = nil ,flags = gg.TYPE_DWORD }
		end
        flag_type = gg.TYPE_DWORD
        gg.setRanges(gg.REGION_OTHER)
                gg.clearResults()
                gg.searchNumber(ARC.SB(method_name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,nil,nil,1)
                String_address = gg.getResults(1)
                String_address = String_address[1].address
                gg.clearResults()
                gg.setRanges(gg.REGION_C_ALLOC)
                gg.searchNumber(String_address, flag_type)
                class_headers = gg.getResults(gg.getResultsCount())
                class_headers_pointer = class_headers
                if gg.getResultsCount() == 1 then 
                    class_headers_pointer[1].address =  class_headers_pointer[1].address - 8 
                    class_headers_pointer = gg.getValues(class_headers_pointer)

                    method_name_edit[1].address = ARC.hex(class_headers_pointer[1].value,true)
                elseif gg.getResultsCount() > 1 then
                    for i, v in pairs(class_headers) do
                            class_headers[i].address = class_headers[i].address + 4
                            class_headers = gg.getValues(class_headers)
                            class_headers[i].address = ARC.hex(class_headers[i].value + 8 ,true)
                            class_headers = gg.getValues(class_headers)
                            class_headers[i].address = class_headers[i].value
                            class_headers[i].flags = gg.TYPE_BYTE
                    end
                    class_headers = gg.getValues(class_headers)
                    gg.clearResults()
                    for k,v in pairs(class_headers) do 
                        res = {}
                        for i = 1 , #class_name do 
                            res[i] = utf8.char(class_headers[k].value)
                            class_headers[k].address = class_headers[k].address + 1
                            class_headers = gg.getValues(class_headers)
                        end
                        result = table.concat(res)
                        if result == class_name then 
                            
                    class_headers_pointer[k].address =  class_headers_pointer[k].address - 8 
                    class_headers_pointer = gg.getValues(class_headers_pointer)

                    method_name_edit[1].address = ARC.hex(class_headers_pointer[k].value,true)

                        end
                    end
                end
                    gg.clearResults()
					for k = 2 ,#method_name_edit do 
						method_name_edit[k].address = method_name_edit[k-1].address + 4 
					end
                    return method_name_edit
                    
                end,
	['CH'] = function(class,offset) 
		Result = {}
		flag_type = gg.TYPE_DWORD
		FieldSearch = ARC.SB(class)
		gg.setRanges(gg.REGION_OTHER)
		gg.clearResults()
		gg.searchNumber(FieldSearch, gg.TYPE_BYTE, false, gg.SIGN_EQUAL,nil,nil,1)
		String_address = gg.getResults(1)
		String_address = String_address[1].address
		gg.clearResults()
		gg.setRanges(gg.REGION_C_ALLOC)
		gg.searchNumber(String_address, flag_type)
		class_headers = gg.getResults(gg.getResultsCount())
			for i, v in pairs(class_headers) do
					class_headers[i].address = class_headers[i].address - 8
			end
		
			gg.setRanges(gg.REGION_ANONYMOUS)
			gg.loadResults(class_headers)
			gg.searchPointer(0)
			Result =  gg.getResults(gg.getResultsCount())
			for i, v in pairs(Result) do
				Result[i].address = Result[i].address + offset
			end
			Result = gg.getValues(Result)
	return Result
    end,
    ['Worker'] = function(self)
        for k,v in pairs(self) do 
            if self.Method ~= nil then         
                return {
                Status = ' [OFF]',
                  temp = false,
                  Name = self.Name,
                  _Name = self._Name,
                  Method = self.Method,
                  Class = self.Class,
                  val = {
                    Edit = self.Edit,
                    Pointer = nil,
                    Restore = {},
                  },
                  Slave = function(self) 
                    if self.temp == false then 
                      if self.val.Pointer == nil then
                                  self.val.Pointer = ARC.MH(self.Method,self.Class,#self.val.Edit) 
								  self.val.Pointer = gg.getValues(self.val.Pointer)
					  end
                                  for i=1,#self.val.Edit do 
                                    self.val.Restore[i] = self.val.Pointer[i].value
                                    if self.val.Pointer[i].address == nil or self.val.Pointer[i].value == nil then 
                                    self.val.Pointer[i].address = self.val.Pointer[i-1].address + 4
                                    self.val.Pointer[i].flags = gg.TYPE_DWORD
                                    self.val.Pointer = gg.getValues(self.val.Pointer) end
                                  end
                      for k,v in pairs(self.val.Pointer) do 
                        self.val.Pointer[k].value = self.val.Edit[k]
                      end
                      gg.setValues(self.val.Pointer)

                      self.Status = ' [ON]'
                      gg.toast(tostring(self.Name..self.Status))
                      self.temp = true
                      return self.Status
                    elseif self.temp == true then 
                          for k,v in pairs(self.val.Pointer) do 
                        self.val.Pointer[k].value = self.val.Restore[k]
                      end
                      gg.setValues(self.val.Pointer)
                      self.Status = ' [OFF]'
                      gg.toast(tostring(self.Name..self.Status))
                      self.temp = false
                      end
                      return self.Status
                    end,
                  } end
            if self.Method == nil then 
                return {
                    Status = ' ( None )',
                    Name = self.Name,
                    _Name = self.Name,
                    Class = self.Class,
                    offset = self.offset,
                    val = {
                        Items = nil,
                        Restore = {},
                        Temp_ = nil, --special
                        Menu = {}, --special
                        Enum = self.Enum,
                      },

                    Slave = function(self)
                        if self.val.Temp_ == nil then
                        gg.toast('⌛ Please wait configuring Script it may take a while ... ⌛')
                        if self.val.Item == nil then 
                        self.val.Items = ARC.CL(self.val.Enum) end
                        
                        self.val.Temp_ = ARC.CH(self.Class,tonumber(self.offset))
						self.val.Temp_ = gg.getValues(self.val.Temp_)
						for k = 1, #self.val.Temp_ do 
							self.val.Restore[k] = self.val.Temp_[k].value
						end
                        gg.clearResults()
                        gg.toast('⌛ Please wait configuring Script it may take a while ... ⌛')
                        for k,v in pairs(self.val.Temp_) do 
                        DumpedItem = {
                            [1] = {address = ARC.hex(self.val.Temp_[k].value,true),
                            flags = gg.TYPE_DWORD,
                            name = "START"},
                            [2]= {
                            address = ARC.hex(self.val.Temp_[k].value + 0x8 ,true) ,
                            flags = gg.TYPE_DWORD,}
                            }
                           DumpedItem = gg.getValues(DumpedItem)
                           item_len = DumpedItem[2].value
                           if item_len%2 ~= 0 then item_len = item_len + 1 end
                           for i = 3 , (item_len/2)+2 do
                           DumpedItem[i]= {
                            address = DumpedItem[i-1].address + 0x4,
                            flags = gg.TYPE_DWORD
                           }
                           end
                        DumpedItem = gg.getValues(DumpedItem)
                        local Item_name = {}
                        for i = 3,#DumpedItem do 
                        Item_name[i-2] = ARC.DT(DumpedItem[i].value)
                        end
                        local iden = table.concat(Item_name)
                          for index,value in pairs(self.val.Items) do 
                            if self.val.Items[index].ID == iden and self.val.Items[index].Pointer == nil then
                            self.val.Items[index].Pointer =  ARC.hex(self.val.Temp_[k].value,true)
                            end
                          end
                        end
                    end
                            gg.clearList()
                            gg.clearResults()
							for k,v in pairs(self.val.Items) do
								self.val.Items[k]:update()
							end
							self.val.Menu = {}
                            gg.toast('Ready 🙌')
                              Menu = gg.choice({'Search for item','All Items list','Restore Items'},nil,'Last Items Searched : '..tostring(self.Status))
                                if Menu == 1 then
                                  Input  =  gg.prompt({'Search for Items'},nil,{'text'})
                                 local t = Input[1]
                                  if t ~= nil then
                                   for i,v in pairs(self.val.Items) do
                                     busted = string.find(self.val.Items[i].ID,t)
                                      if busted ~= nil then
                                       self.val.Menu[i] = self.val.Items[i].FS..self.val.Items[i].Mark 
                                      end
                                    end
                                end
                            elseif Menu == 2 then
                                  for i,v in pairs(self.val.Items) do
									self.val.Menu[i] = self.val.Items[i].FS..self.val.Items[i].Mark 
                                  end
                        	 elseif Menu == 3 then 
								if self.val.Restore[1] == self.val.Restore[666] then gg.alert('~ARC: SORRY !\nRestore failed to load. \nif You want to restore Items please Restart the game.') else
                                    for k,v in pairs(self.val.Temp_) do 
                                        self.val.Temp_[k].value = self.val.Restore[k]
                                      end
                                      gg.setValues(self.val.Temp_)
                                      self.Status = ' ( None ) '
                                      gg.toast(' ◄ Items Restored ►')
									end
                            end
                                if self.val.Menu ~= nil then
                                  local menu = gg.choice(self.val.Menu,nil,'Items Hack')
                                  local ind = menu
                                  if menu ~= nil then
                                    gg.toast(tostring(self.val.Items[ind].Mark) .. " Selected ♥")
                                    self.Status = ' ( '..self.val.Items[ind].Mark..' ) '
                                    if self.val.Items[ind].Pointer == nil then 
                                      gg.searchNumber(tostring(#self.val.Items[ind].ID)..';'..ARC.TD(self.val.Items[ind].ID,true), gg.TYPE_DWORD, false, gg.SIGN_EQUAL,nil,nil,1)
                                      local t = {}
                                      t = gg.getResults(1)
                                         t[1].address = t[1].address - 0x8
                                         gg.getValues(t)
                                         self.val.Items[ind].Pointer = ARC.hex(t[1].address,false)
                                         gg.clearList()
                                         gg.clearResults()
                                        end
                                      for k,v in pairs(self.val.Temp_) do 
                                        self.val.Temp_[k].value = self.val.Items[ind].Pointer
                                      end
                                      gg.setValues(self.val.Temp_)
                                    self.val.Temp_ = gg.getValues(self.val.Temp_)
                                    gg.clearList()
                                    gg.clearResults()
                                    gg.toast('◄ '..tostring(self.val.Items[ind].Mark)..' ►')
									self.val.Menu = nil
                                  end
							end
                      end,
                }
            end
        end

        end,
    ['Data'] = {
        [1] = {
            Name = '🎁x99 Stacks',
            _Name = '1Stack',
            Method = 'get__amount',
            Class = 'LimitedInventoryStack',
            Edit = {[1] = '~A mov r0, #99',[2] = '~A bx lr'},
              },
        [2] = {
            Name = '⚒️Crafting Cheat',
            _Name = '2Craft',
            Method = 'get_canCraft',
            Class = 'Research',
            Edit = {[1] = '~A MOV R0, #1',[2] = '~A BX LR'},
              },
        [3] = {
            Name = '✂️Split Weapons',
            _Name = '3Sp',
            Method = 'CanSplit',
            Class = 'InventorySet',
            Edit = {[1] = '~A MOV R0, #1',[2] = '~A BX LR',},
              },
        [4] = {
            Name = '🧰 Free Assemble',
            _Name = '4Assemble',
            Method = 'CanComplete',
            Class = 'BuildingCollection',
            Edit = {[1] = '~A MOV R0, #1',[2] = '~A BX LR',},
              },
        [5] = {
            Name = '🌐Unlock Maps',
            _Name = '5Maps',
            Method = 'get_isVisible',
            Class = 'MapPointPresenter',
            Edit = {[1] = '~A MOV R0, #1',[2] = '~A BX LR',},
              },
        [6] = {
            Name = '📜Unlock Blueprints',
            _Name = '6BP',
            Method = 'get_isLocked',
            Class = 'Research',
            Edit = {[1] = '~A MOV R0, #0',[2] = '~A BX LR',},
              },
        [7] = {
            Name = '🛡Free Upgrade Tier',
            _Name = '7Assembly_v1',
            Method = 'CanUpgrade',
            Class = 'ConstructionTierModel',
            Edit = {[1] = '~A MOV R0, #1',[2] = '~A BX LR',},
              },
        [8] = {
            Name = '🔎Items Hack',
            _Name = '8Items',
            Class = 'AddStackScriptNode',
            offset = 0x18,
            Enum = [[
public const string Berry = "berry";
	public const string BerryDrink = "berry_drink";
	public const string MeatRaw = "meat_raw";
	public const string MeatRoast = "meat_roast";
	public const string MeatJerky = "meat_jerky";
	public const string Leek = "leek";
	public const string LeekRoasted = "leek_roasted";
	public const string FlaskWater = "flask_water";
	public const string BarrelHoney = "barrel_honey";
	public const string Beer = "beer";
	public const string Fabric = "fabric";
	public const string Tincture = "tincture";
	public const string BerryPoison = "berry_poison";
	public const string Pottage = "pottage";
	public const string Mandrake = "mandrake";
	public const string MandrakeTincture = "mandrake_tincture";
	public const string Mushroom = "mushroom";
	public const string MushroomPoison = "mushroom_poison";
	public const string PotionMushroom = "potion_mushroom";
	public const string PottageMushroom = "pottage_mushroom";
	public const string MushroomAmanita = "mushroom_amanita";
	public const string SpellFear = "spell_fear";
	public const string SpellControl = "spell_control";
	public const string SpellControl2 = "spell_control2";
	public const string SpellControl3 = "spell_control3";
	public const string SpellRain = "spell_rain";
	public const string SpellExpel = "spell_expel";
	public const string SpellFreeze = "spell_freeze";
	public const string SpellClan = "spell_clan";
	public const string SpellSummon = "spell_summon";
	public const string SpellLightning = "spell_lightning";
	public const string SpellMassacre = "spell_massacre";
	public const string PotionRevive = "potion_revive";
	public const string PotionCloak = "potion_cloak";
	public const string PotionNightVision = "potion_night_vision";
	public const string SoulCake = "soul_cake";
	public const string CandyApple = "candy_apple";
	public const string Pumpkin = "pumpkin";
	public const string BakedPumpkin = "baked_pumpkin";
	public const string XmasCookie = "xmas_cookie";
	public const string XmasCandy = "xmas_candy";
	public const string XmasPudding = "xmas_pudding";
	public const string XmasSocks = "xmas_socks";
	public const string XmasToy = "xmas_toy";
	public const string XmasLantern = "xmas_lantern";
	public const string XmasGiftSmall = "xmas_gift_small";
	public const string XmasGiftMedium = "xmas_gift_medium";
	public const string XmasGiftBig = "xmas_gift_big";
	public const string SweetPie = "sweet_pie";
	public const string SouredMilk = "soured_milk";
	public const string Turkey = "turkey";
	public const string TurkeyRoast = "turkey_roast";
	public const string Wood = "wood";
	public const string BeechWood = "beech_wood";
	public const string Stone = "stone";
	public const string LeekSeeds = "leek_seeds";
	public const string MandrakeSeeds = "mandrake_seeds";
	public const string PumpkinSeeds = "pumpkin_seeds";
	public const string Oat = "oat";
	public const string OatSeeds = "oat_seeds";
	public const string Rice = "rice";
	public const string RiceSeeds = "rice_seeds";
	public const string RiceCake = "rice_cake";
	public const string Fiber = "fiber";
	public const string Rope = "rope";
	public const string Cloth = "cloth";
	public const string Pelt = "pelt";
	public const string CopperDebris = "copper_debris";
	public const string CopperOre = "copper_ore";
	public const string Candle = "candle";
	public const string Wire = "wire";
	public const string FlaskEmpty = "flask_empty";
	public const string BarrelEmpty = "barrel_empty";
	public const string SpiritEmpty = "spirit_empty";
	public const string Board = "board";
	public const string StoneBlock = "stone_block";
	public const string Leather = "leather";
	public const string CopperIngot = "copper_ingot";
	public const string Nails = "nails";
	public const string ClothThick = "cloth_thick";
	public const string Straps = "straps";
	public const string Chain = "chain";
	public const string Spirit = "spirit";
	public const string OakWood = "oak_wood";
	public const string BirchWood = "birch_wood";
	public const string OakBoard = "oak_board";
	public const string BirchBoard = "birch_board";
	public const string IronOre = "iron_ore";
	public const string MeteorOre = "meteor_ore";
	public const string Sulfur = "sulfur";
	public const string TinOre = "tin_ore";
	public const string BronzeIngot = "bronze_ingot";
	public const string IronIngot = "iron_ingot";
	public const string MeteorIngot = "meteor_ingot";
	public const string Saltpetre = "saltpetre";
	public const string Bowstring = "bowstring";
	public const string Mech = "mech";
	public const string Pilers = "pilers";
	public const string Bracelet = "bracelet";
	public const string Clip = "clip";
	public const string Handle = "handle";
	public const string GrindingWheel = "grinding_wheel";
	public const string GrindOil = "grind_oil";
	public const string GrindOil2 = "grind_oil_2";
	public const string Powder = "powder";
	public const string Coal = "coal";
	public const string SteelIngot = "steel_ingot";
	public const string Soulshard = "soulshard";
	public const string Lattice = "lattice";
	public const string Saddle = "saddle";
	public const string WaggonWheel = "waggon_wheel";
	public const string HorseBridle = "horse_bridle";
	public const string HorseFeeder = "horse_feeder";
	public const string WaggonAxle = "waggon_axle";
	public const string JunkHourglass = "junk_hourglass";
	public const string JunkFibula = "junk_fibula";
	public const string JunkRing = "junk_ring";
	public const string JunkSkull = "junk_skull";
	public const string JunkComb = "junk_comb";
	public const string JunkMirror = "junk_mirror";
	public const string JunkSpoon = "junk_spoon";
	public const string JunkFork = "junk_fork";
	public const string JunkLock = "junk_lock";
	public const string JunkTusk = "junk_tusk";
	public const string JunkGoblet = "junk_goblet";
	public const string PowderCharge = "powder_charge";
	public const string PowderBarrel = "powder_barrel";
	public const string Bomb = "bomb";
	public const string Donut = "donut";
	public const string BattlepassStampSmall = "battlepass_stamp_small";
	public const string BattlepassStampLarge = "battlepass_stamp_large";
	public const string Battlepass3StampSmall = "battlepass3_stamp_small";
	public const string Battlepass3StampMiddle = "battlepass3_stamp_middle";
	public const string Battlepass3StampLarge = "battlepass3_stamp_large";
	public const string Battlepass4StampSmall = "battlepass4_stamp_small";
	public const string Battlepass4StampMiddle = "battlepass4_stamp_middle";
	public const string Battlepass4StampLarge = "battlepass4_stamp_large";
	public const string Battlepass5StampSmall = "battlepass5_stamp_small";
	public const string Battlepass5StampMiddle = "battlepass5_stamp_middle";
	public const string Battlepass5StampLarge = "battlepass5_stamp_large";
	public const string Battlepass6StampSmall = "battlepass6_stamp_small";
	public const string Battlepass6StampMiddle = "battlepass6_stamp_middle";
	public const string Battlepass6StampLarge = "battlepass6_stamp_large";
	public const string Battlepass7StampTiny = "battlepass7_stamp_tiny";
	public const string Battlepass7StampSmall = "battlepass7_stamp_small";
	public const string Battlepass7StampMiddle = "battlepass7_stamp_middle";
	public const string Battlepass7StampLarge = "battlepass7_stamp_large";
	public const string Battlepass8StampTiny = "battlepass8_stamp_tiny";
	public const string Battlepass8StampSmall = "battlepass8_stamp_small";
	public const string Battlepass8StampMiddle = "battlepass8_stamp_middle";
	public const string Battlepass8StampLarge = "battlepass8_stamp_large";
	public const string Battlepass9StampTiny = "battlepass9_stamp_tiny";
	public const string Battlepass9StampSmall = "battlepass9_stamp_small";
	public const string Battlepass9StampMiddle = "battlepass9_stamp_middle";
	public const string Battlepass9StampLarge = "battlepass9_stamp_large";
	public const string Battlepass10StampTiny = "battlepass10_stamp_tiny";
	public const string Battlepass10StampSmall = "battlepass10_stamp_small";
	public const string Battlepass10StampMiddle = "battlepass10_stamp_middle";
	public const string Battlepass10StampLarge = "battlepass10_stamp_large";
	public const string Battlepass11StampTiny = "battlepass11_stamp_tiny";
	public const string Battlepass11StampSmall = "battlepass11_stamp_small";
	public const string Battlepass11StampMiddle = "battlepass11_stamp_middle";
	public const string Battlepass11StampLarge = "battlepass11_stamp_large";
	public const string Battlepass12StampTiny = "battlepass12_stamp_tiny";
	public const string Battlepass12StampSmall = "battlepass12_stamp_small";
	public const string Battlepass12StampMiddle = "battlepass12_stamp_middle";
	public const string Battlepass12StampLarge = "battlepass12_stamp_large";
	public const string BattlepassBannerInfantryman = "battlepass_banner_infantryman";
	public const string BattlepassBannerPaladin = "battlepass_banner_paladin";
	public const string Battlepass8BannerInfantryman = "battlepass8_banner_infantryman";
	public const string Battlepass8BannerPaladin = "battlepass8_banner_paladin";
	public const string Battlepass9BannerInfantryman = "battlepass9_banner_infantryman";
	public const string Battlepass9BannerPaladin = "battlepass9_banner_paladin";
	public const string Battlepass10BannerInfantryman = "battlepass10_banner_infantryman";
	public const string Battlepass10BannerPaladin = "battlepass10_banner_paladin";
	public const string Battlepass11BannerInfantryman = "battlepass11_banner_infantryman";
	public const string Battlepass11BannerPaladin = "battlepass11_banner_paladin";
	public const string Battlepass12BannerInfantryman = "battlepass12_banner_infantryman";
	public const string Battlepass12BannerPaladin = "battlepass12_banner_paladin";
	public const string BattlepassMainchestSmall = "battlepass_mainchest_small";
	public const string BattlepassMainchestMedium = "battlepass_mainchest_medium";
	public const string BattlepassMainchestBig = "battlepass_mainchest_big";
	public const string BattlepassLetterSmall = "battlepass_letter_small";
	public const string BattlepassLetterLarge = "battlepass_letter_large";
	public const string Book = "book";
	public const string PerkBookAbstractS = "perk_book_abstract_s";
	public const string PerkBookAbstractB = "perk_book_abstract_b";
	public const string FakeBerry = "fake_berry";
	public const string PotionFear = "potion_fear";
	public const string AltarTip = "altar_tip";
	public const string Beartrap = "beartrap";
	public const string BeartrapCopper = "beartrap_copper";
	public const string AltarLeft = "altar_left";
	public const string AltarRight = "altar_right";
	public const string AltarMid = "altar_mid";
	public const string Incense = "incense";
	public const string RupertDrop = "rupert_drop";
	public const string Scales = "scales";
	public const string Pestle = "pestle";
	public const string Retort = "retort";
	public const string PhStone = "ph_stone";
	public const string GoldAlch = "gold_alch";
	public const string IronPlate = "iron_plate";
	public const string EisenhornHead = "eisenhorn_head";
	public const string AissaHead = "aissa_head";
	public const string WeaponHolder = "weapon_holder";
	public const string KeyEisenhornChest = "key_eisenhorn_chest";
	public const string BabywolfBlackUnique = "babywolf_black_unique";
	public const string BabywolfWhiteUnique = "babywolf_white_unique";
	public const string Babywolf = "babywolf";
	public const string BabywolfRnd = "babywolf_rnd";
	public const string BabywolfRnd1 = "babywolf_rnd1";
	public const string BabywolfRareMale = "babywolf_rare_male";
	public const string BabywolfRareFemale = "babywolf_rare_female";
	public const string BabywolfMale = "babywolf_male";
	public const string BabywolfFemale = "babywolf_female";
	public const string PetwolfAdult = "petwolf_adult";
	public const string PetwolfAdult1 = "petwolf_adult1";
	public const string PetwolfAdultEpic = "petwolf_adult_epic";
	public const string PetwolfAdultEpicViolet = "petwolf_adult_epic_violet";
	public const string PetwolfAdultEpicXmas = "petwolf_adult_epic_xmas";
	public const string Babycat = "babycat";
	public const string BabycatRnd = "babycat_rnd";
	public const string BabycatRnd1 = "babycat_rnd1";
	public const string BabycatUnique1 = "babycat_unique1";
	public const string BabycatUnique2 = "babycat_unique2";
	public const string BabycatRare = "babycat_rare";
	public const string PetcatAdult = "petcat_adult";
	public const string PetcatAdult1 = "petcat_adult1";
	public const string BabywolfGreenHalloween = "babywolf_green_halloween";
	public const string BabywolfYellowHalloween = "babywolf_yellow_halloween";
	public const string BabywolfBlackHalloween = "babywolf_black_halloween";
	public const string BabywolfVioletHalloween = "babywolf_violet_halloween";
	public const string BabywolfBlueHalloween = "babywolf_blue_halloween";
	public const string BabywolfTurquoiseHalloween = "babywolf_turquoise_halloween";
	public const string ResearchKennel1 = "research_kennel_1";
	public const string ResearchKennel2 = "research_kennel_2";
	public const string ResearchKennel3 = "research_kennel_3";
	public const string ResearchChestShared1 = "research_chest_shared_1";
	public const string ResearchChestShared2 = "research_chest_shared_2";
	public const string ResearchChestShared3 = "research_chest_shared_3";
	public const string ProtectiveOintment = "protective_ointment";
	public const string PetFood = "pet_food";
	public const string PetFoodAlchemy = "pet_food_alchemy";
	public const string PetCollar = "pet_collar";
	public const string CatFood = "cat_food";
	public const string TrainingMannequin = "training_mannequin";
	public const string KeyTask107 = "key_task107";
	public const string ResearchSanctum1 = "research_sanctum_1";
	public const string ResearchSanctum2 = "research_sanctum_2";
	public const string ResearchSanctum3 = "research_sanctum_3";
	public const string WoodenHorse = "wooden_horse";
	public const string GrenadePoison = "grenade_poison";
	public const string GrenadeFreeze = "grenade_freeze";
	public const string GrenadePumpkin = "grenade_pumpkin";
	public const string AissaDrop = "aissa_drop";
	public const string ResearchAltar = "research_altar";
	public const string RavenFeather = "raven_feather";
	public const string HolyWrit = "holy_writ";
	public const string Bell = "bell";
	public const string PetwolfXmasCerulean = "petwolf_xmas_cerulean";
	public const string PetwolfXmasTurquoise = "petwolf_xmas_turquoise";
	public const string PetwolfXmasLavender = "petwolf_xmas_lavender";
	public const string BabywolfConverter = "babywolf_converter";
	public const string KeyCastleChest = "key_castle_chest";
	public const string StrongBowstring = "strong_bowstring";
	public const string KeyEnemyChest = "key_enemy_chest";
	public const string KeyTask40725 = "key_task407_2_5";
	public const string Moonflower = "moonflower";
	public const string Cinnabar = "cinnabar";
	public const string KeyPuzzle = "key_puzzle";
	public const string KeyWatchtower = "key_watchtower";
	public const string HereticsFork = "heretics_fork";
	public const string ToolsRack = "tools_rack";
	public const string WoodMagic = "wood_magic";
	public const string IronMagic = "iron_magic";
	public const string KneeCrusher = "knee_crusher";
	public const string MaskIron = "mask_iron";
	public const string IronDebris = "iron_debris";
	public const string IronShaft = "iron_shaft";
	public const string GiftKeyBronze = "gift_key_bronze";
	public const string GiftKeySilver = "gift_key_silver";
	public const string GiftKeyGold = "gift_key_gold";
	public const string TokenHarat = "token_harat";
	public const string TokenPlague = "token_plague";
	public const string TokenNameless = "token_nameless";
	public const string KeyForgottenCemeteryChest = "key_forgotten_cemetery_chest";
	public const string PotionLuck = "potion_luck";
	public const string Tattoo01 = "tattoo_01";
	public const string Tattoo02 = "tattoo_02";
	public const string Tattoo03 = "tattoo_03";
	public const string Tattoo04 = "tattoo_04";
	public const string Tattoo05 = "tattoo_05";
	public const string Tattoo06 = "tattoo_06";
	public const string Tattoo07 = "tattoo_07";
	public const string Tattoo08 = "tattoo_08";
	public const string Wine = "wine";
	public const string Tattoo09 = "tattoo_09";
	public const string Tattoo10 = "tattoo_10";
	public const string Tattoo11 = "tattoo_11";
	public const string Tattoo12 = "tattoo_12";
	public const string HaltHead = "halt_head";
	public const string Bellows = "bellows";
	public const string Gutter = "gutter";
	public const string Vat = "vat";
	public const string Mold = "mold";
	public const string Ticks = "ticks";
	public const string Cobalt = "cobalt";
	public const string WhaleBook = "whale_book";
	public const string HorseFake = "horse_fake";
	public const string LeatherMagic = "leather_magic";
	public const string Filth = "filth";
	public const string BattlepassDailies1 = "battlepass_dailies1";
	public const string BattlepassDailies2 = "battlepass_dailies2";
	public const string Yuck = "yuck";
	public const string MeatStew = "meat_stew";
	public const string TurkeyWithLeek = "turkey_with_leek";
	public const string LeekRings = "leek_rings";
	public const string BerryTea = "berry_tea";
	public const string SeedsRoast = "seeds_roast";
	public const string MonkTincture = "monk_tincture";
	public const string Mead = "mead";
	public const string PottageNorth = "pottage_north";
	public const string ConsommeWithLeek = "consomme_with_leek";
	public const string PotionMushroomSweet = "potion_mushroom_sweet";
	public const string Touchstone = "touchstone";
	public const string Vise = "vise";
	public const string Mallet = "mallet";
	public const string NeedleSet = "needle_set";
	public const string HaridHead = "harid_head";
	public const string PotionFocus = "potion_focus";
	public const string SugarSkull = "sugar_skull";
	public const string PriestessAshes = "priestess_ashes";
	public const string PotionEnergy = "potion_energy";
	public const string TemperedRivet = "tempered_rivet";
	public const string PerkBookAbstractDamage = "perk_book_abstract_damage";
	public const string PerkBookAbstractSupport = "perk_book_abstract_support";
	public const string PerkBookAbstractSpecial = "perk_book_abstract_special";
	public const string Acid = "acid";
	public const string Awl = "awl";
	public const string WaxedThread = "waxed_thread";
	public const string ResearchWorkbenchArmor1 = "research_workbench_armor_1";
	public const string ResearchWorkbenchArmor2 = "research_workbench_armor_2";
	public const string ResearchWorkbenchArmor3 = "research_workbench_armor_3";
	public const string ResearchWorkbenchWeapon1 = "research_workbench_weapon_1";
	public const string ResearchWorkbenchWeapon2 = "research_workbench_weapon_2";
	public const string ResearchWorkbenchWeapon3 = "research_workbench_weapon_3";
	public const string AncientPlate = "ancient_plate";
	public const string Staple = "staple";
	public const string ResearchKennelCat1 = "research_kennel_cat_1";
	public const string ResearchKennelCat2 = "research_kennel_cat_2";
	public const string ResearchKennelCat3 = "research_kennel_cat_3";
	public const string ScratchingPost = "scratching_post";
	public const string Cushion = "cushion";
	public const string CatacombMarker = "catacomb_marker";
	public const string BonePowder = "bone_powder";
	public const string RogvoldHead = "rogvold_head";
	public const string TrueSilver = "true_silver";
	public const string TokenAngel = "token_angel";
	public const string XmasWreath = "xmas_wreath";
	public const string KeyClausTradeSmall = "key_claus_trade_small";
	public const string KeyClausTradeMedium = "key_claus_trade_medium";
	public const string KeyClausTradeLarge = "key_claus_trade_large";
	public const string Anvil = "anvil";
	public const string Chisel = "chisel";
	public const string RelicFragment = "relic_fragment";
	public const string EventMapHuntingGrounds = "event_map_hunting_grounds";
	public const string EventMapConverter = "event_map_converter";
	public const string EventMapConvoy = "event_map_convoy";
	public const string EventMapCemetery = "event_map_cemetery";
	public const string EventMapDeathLabyrinth = "event_map_death_labyrinth";
	public const string EventMapWarlockLair = "event_map_warlock_lair";
	public const string EventMapSmallHermitStorage = "event_map_small_hermit_storage";
	public const string EventMapBigHermitStorage = "event_map_big_hermit_storage";
	public const string EventMapUnknown = "event_map_unknown";
	public const string EventMapRare = "event_map_rare";
	public const string EventMapUnique = "event_map_unique";
	public const string EventMapTrader = "event_map_trader";
	public const string Fist = "fist";
	public const string TemplarBerserk = "templar_berserk";
	public const string TorturerDung = "torturer_dung";
	public const string TemplarGorh = "templar_gorh";
	public const string TemplarElite1 = "templar_elite_1";
	public const string TemplarElite3 = "templar_elite_3";
	public const string TemplarElite4 = "templar_elite_4";
	public const string GhostSwordFake = "ghost_sword_fake";
	public const string ServantDagger = "servant_dagger";
	public const string Pickaxe = "pickaxe";
	public const string Hatchet = "hatchet";
	public const string PickaxeBronze = "pickaxe_bronze";
	public const string HatchetBronze = "hatchet_bronze";
	public const string PickaxeArtisan = "pickaxe_artisan";
	public const string HatchetArtisan = "hatchet_artisan";
	public const string Cudgel = "cudgel";
	public const string Torch = "torch";
	public const string Enlightener = "enlightener";
	public const string Sickle = "sickle";
	public const string WaggonThill = "waggon_thill";
	public const string Paddle = "paddle";
	public const string Hoe = "hoe";
	public const string Hammer = "hammer";
	public const string Mace = "mace";
	public const string MarkusDagger = "markus_dagger";
	public const string Dagger = "dagger";
	public const string DaggerPoisoned = "dagger_poisoned";
	public const string Pitchfork = "pitchfork";
	public const string Shovel = "shovel";
	public const string Sword = "sword";
	public const string Pernach = "pernach";
	public const string Morgenstern = "morgenstern";
	public const string Bastard = "bastard";
	public const string BastardIron = "bastard_iron";
	public const string RupertSword = "rupert_sword";
	public const string Falchion = "falchion";
	public const string Scimitar = "scimitar";
	public const string Halberd = "halberd";
	public const string BlackScimitar = "black_scimitar";
	public const string BlackHalberd = "black_halberd";
	public const string Espadon = "espadon";
	public const string Kriegsmesser = "kriegsmesser";
	public const string DaggerDurable = "dagger_durable";
	public const string HammerDurable = "hammer_durable";
	public const string PitchforkDurable = "pitchfork_durable";
	public const string MaceDurable = "mace_durable";
	public const string BowSimple = "bow_simple";
	public const string BowComposite = "bow_composite";
	public const string CrossbowSimple = "crossbow_simple";
	public const string CrossbowLight = "crossbow_light";
	public const string CrossbowHeavy = "crossbow_heavy";
	public const string CrossbowCrow = "crossbow_crow";
	public const string Warpick = "warpick";
	public const string Claymore = "claymore";
	public const string ClaymoreSilver = "claymore_silver";
	public const string FlamingSword = "flaming_sword";
	public const string NguestSickle = "nguest_sickle";
	public const string GhostSword = "ghost_sword";
	public const string Scythe = "scythe";
	public const string ScytheFire = "scythe_fire";
	public const string ScytheMoon = "scythe_moon";
	public const string Axe = "axe";
	public const string Kris = "kris";
	public const string Smasher = "smasher";
	public const string AxeHeadhunter = "axe_headhunter";
	public const string FrostSword = "frost_sword";
	public const string BowBone = "bow_bone";
	public const string MaceSoul = "mace_soul";
	public const string SoulEater = "soul_eater";
	public const string MaceCursed = "mace_cursed";
	public const string Stiletto = "stiletto";
	public const string FlamingHalberd = "flaming_halberd";
	public const string AxeFrost = "axe_frost";
	public const string MaceFrost = "mace_frost";
	public const string SkullCrusher = "skull_crusher";
	public const string TemplarSword = "templar_sword";
	public const string Glaive = "glaive";
	public const string ThunderKnuckle = "thunder_knuckle";
	public const string SickleGrind1 = "sickle_grind1";
	public const string SickleGrind2 = "sickle_grind2";
	public const string SickleGrind3 = "sickle_grind3";
	public const string SickleGrind4 = "sickle_grind4";
	public const string SickleGrind5 = "sickle_grind5";
	public const string DaggerGrind1 = "dagger_grind1";
	public const string DaggerGrind2 = "dagger_grind2";
	public const string DaggerGrind3 = "dagger_grind3";
	public const string DaggerGrind4 = "dagger_grind4";
	public const string DaggerGrind5 = "dagger_grind5";
	public const string JambiaGrind1 = "jambia_grind1";
	public const string JambiaGrind2 = "jambia_grind2";
	public const string JambiaGrind3 = "jambia_grind3";
	public const string JambiaGrind4 = "jambia_grind4";
	public const string JambiaGrind5 = "jambia_grind5";
	public const string SwordGrind1 = "sword_grind1";
	public const string SwordGrind2 = "sword_grind2";
	public const string SwordGrind3 = "sword_grind3";
	public const string SwordGrind4 = "sword_grind4";
	public const string SwordGrind5 = "sword_grind5";
	public const string KhopeshGrind1 = "khopesh_grind1";
	public const string KhopeshGrind2 = "khopesh_grind2";
	public const string KhopeshGrind3 = "khopesh_grind3";
	public const string KhopeshGrind4 = "khopesh_grind4";
	public const string KhopeshGrind5 = "khopesh_grind5";
	public const string BastardGrind1 = "bastard_grind1";
	public const string BastardGrind2 = "bastard_grind2";
	public const string BastardGrind3 = "bastard_grind3";
	public const string BastardGrind4 = "bastard_grind4";
	public const string BastardGrind5 = "bastard_grind5";
	public const string RitterschwertGrind1 = "ritterschwert_grind1";
	public const string RitterschwertGrind2 = "ritterschwert_grind2";
	public const string RitterschwertGrind3 = "ritterschwert_grind3";
	public const string RitterschwertGrind4 = "ritterschwert_grind4";
	public const string RitterschwertGrind5 = "ritterschwert_grind5";
	public const string FalchionGrind1 = "falchion_grind1";
	public const string FalchionGrind2 = "falchion_grind2";
	public const string FalchionGrind3 = "falchion_grind3";
	public const string FalchionGrind4 = "falchion_grind4";
	public const string FalchionGrind5 = "falchion_grind5";
	public const string FalchionKillerGrind1 = "falchion_killer_grind1";
	public const string FalchionKillerGrind2 = "falchion_killer_grind2";
	public const string FalchionKillerGrind3 = "falchion_killer_grind3";
	public const string FalchionKillerGrind4 = "falchion_killer_grind4";
	public const string FalchionKillerGrind5 = "falchion_killer_grind5";
	public const string ScimitarGrind1 = "scimitar_grind1";
	public const string ScimitarGrind2 = "scimitar_grind2";
	public const string ScimitarGrind3 = "scimitar_grind3";
	public const string ScimitarGrind4 = "scimitar_grind4";
	public const string ScimitarGrind5 = "scimitar_grind5";
	public const string HalberdGrind1 = "halberd_grind1";
	public const string HalberdGrind2 = "halberd_grind2";
	public const string HalberdGrind3 = "halberd_grind3";
	public const string HalberdGrind4 = "halberd_grind4";
	public const string HalberdGrind5 = "halberd_grind5";
	public const string ClaymoreGrind1 = "claymore_grind1";
	public const string ClaymoreGrind2 = "claymore_grind2";
	public const string ClaymoreGrind3 = "claymore_grind3";
	public const string ClaymoreGrind4 = "claymore_grind4";
	public const string ClaymoreGrind5 = "claymore_grind5";
	public const string EspadonGrind1 = "espadon_grind1";
	public const string EspadonGrind2 = "espadon_grind2";
	public const string EspadonGrind3 = "espadon_grind3";
	public const string EspadonGrind4 = "espadon_grind4";
	public const string EspadonGrind5 = "espadon_grind5";
	public const string KriegsmesserGrind1 = "kriegsmesser_grind1";
	public const string KriegsmesserGrind2 = "kriegsmesser_grind2";
	public const string KriegsmesserGrind3 = "kriegsmesser_grind3";
	public const string KriegsmesserGrind4 = "kriegsmesser_grind4";
	public const string KriegsmesserGrind5 = "kriegsmesser_grind5";
	public const string KatanaGrind1 = "katana_grind1";
	public const string KatanaGrind2 = "katana_grind2";
	public const string KatanaGrind3 = "katana_grind3";
	public const string KatanaGrind4 = "katana_grind4";
	public const string KatanaGrind5 = "katana_grind5";
	public const string RapierGrind1 = "rapier_grind1";
	public const string RapierGrind2 = "rapier_grind2";
	public const string RapierGrind3 = "rapier_grind3";
	public const string RapierGrind4 = "rapier_grind4";
	public const string RapierGrind5 = "rapier_grind5";
	public const string SwordCrusherGrind1 = "sword_crusher_grind1";
	public const string SwordCrusherGrind2 = "sword_crusher_grind2";
	public const string SwordCrusherGrind3 = "sword_crusher_grind3";
	public const string SwordCrusherGrind4 = "sword_crusher_grind4";
	public const string SwordCrusherGrind5 = "sword_crusher_grind5";
	public const string YataghanGrind1 = "yataghan_grind1";
	public const string YataghanGrind2 = "yataghan_grind2";
	public const string YataghanGrind3 = "yataghan_grind3";
	public const string YataghanGrind4 = "yataghan_grind4";
	public const string YataghanGrind5 = "yataghan_grind5";
	public const string KatanaBlackGrind1 = "katana_black_grind1";
	public const string KatanaBlackGrind2 = "katana_black_grind2";
	public const string KatanaBlackGrind3 = "katana_black_grind3";
	public const string KatanaBlackGrind4 = "katana_black_grind4";
	public const string KatanaBlackGrind5 = "katana_black_grind5";
	public const string BlackScimitarGrind1 = "black_scimitar_grind1";
	public const string BlackScimitarGrind2 = "black_scimitar_grind2";
	public const string BlackScimitarGrind3 = "black_scimitar_grind3";
	public const string BlackScimitarGrind4 = "black_scimitar_grind4";
	public const string BlackScimitarGrind5 = "black_scimitar_grind5";
	public const string BlackHalberdGrind1 = "black_halberd_grind1";
	public const string BlackHalberdGrind2 = "black_halberd_grind2";
	public const string BlackHalberdGrind3 = "black_halberd_grind3";
	public const string BlackHalberdGrind4 = "black_halberd_grind4";
	public const string BlackHalberdGrind5 = "black_halberd_grind5";
	public const string ClaymoreBlackGrind1 = "claymore_black_grind1";
	public const string ClaymoreBlackGrind2 = "claymore_black_grind2";
	public const string ClaymoreBlackGrind3 = "claymore_black_grind3";
	public const string ClaymoreBlackGrind4 = "claymore_black_grind4";
	public const string ClaymoreBlackGrind5 = "claymore_black_grind5";
	public const string PoleaxeGrind1 = "poleaxe_grind1";
	public const string PoleaxeGrind2 = "poleaxe_grind2";
	public const string PoleaxeGrind3 = "poleaxe_grind3";
	public const string PoleaxeGrind4 = "poleaxe_grind4";
	public const string PoleaxeGrind5 = "poleaxe_grind5";
	public const string ClaymoreBlack = "claymore_black";
	public const string ScytheFrost = "scythe_frost";
	public const string BowFrost = "bow_frost";
	public const string GlaiveFrost = "glaive_frost";
	public const string HalberdFrost = "halberd_frost";
	public const string DaggerFrost = "dagger_frost";
	public const string AxeWar = "axe_war";
	public const string Shuko = "shuko";
	public const string Guisarme = "guisarme";
	public const string FireSpawnClaw = "fire_spawn_claw";
	public const string WitchSpawnClaw = "witch_spawn_claw";
	public const string HangmanPunisherDungClaw = "hangman_punisher_dung_claw";
	public const string CruelTorturerDungClaw = "cruel_torturer_dung_claw";
	public const string TridentPoison = "trident_poison";
	public const string PernachNovice = "pernach_novice";
	public const string FalchionKiller = "falchion_killer";
	public const string AxeMaster = "axe_master";
	public const string FlamingPartisan = "flaming_partisan";
	public const string FlamingHammer = "flaming_hammer";
	public const string FlamingHammerSanta = "flaming_hammer_santa";
	public const string TempleTorch = "temple_torch";
	public const string FlamingBow = "flaming_bow";
	public const string AxeSquealing = "axe_squealing";
	public const string BoneSword = "bone_sword";
	public const string Khopesh = "khopesh";
	public const string Ritterschwert = "ritterschwert";
	public const string SkeletonBossGraveGuardianWeapon = "skeleton_boss_grave_guardian_weapon";
	public const string BlackShuko = "black_shuko";
	public const string MorgensternNovice = "morgenstern_novice";
	public const string Jambia = "jambia";
	public const string MaceAztec = "mace_aztec";
	public const string ShovelMonk = "shovel_monk";
	public const string WoodenSword = "wooden_sword";
	public const string Katana = "katana";
	public const string MaceFist = "mace_fist";
	public const string SpearCrit = "spear_crit";
	public const string SwordEmperor = "sword_emperor";
	public const string Rapier = "rapier";
	public const string SwordCrusher = "sword_crusher";
	public const string Nagamaki = "nagamaki";
	public const string DawnBlades = "dawn_blades";
	public const string Yataghan = "yataghan";
	public const string Kamiz = "kamiz";
	public const string FrostfireStaff = "frostfire_staff";
	public const string Broom = "broom";
	public const string WatcherSword = "watcher_sword";
	public const string KatanaBlack = "katana_black";
	public const string BowCompositeBlack = "bow_composite_black";
	public const string AxeMasterBlack = "axe_master_black";
	public const string GlaiveBlack = "glaive_black";
	public const string Poleaxe = "poleaxe";
	public const string SimpleHat = "simple_hat";
	public const string SimpleShirt = "simple_shirt";
	public const string SimplePants = "simple_pants";
	public const string SimpleBoots = "simple_boots";
	public const string SimpleGloves = "simple_gloves";
	public const string LeatherHat = "leather_hat";
	public const string LeatherShirt = "leather_shirt";
	public const string LeatherPants = "leather_pants";
	public const string LeatherBoots = "leather_boots";
	public const string LeatherGloves = "leather_gloves";
	public const string ChainmailHat = "chainmail_hat";
	public const string ChainmailShirt = "chainmail_shirt";
	public const string ChainmailPants = "chainmail_pants";
	public const string ChainmailBoots = "chainmail_boots";
	public const string ChainmailGloves = "chainmail_gloves";
	public const string ChainscalyHat = "chainscaly_hat";
	public const string ChainscalyShirt = "chainscaly_shirt";
	public const string ChainscalyPants = "chainscaly_pants";
	public const string ChainscalyBoots = "chainscaly_boots";
	public const string ChainscalyGloves = "chainscaly_gloves";
	public const string ScalyHat = "scaly_hat";
	public const string ScalyShirt = "scaly_shirt";
	public const string ScalyPants = "scaly_pants";
	public const string ScalyBoots = "scaly_boots";
	public const string ScalyGloves = "scaly_gloves";
	public const string ScoutShirt = "scout_shirt";
	public const string ScoutBoots = "scout_boots";
	public const string PlagueHat = "plague_hat";
	public const string PlagueShirt = "plague_shirt";
	public const string PlaguePants = "plague_pants";
	public const string PlagueBoots = "plague_boots";
	public const string PlagueGloves = "plague_gloves";
	public const string PlagueBag = "plague_bag";
	public const string BrigantHat = "brigant_hat";
	public const string BrigantShirt = "brigant_shirt";
	public const string BrigantPants = "brigant_pants";
	public const string BrigantBoots = "brigant_boots";
	public const string BrigantGloves = "brigant_gloves";
	public const string TemplarHat = "templar_hat";
	public const string TemplarShirt = "templar_shirt";
	public const string TemplarPants = "templar_pants";
	public const string TemplarBoots = "templar_boots";
	public const string TemplarGloves = "templar_gloves";
	public const string Backpack5 = "backpack_5";
	public const string Backpack10 = "backpack_10";
	public const string Backpack15 = "backpack_15";
	public const string BackpackBlack = "backpack_black";
	public const string BackpackViolet = "backpack_violet";
	public const string BackpackRed = "backpack_red";
	public const string BagXmas = "bag_xmas";
	public const string ShieldWicker = "shield_wicker";
	public const string ShieldLeather = "shield_leather";
	public const string ShieldLight = "shield_light";
	public const string ShieldHeavy = "shield_heavy";
	public const string ShieldBlack = "shield_black";
	public const string ShieldHeavyTemplar = "shield_heavy_templar";
	public const string ShieldBuckler = "shield_buckler";
	public const string ShieldStun = "shield_stun";
	public const string ShieldPoison = "shield_poison";
	public const string ShieldTemplar = "shield_templar";
	public const string ShieldGladiator = "shield_gladiator";
	public const string ShieldFrost = "shield_frost";
	public const string ShieldEmperor = "shield_emperor";
	public const string ShieldCompound = "shield_compound";
	public const string HwCoat = "hw_coat";
	public const string DoubletShirt = "doublet_shirt";
	public const string GladiatorHat = "gladiator_hat";
	public const string GladiatorBoots = "gladiator_boots";
	public const string GladiatorGloves = "gladiator_gloves";
	public const string GladiatorPants = "gladiator_pants";
	public const string GladiatorShirt = "gladiator_shirt";
	public const string ChaperonHat = "chaperon_hat";
	public const string AiletteShirt = "ailette_shirt";
	public const string WinterHat = "winter_hat";
	public const string WinterHatBlue = "winter_hat_blue";
	public const string WinterShirt = "winter_shirt";
	public const string WinterPants = "winter_pants";
	public const string WinterBoots = "winter_boots";
	public const string WinterGloves = "winter_gloves";
	public const string WinterBag = "winter_bag";
	public const string HaltBag = "halt_bag";
	public const string IronmaidenBag = "ironmaiden_bag";
	public const string MerchantBag = "merchant_bag";
	public const string BookBag = "book_bag";
	public const string BechterShirt = "bechter_shirt";
	public const string HornedHat = "horned_hat";
	public const string BirdBag = "bird_bag";
	public const string IceHat = "ice_hat";
	public const string IceShirt = "ice_shirt";
	public const string IcePants = "ice_pants";
	public const string IceBoots = "ice_boots";
	public const string IceGloves = "ice_gloves";
	public const string FlamingBag = "flaming_bag";
	public const string PumpkinHat = "pumpkin_hat";
	public const string KeeperHat = "keeper_hat";
	public const string TwilightBag = "twilight_bag";
	public const string BarbuteHat = "barbute_hat";
	public const string SoldierHat = "soldier_hat";
	public const string SoldierShirt = "soldier_shirt";
	public const string SoldierPants = "soldier_pants";
	public const string SoldierBoots = "soldier_boots";
	public const string SoldierGloves = "soldier_gloves";
	public const string BackstabBag = "backstab_bag";
	public const string WarlockHat = "warlock_hat";
	public const string WarlockShirt = "warlock_shirt";
	public const string WarlockPants = "warlock_pants";
	public const string WarlockBoots = "warlock_boots";
	public const string WarlockGloves = "warlock_gloves";
	public const string LuteBag = "lute_bag";
	public const string PiligrimHat = "piligrim_hat";
	public const string PiligrimShirt = "piligrim_shirt";
	public const string PiligrimPants = "piligrim_pants";
	public const string PiligrimBoots = "piligrim_boots";
	public const string PiligrimGloves = "piligrim_gloves";
	public const string EastBag = "east_bag";
	public const string XmasHat = "xmas_hat";
	public const string XmasShirt = "xmas_shirt";
	public const string XmasPants = "xmas_pants";
	public const string XmasBoots = "xmas_boots";
	public const string XmasGloves = "xmas_gloves";
	public const string TravellerBag = "traveller_bag";
	public const string BearBag = "bear_bag";
	public const string AventailHat = "aventail_hat";
	public const string PullenBoots = "pullen_boots";
	public const string SpiderBag = "spider_bag";
	public const string BearHat = "bear_hat";
	public const string BearShirt = "bear_shirt";
	public const string BearPants = "bear_pants";
	public const string BearBoots = "bear_boots";
	public const string BearGloves = "bear_gloves";
	public const string StrawHat = "straw_hat";
	public const string RogvoldBag = "rogvold_bag";
	public const string DragonHat = "dragon_hat";
	public const string DragonShirt = "dragon_shirt";
	public const string DragonPants = "dragon_pants";
	public const string DragonBoots = "dragon_boots";
	public const string DragonGloves = "dragon_gloves";
	public const string SnowHunterBag = "snow_hunter_bag";
	public const string CitizenHat = "citizen_hat";
	public const string CitizenShirt = "citizen_shirt";
	public const string CitizenPants = "citizen_pants";
	public const string CitizenBoots = "citizen_boots";
	public const string CitizenGloves = "citizen_gloves";
	public const string PiligrimBag = "piligrim_bag";
	public const string NokerHat = "noker_hat";
	public const string NokerShirt = "noker_shirt";
	public const string NokerPants = "noker_pants";
	public const string NokerBoots = "noker_boots";
	public const string NokerGloves = "noker_gloves";
	public const string BardHat = "bard_hat";
	public const string BardShirt = "bard_shirt";
	public const string BardPants = "bard_pants";
	public const string BardBoots = "bard_boots";
	public const string BardGloves = "bard_gloves";
	public const string DuelistHat = "duelist_hat";
	public const string DuelistShirt = "duelist_shirt";
	public const string DuelistPants = "duelist_pants";
	public const string DuelistBoots = "duelist_boots";
	public const string DuelistGloves = "duelist_gloves";
	public const string EastChampionHat = "east_champion_hat";
	public const string EastChampionShirt = "east_champion_shirt";
	public const string EastChampionPants = "east_champion_pants";
	public const string EastChampionBoots = "east_champion_boots";
	public const string EastChampionGloves = "east_champion_gloves";
	public const string DiplomatHat = "diplomat_hat";
	public const string DiplomatShirt = "diplomat_shirt";
	public const string DiplomatPants = "diplomat_pants";
	public const string DiplomatBoots = "diplomat_boots";
	public const string DiplomatGloves = "diplomat_gloves";
	public const string BlackWarriorHat = "black_warrior_hat";
	public const string BlackWarriorShirt = "black_warrior_shirt";
	public const string BlackWarriorPants = "black_warrior_pants";
	public const string BlackWarriorBoots = "black_warrior_boots";
	public const string BlackWarriorGloves = "black_warrior_gloves";
	public const string BlackScalyHat = "black_scaly_hat";
	public const string BlackScalyShirt = "black_scaly_shirt";
	public const string BlackScalyPants = "black_scaly_pants";
	public const string BlackScalyBoots = "black_scaly_boots";
	public const string BlackScalyGloves = "black_scaly_gloves";
	public const string SnowHunterHat = "snow_hunter_hat";
	public const string SnowHunterShirt = "snow_hunter_shirt";
	public const string SnowHunterPants = "snow_hunter_pants";
	public const string SnowHunterBoots = "snow_hunter_boots";
	public const string SnowHunterGloves = "snow_hunter_gloves";
	public const string MourningReaperHat = "mourning_reaper_hat";
	public const string MourningReaperShirt = "mourning_reaper_shirt";
	public const string MourningReaperPants = "mourning_reaper_pants";
	public const string MourningReaperBoots = "mourning_reaper_boots";
	public const string MourningReaperGloves = "mourning_reaper_gloves";
	public const string Chest10 = "chest_10";
	public const string Chest15 = "chest_15";
	public const string Chest20 = "chest_20";
	public const string ChestElegant = "chest_elegant";
	public const string ChestCoffin = "chest_coffin";
	public const string ChestFrost = "chest_frost";
	public const string ChestGrimSoul = "chest_grim_soul";
	public const string ChestGrimSoul2 = "chest_grim_soul2";
	public const string ChestGrimSoul3 = "chest_grim_soul3";
	public const string ChestGrimSoul5 = "chest_grim_soul5";
	public const string ChestGrimSoul6 = "chest_grim_soul6";
	public const string ChestChallenge = "chest_challenge";
	public const string ChestShared = "chest_shared";
	public const string Firepit = "firepit";
	public const string Campfire = "campfire";
	public const string Cropfield = "cropfield";
	public const string Furnace = "furnace";
	public const string Well = "well";
	public const string RackMeat = "rack_meat";
	public const string RackLeather = "rack_leather";
	public const string WorkbenchStone = "workbench_stone";
	public const string WorkbenchWood = "workbench_wood";
	public const string WorkbenchSew = "workbench_sew";
	public const string WorkbenchNail = "workbench_nail";
	public const string WorkbenchHerb = "workbench_herb";
	public const string WorkbenchGrind = "workbench_grind";
	public const string WorkbenchAlchemist = "workbench_alchemist";
	public const string ChestTrophy = "chest_trophy";
	public const string Ravencage = "ravencage";
	public const string Stall = "stall";
	public const string Sanctum = "sanctum";
	public const string Boat = "boat";
	public const string Coach = "coach";
	public const string Waggon = "waggon";
	public const string TortureChair = "torture_chair";
	public const string Strappado = "strappado";
	public const string Rug = "rug";
	public const string GuildBanner = "guild_banner";
	public const string Strongbox = "strongbox";
	public const string Candlestick = "candlestick";
	public const string DinnerTable = "dinner_table";
	public const string Spikes = "spikes";
	public const string TraderWaggon = "trader_waggon";
	public const string Altar = "altar";
	public const string Scarecrow = "scarecrow";
	public const string Bed = "bed";
	public const string Fireplace = "fireplace";
	public const string RackWeapon = "rack_weapon";
	public const string RackWeaponElite = "rack_weapon_elite";
	public const string Kennel = "kennel";
	public const string KennelCat = "kennel_cat";
	public const string Strongwall = "strongwall";
	public const string RackArmor = "rack_armor";
	public const string RackArmorElite = "rack_armor_elite";
	public const string ThroneFrozen = "throne_frozen";
	public const string ChestCoffinHw = "chest_coffin_hw";
	public const string XmasTree = "xmas_tree";
	public const string BlastFurnace = "blast_furnace";
	public const string ChestDungeon = "chest_dungeon";
	public const string ChestBone = "chest_bone";
	public const string AdvancedCropfield = "advanced_cropfield";
	public const string AdvancedRackMeat = "advanced_rack_meat";
	public const string ChestExquisite = "chest_exquisite";
	public const string ChestMutant = "chest_mutant";
	public const string ChestDeadman = "chest_deadman";
	public const string ChestSilver = "chest_silver";
	public const string ChestTroubled = "chest_troubled";
	public const string ChestCoffinTwilight = "chest_coffin_twilight";
	public const string ChestCultist = "chest_cultist";
	public const string ChestHarid = "chest_harid";
	public const string ChestPlague = "chest_plague";
	public const string ChestDeer = "chest_deer";
	public const string WorkbenchArmor = "workbench_armor";
	public const string WorkbenchWeapon = "workbench_weapon";
	public const string ChestStone = "chest_stone";
	public const string ChestEgypt = "chest_egypt";
	public const string ChestLord = "chest_lord";
	public const string ChestEmerald = "chest_emerald";
	public const string ChestBlood = "chest_blood";
	public const string ChestCoffinHw23 = "chest_coffin_hw23";
	public const string StorageWeapon = "storage_weapon";
	public const string BookFistsDamage1 = "book_fists_damage_1";
	public const string BookFistsDamage2 = "book_fists_damage_2";
	public const string BookCudgelDamage1 = "book_cudgel_damage_1";
	public const string BookCudgelDamage2 = "book_cudgel_damage_2";
	public const string BookCudgelDamage3 = "book_cudgel_damage_3";
	public const string BookTorchDamage1 = "book_torch_damage_1";
	public const string BookTorchDamage2 = "book_torch_damage_2";
	public const string BookTorchDamage3 = "book_torch_damage_3";
	public const string BookWaggonThillDamage1 = "book_waggon_thill_damage_1";
	public const string BookWaggonThillDamage2 = "book_waggon_thill_damage_2";
	public const string BookWaggonThillDamage3 = "book_waggon_thill_damage_3";
	public const string BookWaggonThillDamage4 = "book_waggon_thill_damage_4";
	public const string BookHoeDamage1 = "book_hoe_damage_1";
	public const string BookHoeDamage2 = "book_hoe_damage_2";
	public const string BookHoeDamage3 = "book_hoe_damage_3";
	public const string BookHammerDamage1 = "book_hammer_damage_1";
	public const string BookHammerDamage2 = "book_hammer_damage_2";
	public const string BookHammerDamage3 = "book_hammer_damage_3";
	public const string BookHammerDamage4 = "book_hammer_damage_4";
	public const string BookHammerDamage5 = "book_hammer_damage_5";
	public const string BookPaddleDamage1 = "book_paddle_damage_1";
	public const string BookPaddleDamage2 = "book_paddle_damage_2";
	public const string BookPaddleDamage3 = "book_paddle_damage_3";
	public const string BookPaddleDamage4 = "book_paddle_damage_4";
	public const string BookPaddleDamage5 = "book_paddle_damage_5";
	public const string BookPaddleDamage6 = "book_paddle_damage_6";
	public const string BookShovelDamage1 = "book_shovel_damage_1";
	public const string BookShovelDamage2 = "book_shovel_damage_2";
	public const string BookShovelDamage3 = "book_shovel_damage_3";
	public const string BookShovelDamage4 = "book_shovel_damage_4";
	public const string BookShovelDamage5 = "book_shovel_damage_5";
	public const string BookPitchforkDamage1 = "book_pitchfork_damage_1";
	public const string BookPitchforkDamage2 = "book_pitchfork_damage_2";
	public const string BookPitchforkDamage3 = "book_pitchfork_damage_3";
	public const string BookPitchforkDamage4 = "book_pitchfork_damage_4";
	public const string BookPitchforkDamage5 = "book_pitchfork_damage_5";
	public const string BookPitchforkDamage6 = "book_pitchfork_damage_6";
	public const string BookSickleDamage1 = "book_sickle_damage_1";
	public const string BookSickleDamage2 = "book_sickle_damage_2";
	public const string BookSickleDamage3 = "book_sickle_damage_3";
	public const string BookSickleDamage4 = "book_sickle_damage_4";
	public const string BookDaggerDamage1 = "book_dagger_damage_1";
	public const string BookDaggerDamage2 = "book_dagger_damage_2";
	public const string BookDaggerDamage3 = "book_dagger_damage_3";
	public const string BookDaggerDamage4 = "book_dagger_damage_4";
	public const string BookDaggerDamage5 = "book_dagger_damage_5";
	public const string BookSwordDamage1 = "book_sword_damage_1";
	public const string BookSwordDamage2 = "book_sword_damage_2";
	public const string BookSwordDamage3 = "book_sword_damage_3";
	public const string BookSwordDamage4 = "book_sword_damage_4";
	public const string BookSwordDamage5 = "book_sword_damage_5";
	public const string BookSwordDamage6 = "book_sword_damage_6";
	public const string BookMaceDamage1 = "book_mace_damage_1";
	public const string BookMaceDamage2 = "book_mace_damage_2";
	public const string BookMaceDamage3 = "book_mace_damage_3";
	public const string BookMaceDamage4 = "book_mace_damage_4";
	public const string BookMaceDamage5 = "book_mace_damage_5";
	public const string BookMaceDamage6 = "book_mace_damage_6";
	public const string BookMaceDamage7 = "book_mace_damage_7";
	public const string BookMorgensternDamage1 = "book_morgenstern_damage_1";
	public const string BookMorgensternDamage2 = "book_morgenstern_damage_2";
	public const string BookMorgensternDamage3 = "book_morgenstern_damage_3";
	public const string BookMorgensternDamage4 = "book_morgenstern_damage_4";
	public const string BookMorgensternDamage5 = "book_morgenstern_damage_5";
	public const string BookMorgensternDamage6 = "book_morgenstern_damage_6";
	public const string BookMorgensternDamage7 = "book_morgenstern_damage_7";
	public const string BookMorgensternDamage8 = "book_morgenstern_damage_8";
	public const string BookPoleaxeDamage1 = "book_poleaxe_damage_1";
	public const string BookPoleaxeDamage2 = "book_poleaxe_damage_2";
	public const string BookPoleaxeDamage3 = "book_poleaxe_damage_3";
	public const string BookPoleaxeDamage4 = "book_poleaxe_damage_4";
	public const string BookPoleaxeDamage5 = "book_poleaxe_damage_5";
	public const string BookPoleaxeDamage6 = "book_poleaxe_damage_6";
	public const string BookPoleaxeDamage7 = "book_poleaxe_damage_7";
	public const string BookPoleaxeDamage8 = "book_poleaxe_damage_8";
	public const string BookPernachDamage1 = "book_pernach_damage_1";
	public const string BookPernachDamage2 = "book_pernach_damage_2";
	public const string BookPernachDamage3 = "book_pernach_damage_3";
	public const string BookPernachDamage4 = "book_pernach_damage_4";
	public const string BookPernachDamage5 = "book_pernach_damage_5";
	public const string BookPernachDamage6 = "book_pernach_damage_6";
	public const string BookPernachDamage7 = "book_pernach_damage_7";
	public const string BookPernachDamage8 = "book_pernach_damage_8";
	public const string BookFalchionDamage1 = "book_falchion_damage_1";
	public const string BookFalchionDamage2 = "book_falchion_damage_2";
	public const string BookFalchionDamage3 = "book_falchion_damage_3";
	public const string BookFalchionDamage4 = "book_falchion_damage_4";
	public const string BookFalchionDamage5 = "book_falchion_damage_5";
	public const string BookFalchionDamage6 = "book_falchion_damage_6";
	public const string BookFalchionDamage7 = "book_falchion_damage_7";
	public const string BookFalchionDamage8 = "book_falchion_damage_8";
	public const string BookFalchionDamage9 = "book_falchion_damage_9";
	public const string BookBastardDamage1 = "book_bastard_damage_1";
	public const string BookBastardDamage2 = "book_bastard_damage_2";
	public const string BookBastardDamage3 = "book_bastard_damage_3";
	public const string BookBastardDamage4 = "book_bastard_damage_4";
	public const string BookBastardDamage5 = "book_bastard_damage_5";
	public const string BookBastardDamage6 = "book_bastard_damage_6";
	public const string BookBastardDamage7 = "book_bastard_damage_7";
	public const string BookBastardDamage8 = "book_bastard_damage_8";
	public const string BookBastardDamage9 = "book_bastard_damage_9";
	public const string BookBastardDamage10 = "book_bastard_damage_10";
	public const string BookBastardDamage11 = "book_bastard_damage_11";
	public const string BookBastardDamage12 = "book_bastard_damage_12";
	public const string BookBastardDamage13 = "book_bastard_damage_13";
	public const string BookBastardDamage14 = "book_bastard_damage_14";
	public const string BookBastardDamage15 = "book_bastard_damage_15";
	public const string BookScimitarDamage1 = "book_scimitar_damage_1";
	public const string BookScimitarDamage2 = "book_scimitar_damage_2";
	public const string BookScimitarDamage3 = "book_scimitar_damage_3";
	public const string BookScimitarDamage4 = "book_scimitar_damage_4";
	public const string BookScimitarDamage5 = "book_scimitar_damage_5";
	public const string BookScimitarDamage6 = "book_scimitar_damage_6";
	public const string BookScimitarDamage7 = "book_scimitar_damage_7";
	public const string BookScimitarDamage8 = "book_scimitar_damage_8";
	public const string BookScimitarDamage9 = "book_scimitar_damage_9";
	public const string BookScimitarDamage10 = "book_scimitar_damage_10";
	public const string BookScimitarDamage11 = "book_scimitar_damage_11";
	public const string BookScimitarDamage12 = "book_scimitar_damage_12";
	public const string BookScimitarDamage13 = "book_scimitar_damage_13";
	public const string BookScimitarDamage14 = "book_scimitar_damage_14";
	public const string BookScimitarDamage15 = "book_scimitar_damage_15";
	public const string BookKriegsmesserDamage1 = "book_kriegsmesser_damage_1";
	public const string BookKriegsmesserDamage2 = "book_kriegsmesser_damage_2";
	public const string BookKriegsmesserDamage3 = "book_kriegsmesser_damage_3";
	public const string BookKriegsmesserDamage4 = "book_kriegsmesser_damage_4";
	public const string BookKriegsmesserDamage5 = "book_kriegsmesser_damage_5";
	public const string BookKriegsmesserDamage6 = "book_kriegsmesser_damage_6";
	public const string BookKriegsmesserDamage7 = "book_kriegsmesser_damage_7";
	public const string BookKriegsmesserDamage8 = "book_kriegsmesser_damage_8";
	public const string BookKriegsmesserDamage9 = "book_kriegsmesser_damage_9";
	public const string BookKriegsmesserDamage10 = "book_kriegsmesser_damage_10";
	public const string BookKriegsmesserDamage11 = "book_kriegsmesser_damage_11";
	public const string BookKriegsmesserDamage12 = "book_kriegsmesser_damage_12";
	public const string BookKriegsmesserDamage13 = "book_kriegsmesser_damage_13";
	public const string BookKriegsmesserDamage14 = "book_kriegsmesser_damage_14";
	public const string BookKriegsmesserDamage15 = "book_kriegsmesser_damage_15";
	public const string BookClaymoreDamage1 = "book_claymore_damage_1";
	public const string BookClaymoreDamage2 = "book_claymore_damage_2";
	public const string BookClaymoreDamage3 = "book_claymore_damage_3";
	public const string BookClaymoreDamage4 = "book_claymore_damage_4";
	public const string BookClaymoreDamage5 = "book_claymore_damage_5";
	public const string BookClaymoreDamage6 = "book_claymore_damage_6";
	public const string BookClaymoreDamage7 = "book_claymore_damage_7";
	public const string BookClaymoreDamage8 = "book_claymore_damage_8";
	public const string BookClaymoreDamage9 = "book_claymore_damage_9";
	public const string BookClaymoreDamage10 = "book_claymore_damage_10";
	public const string BookClaymoreDamage11 = "book_claymore_damage_11";
	public const string BookClaymoreDamage12 = "book_claymore_damage_12";
	public const string BookClaymoreDamage13 = "book_claymore_damage_13";
	public const string BookClaymoreDamage14 = "book_claymore_damage_14";
	public const string BookClaymoreDamage15 = "book_claymore_damage_15";
	public const string BookEspadonDamage1 = "book_espadon_damage_1";
	public const string BookEspadonDamage2 = "book_espadon_damage_2";
	public const string BookEspadonDamage3 = "book_espadon_damage_3";
	public const string BookEspadonDamage4 = "book_espadon_damage_4";
	public const string BookEspadonDamage5 = "book_espadon_damage_5";
	public const string BookEspadonDamage6 = "book_espadon_damage_6";
	public const string BookEspadonDamage7 = "book_espadon_damage_7";
	public const string BookEspadonDamage8 = "book_espadon_damage_8";
	public const string BookEspadonDamage9 = "book_espadon_damage_9";
	public const string BookEspadonDamage10 = "book_espadon_damage_10";
	public const string BookEspadonDamage11 = "book_espadon_damage_11";
	public const string BookEspadonDamage12 = "book_espadon_damage_12";
	public const string BookEspadonDamage13 = "book_espadon_damage_13";
	public const string BookEspadonDamage14 = "book_espadon_damage_14";
	public const string BookEspadonDamage15 = "book_espadon_damage_15";
	public const string BookHalberdDamage1 = "book_halberd_damage_1";
	public const string BookHalberdDamage2 = "book_halberd_damage_2";
	public const string BookHalberdDamage3 = "book_halberd_damage_3";
	public const string BookHalberdDamage4 = "book_halberd_damage_4";
	public const string BookHalberdDamage5 = "book_halberd_damage_5";
	public const string BookHalberdDamage6 = "book_halberd_damage_6";
	public const string BookHalberdDamage7 = "book_halberd_damage_7";
	public const string BookHalberdDamage8 = "book_halberd_damage_8";
	public const string BookHalberdDamage9 = "book_halberd_damage_9";
	public const string BookHalberdDamage10 = "book_halberd_damage_10";
	public const string BookHalberdDamage11 = "book_halberd_damage_11";
	public const string BookHalberdDamage12 = "book_halberd_damage_12";
	public const string BookHalberdDamage13 = "book_halberd_damage_13";
	public const string BookHalberdDamage14 = "book_halberd_damage_14";
	public const string BookHalberdDamage15 = "book_halberd_damage_15";
	public const string BookShieldsDurability1 = "book_shields_durability_1";
	public const string BookShieldsDurability2 = "book_shields_durability_2";
	public const string BookShieldsDurability3 = "book_shields_durability_3";
	public const string BookShieldsDurability4 = "book_shields_durability_4";
	public const string BookShieldsDurability5 = "book_shields_durability_5";
	public const string BookShieldsDurability6 = "book_shields_durability_6";
	public const string BookShieldsDurability7 = "book_shields_durability_7";
	public const string BookShieldsDurability8 = "book_shields_durability_8";
	public const string BookShieldsDurability9 = "book_shields_durability_9";
	public const string BookShieldsDurability10 = "book_shields_durability_10";
	public const string BookShieldsDurability11 = "book_shields_durability_11";
	public const string BookShieldsDurability12 = "book_shields_durability_12";
	public const string BookShieldsDurability13 = "book_shields_durability_13";
	public const string BookShieldsDurability14 = "book_shields_durability_14";
	public const string BookShieldsDurability15 = "book_shields_durability_15";
	public const string BookSecondArrowAttack1 = "book_second_arrow_attack_1";
	public const string BookSecondArrowAttack2 = "book_second_arrow_attack_2";
	public const string BookSecondArrowAttack3 = "book_second_arrow_attack_3";
	public const string BookSecondArrowAttack4 = "book_second_arrow_attack_4";
	public const string BookSecondArrowAttack5 = "book_second_arrow_attack_5";
	public const string BookSecondArrowAttack6 = "book_second_arrow_attack_6";
	public const string BookSecondArrowAttack7 = "book_second_arrow_attack_7";
	public const string BookSecondArrowAttack8 = "book_second_arrow_attack_8";
	public const string BookSecondArrowAttack9 = "book_second_arrow_attack_9";
	public const string BookSecondArrowAttack10 = "book_second_arrow_attack_10";
	public const string BookSecondArrowAttack11 = "book_second_arrow_attack_11";
	public const string BookSecondArrowAttack12 = "book_second_arrow_attack_12";
	public const string BookSecondArrowAttack13 = "book_second_arrow_attack_13";
	public const string BookSecondArrowAttack14 = "book_second_arrow_attack_14";
	public const string BookSecondArrowAttack15 = "book_second_arrow_attack_15";
	public const string BookFabricHeal1 = "book_fabric_heal_1";
	public const string BookFabricHeal2 = "book_fabric_heal_2";
	public const string BookFabricHeal3 = "book_fabric_heal_3";
	public const string BookFabricHeal4 = "book_fabric_heal_4";
	public const string BookFabricHeal5 = "book_fabric_heal_5";
	public const string BookFabricHeal6 = "book_fabric_heal_6";
	public const string BookFabricHeal7 = "book_fabric_heal_7";
	public const string BookFabricHeal8 = "book_fabric_heal_8";
	public const string BookFabricHeal9 = "book_fabric_heal_9";
	public const string BookFabricHeal10 = "book_fabric_heal_10";
	public const string BookBeerHeal1 = "book_beer_heal_1";
	public const string BookBeerHeal2 = "book_beer_heal_2";
	public const string BookBeerHeal3 = "book_beer_heal_3";
	public const string BookBeerHeal4 = "book_beer_heal_4";
	public const string BookBeerHeal5 = "book_beer_heal_5";
	public const string BookBeerHeal6 = "book_beer_heal_6";
	public const string BookBeerHeal7 = "book_beer_heal_7";
	public const string BookBeerHeal8 = "book_beer_heal_8";
	public const string BookBeerHeal9 = "book_beer_heal_9";
	public const string BookBeerHeal10 = "book_beer_heal_10";
	public const string BookBerryDrinkHeal1 = "book_berry_drink_heal_1";
	public const string BookBerryDrinkHeal2 = "book_berry_drink_heal_2";
	public const string BookBerryDrinkHeal3 = "book_berry_drink_heal_3";
	public const string BookBerryDrinkHeal4 = "book_berry_drink_heal_4";
	public const string BookBerryDrinkHeal5 = "book_berry_drink_heal_5";
	public const string BookBerryDrinkHeal6 = "book_berry_drink_heal_6";
	public const string BookBerryDrinkHeal7 = "book_berry_drink_heal_7";
	public const string BookBerryDrinkHeal8 = "book_berry_drink_heal_8";
	public const string BookBerryDrinkHeal9 = "book_berry_drink_heal_9";
	public const string BookBerryDrinkHeal10 = "book_berry_drink_heal_10";
	public const string BookMeatJerkyHeal1 = "book_meat_jerky_heal_1";
	public const string BookMeatJerkyHeal2 = "book_meat_jerky_heal_2";
	public const string BookMeatJerkyHeal3 = "book_meat_jerky_heal_3";
	public const string BookMeatJerkyHeal4 = "book_meat_jerky_heal_4";
	public const string BookMeatJerkyHeal5 = "book_meat_jerky_heal_5";
	public const string BookMeatJerkyHeal6 = "book_meat_jerky_heal_6";
	public const string BookMeatJerkyHeal7 = "book_meat_jerky_heal_7";
	public const string BookMeatJerkyHeal8 = "book_meat_jerky_heal_8";
	public const string BookMeatJerkyHeal9 = "book_meat_jerky_heal_9";
	public const string BookMeatJerkyHeal10 = "book_meat_jerky_heal_10";
	public const string BookMeatRoastHeal1 = "book_meat_roast_heal_1";
	public const string BookMeatRoastHeal2 = "book_meat_roast_heal_2";
	public const string BookMeatRoastHeal3 = "book_meat_roast_heal_3";
	public const string BookMeatRoastHeal4 = "book_meat_roast_heal_4";
	public const string BookMeatRoastHeal5 = "book_meat_roast_heal_5";
	public const string BookMeatRoastHeal6 = "book_meat_roast_heal_6";
	public const string BookMeatRoastHeal7 = "book_meat_roast_heal_7";
	public const string BookMeatRoastHeal8 = "book_meat_roast_heal_8";
	public const string BookMeatRoastHeal9 = "book_meat_roast_heal_9";
	public const string BookMeatRoastHeal10 = "book_meat_roast_heal_10";
	public const string BookPottageHeal1 = "book_pottage_heal_1";
	public const string BookPottageHeal2 = "book_pottage_heal_2";
	public const string BookPottageHeal3 = "book_pottage_heal_3";
	public const string BookPottageHeal4 = "book_pottage_heal_4";
	public const string BookPottageHeal5 = "book_pottage_heal_5";
	public const string BookPottageHeal6 = "book_pottage_heal_6";
	public const string BookPottageHeal7 = "book_pottage_heal_7";
	public const string BookPottageHeal8 = "book_pottage_heal_8";
	public const string BookPottageHeal9 = "book_pottage_heal_9";
	public const string BookPottageHeal10 = "book_pottage_heal_10";
	public const string BookBarrelHoneyHeal1 = "book_barrel_honey_heal_1";
	public const string BookBarrelHoneyHeal2 = "book_barrel_honey_heal_2";
	public const string BookBarrelHoneyHeal3 = "book_barrel_honey_heal_3";
	public const string BookBarrelHoneyHeal4 = "book_barrel_honey_heal_4";
	public const string BookBarrelHoneyHeal5 = "book_barrel_honey_heal_5";
	public const string BookBarrelHoneyHeal6 = "book_barrel_honey_heal_6";
	public const string BookBarrelHoneyHeal7 = "book_barrel_honey_heal_7";
	public const string BookBarrelHoneyHeal8 = "book_barrel_honey_heal_8";
	public const string BookBarrelHoneyHeal9 = "book_barrel_honey_heal_9";
	public const string BookBarrelHoneyHeal10 = "book_barrel_honey_heal_10";
	public const string BookLeekRoastedHeal1 = "book_leek_roasted_heal_1";
	public const string BookLeekRoastedHeal2 = "book_leek_roasted_heal_2";
	public const string BookLeekRoastedHeal3 = "book_leek_roasted_heal_3";
	public const string BookLeekRoastedHeal4 = "book_leek_roasted_heal_4";
	public const string BookLeekRoastedHeal5 = "book_leek_roasted_heal_5";
	public const string BookLeekRoastedHeal6 = "book_leek_roasted_heal_6";
	public const string BookLeekRoastedHeal7 = "book_leek_roasted_heal_7";
	public const string BookLeekRoastedHeal8 = "book_leek_roasted_heal_8";
	public const string BookLeekRoastedHeal9 = "book_leek_roasted_heal_9";
	public const string BookLeekRoastedHeal10 = "book_leek_roasted_heal_10";
	public const string BookPotionMushroomHeal1 = "book_potion_mushroom_heal_1";
	public const string BookPotionMushroomHeal2 = "book_potion_mushroom_heal_2";
	public const string BookPotionMushroomHeal3 = "book_potion_mushroom_heal_3";
	public const string BookPotionMushroomHeal4 = "book_potion_mushroom_heal_4";
	public const string BookPotionMushroomHeal5 = "book_potion_mushroom_heal_5";
	public const string BookPotionMushroomHeal6 = "book_potion_mushroom_heal_6";
	public const string BookWineHeal1 = "book_wine_heal_1";
	public const string BookWineHeal2 = "book_wine_heal_2";
	public const string BookWineHeal3 = "book_wine_heal_3";
	public const string BookWineHeal4 = "book_wine_heal_4";
	public const string BookWineHeal5 = "book_wine_heal_5";
	public const string BookWineHeal6 = "book_wine_heal_6";
	public const string BookTinctureHeal1 = "book_tincture_heal_1";
	public const string BookTinctureHeal2 = "book_tincture_heal_2";
	public const string BookTinctureHeal3 = "book_tincture_heal_3";
	public const string BookTinctureHeal4 = "book_tincture_heal_4";
	public const string BookTinctureHeal5 = "book_tincture_heal_5";
	public const string BookTinctureHeal6 = "book_tincture_heal_6";
	public const string BookMandrakeTinctureHeal1 = "book_mandrake_tincture_heal_1";
	public const string BookMandrakeTinctureHeal2 = "book_mandrake_tincture_heal_2";
	public const string BookMandrakeTinctureHeal3 = "book_mandrake_tincture_heal_3";
	public const string BookMandrakeTinctureHeal4 = "book_mandrake_tincture_heal_4";
	public const string BookMandrakeTinctureHeal5 = "book_mandrake_tincture_heal_5";
	public const string BookMandrakeTinctureHeal6 = "book_mandrake_tincture_heal_6";
	public const string BookLeperEvade1 = "book_leper_evade_1";
	public const string BookLeperEvade2 = "book_leper_evade_2";
	public const string BookLeperEvade3 = "book_leper_evade_3";
	public const string BookLeperEvade4 = "book_leper_evade_4";
	public const string BookLeperEvade5 = "book_leper_evade_5";
	public const string BookLeperEvade6 = "book_leper_evade_6";
	public const string BookLeperEvade7 = "book_leper_evade_7";
	public const string BookLeperEvade8 = "book_leper_evade_8";
	public const string BookLeperEvade9 = "book_leper_evade_9";
	public const string BookLeperEvade10 = "book_leper_evade_10";
	public const string BookWolfEvade1 = "book_wolf_evade_1";
	public const string BookWolfEvade2 = "book_wolf_evade_2";
	public const string BookWolfEvade3 = "book_wolf_evade_3";
	public const string BookWolfEvade4 = "book_wolf_evade_4";
	public const string BookWolfEvade5 = "book_wolf_evade_5";
	public const string BookWolfEvade6 = "book_wolf_evade_6";
	public const string BookWolfEvade7 = "book_wolf_evade_7";
	public const string BookWolfEvade8 = "book_wolf_evade_8";
	public const string BookWolfEvade9 = "book_wolf_evade_9";
	public const string BookWolfEvade10 = "book_wolf_evade_10";
	public const string BookBearEvade1 = "book_bear_evade_1";
	public const string BookBearEvade2 = "book_bear_evade_2";
	public const string BookBearEvade3 = "book_bear_evade_3";
	public const string BookBearEvade4 = "book_bear_evade_4";
	public const string BookBearEvade5 = "book_bear_evade_5";
	public const string BookBearEvade6 = "book_bear_evade_6";
	public const string BookBearEvade7 = "book_bear_evade_7";
	public const string BookBearEvade8 = "book_bear_evade_8";
	public const string BookBearEvade9 = "book_bear_evade_9";
	public const string BookBearEvade10 = "book_bear_evade_10";
	public const string BookCursedEvade1 = "book_cursed_evade_1";
	public const string BookCursedEvade2 = "book_cursed_evade_2";
	public const string BookCursedEvade3 = "book_cursed_evade_3";
	public const string BookCursedEvade4 = "book_cursed_evade_4";
	public const string BookCursedEvade5 = "book_cursed_evade_5";
	public const string BookCursedEvade6 = "book_cursed_evade_6";
	public const string BookCursedEvade7 = "book_cursed_evade_7";
	public const string BookCursedEvade8 = "book_cursed_evade_8";
	public const string BookCursedEvade9 = "book_cursed_evade_9";
	public const string BookCursedEvade10 = "book_cursed_evade_10";
	public const string BookDirewolfEvade1 = "book_direwolf_evade_1";
	public const string BookDirewolfEvade2 = "book_direwolf_evade_2";
	public const string BookDirewolfEvade3 = "book_direwolf_evade_3";
	public const string BookDirewolfEvade4 = "book_direwolf_evade_4";
	public const string BookDirewolfEvade5 = "book_direwolf_evade_5";
	public const string BookDirewolfEvade6 = "book_direwolf_evade_6";
	public const string BookDirewolfEvade7 = "book_direwolf_evade_7";
	public const string BookDirewolfEvade8 = "book_direwolf_evade_8";
	public const string BookDirewolfEvade9 = "book_direwolf_evade_9";
	public const string BookDirewolfEvade10 = "book_direwolf_evade_10";
	public const string BookKnightEvade1 = "book_knight_evade_1";
	public const string BookKnightEvade2 = "book_knight_evade_2";
	public const string BookKnightEvade3 = "book_knight_evade_3";
	public const string BookKnightEvade4 = "book_knight_evade_4";
	public const string BookKnightEvade5 = "book_knight_evade_5";
	public const string BookKnightEvade6 = "book_knight_evade_6";
	public const string BookKnightEvade7 = "book_knight_evade_7";
	public const string BookKnightEvade8 = "book_knight_evade_8";
	public const string BookKnightEvade9 = "book_knight_evade_9";
	public const string BookKnightEvade10 = "book_knight_evade_10";
	public const string BookTemplarEvade1 = "book_templar_evade_1";
	public const string BookTemplarEvade2 = "book_templar_evade_2";
	public const string BookTemplarEvade3 = "book_templar_evade_3";
	public const string BookTemplarEvade4 = "book_templar_evade_4";
	public const string BookTemplarEvade5 = "book_templar_evade_5";
	public const string BookTemplarEvade6 = "book_templar_evade_6";
	public const string BookTemplarEvade7 = "book_templar_evade_7";
	public const string BookTemplarEvade8 = "book_templar_evade_8";
	public const string BookTemplarEvade9 = "book_templar_evade_9";
	public const string BookTemplarEvade10 = "book_templar_evade_10";
	public const string BookArcherEvade1 = "book_archer_evade_1";
	public const string BookArcherEvade2 = "book_archer_evade_2";
	public const string BookArcherEvade3 = "book_archer_evade_3";
	public const string BookArcherEvade4 = "book_archer_evade_4";
	public const string BookArcherEvade5 = "book_archer_evade_5";
	public const string BookArcherEvade6 = "book_archer_evade_6";
	public const string BookArcherEvade7 = "book_archer_evade_7";
	public const string BookArcherEvade8 = "book_archer_evade_8";
	public const string BookArcherEvade9 = "book_archer_evade_9";
	public const string BookArcherEvade10 = "book_archer_evade_10";
	public const string BookRogueEvade1 = "book_rogue_evade_1";
	public const string BookRogueEvade2 = "book_rogue_evade_2";
	public const string BookRogueEvade3 = "book_rogue_evade_3";
	public const string BookRogueEvade4 = "book_rogue_evade_4";
	public const string BookRogueEvade5 = "book_rogue_evade_5";
	public const string BookRogueEvade6 = "book_rogue_evade_6";
	public const string BookRogueEvade7 = "book_rogue_evade_7";
	public const string BookRogueEvade8 = "book_rogue_evade_8";
	public const string BookRogueEvade9 = "book_rogue_evade_9";
	public const string BookRogueEvade10 = "book_rogue_evade_10";
	public const string BookCursedDung1Evade1 = "book_cursed_dung1_evade_1";
	public const string BookCursedDung1Evade2 = "book_cursed_dung1_evade_2";
	public const string BookCursedDung1Evade3 = "book_cursed_dung1_evade_3";
	public const string BookCursedDung1Evade4 = "book_cursed_dung1_evade_4";
	public const string BookCursedDung1Evade5 = "book_cursed_dung1_evade_5";
	public const string BookCursedDung1Evade6 = "book_cursed_dung1_evade_6";
	public const string BookCursedDung1Evade7 = "book_cursed_dung1_evade_7";
	public const string BookCursedDung1Evade8 = "book_cursed_dung1_evade_8";
	public const string BookCursedDung1Evade9 = "book_cursed_dung1_evade_9";
	public const string BookCursedDung1Evade10 = "book_cursed_dung1_evade_10";
	public const string BookKnightDung1Evade1 = "book_knight_dung1_evade_1";
	public const string BookKnightDung1Evade2 = "book_knight_dung1_evade_2";
	public const string BookKnightDung1Evade3 = "book_knight_dung1_evade_3";
	public const string BookKnightDung1Evade4 = "book_knight_dung1_evade_4";
	public const string BookKnightDung1Evade5 = "book_knight_dung1_evade_5";
	public const string BookKnightDung1Evade6 = "book_knight_dung1_evade_6";
	public const string BookKnightDung1Evade7 = "book_knight_dung1_evade_7";
	public const string BookKnightDung1Evade8 = "book_knight_dung1_evade_8";
	public const string BookKnightDung1Evade9 = "book_knight_dung1_evade_9";
	public const string BookKnightDung1Evade10 = "book_knight_dung1_evade_10";
	public const string BookTemplarDung1Evade1 = "book_templar_dung1_evade_1";
	public const string BookTemplarDung1Evade2 = "book_templar_dung1_evade_2";
	public const string BookTemplarDung1Evade3 = "book_templar_dung1_evade_3";
	public const string BookTemplarDung1Evade4 = "book_templar_dung1_evade_4";
	public const string BookTemplarDung1Evade5 = "book_templar_dung1_evade_5";
	public const string BookTemplarDung1Evade6 = "book_templar_dung1_evade_6";
	public const string BookTemplarDung1Evade7 = "book_templar_dung1_evade_7";
	public const string BookTemplarDung1Evade8 = "book_templar_dung1_evade_8";
	public const string BookTemplarDung1Evade9 = "book_templar_dung1_evade_9";
	public const string BookTemplarDung1Evade10 = "book_templar_dung1_evade_10";
	public const string BookVictimDungEvade1 = "book_victim_dung_evade_1";
	public const string BookVictimDungEvade2 = "book_victim_dung_evade_2";
	public const string BookVictimDungEvade3 = "book_victim_dung_evade_3";
	public const string BookVictimDungEvade4 = "book_victim_dung_evade_4";
	public const string BookVictimDungEvade5 = "book_victim_dung_evade_5";
	public const string BookVictimDungEvade6 = "book_victim_dung_evade_6";
	public const string BookVictimDungEvade7 = "book_victim_dung_evade_7";
	public const string BookVictimDungEvade8 = "book_victim_dung_evade_8";
	public const string BookVictimDungEvade9 = "book_victim_dung_evade_9";
	public const string BookVictimDungEvade10 = "book_victim_dung_evade_10";
	public const string BookHangmanDungEvade1 = "book_hangman_dung_evade_1";
	public const string BookHangmanDungEvade2 = "book_hangman_dung_evade_2";
	public const string BookHangmanDungEvade3 = "book_hangman_dung_evade_3";
	public const string BookHangmanDungEvade4 = "book_hangman_dung_evade_4";
	public const string BookHangmanDungEvade5 = "book_hangman_dung_evade_5";
	public const string BookHangmanDungEvade6 = "book_hangman_dung_evade_6";
	public const string BookHangmanDungEvade7 = "book_hangman_dung_evade_7";
	public const string BookHangmanDungEvade8 = "book_hangman_dung_evade_8";
	public const string BookHangmanDungEvade9 = "book_hangman_dung_evade_9";
	public const string BookHangmanDungEvade10 = "book_hangman_dung_evade_10";
	public const string BookAxeThrowerDungEvade1 = "book_axe_thrower_dung_evade_1";
	public const string BookAxeThrowerDungEvade2 = "book_axe_thrower_dung_evade_2";
	public const string BookAxeThrowerDungEvade3 = "book_axe_thrower_dung_evade_3";
	public const string BookAxeThrowerDungEvade4 = "book_axe_thrower_dung_evade_4";
	public const string BookAxeThrowerDungEvade5 = "book_axe_thrower_dung_evade_5";
	public const string BookAxeThrowerDungEvade6 = "book_axe_thrower_dung_evade_6";
	public const string BookAxeThrowerDungEvade7 = "book_axe_thrower_dung_evade_7";
	public const string BookAxeThrowerDungEvade8 = "book_axe_thrower_dung_evade_8";
	public const string BookAxeThrowerDungEvade9 = "book_axe_thrower_dung_evade_9";
	public const string BookAxeThrowerDungEvade10 = "book_axe_thrower_dung_evade_10";
	public const string BookShamanDungEvade1 = "book_shaman_dung_evade_1";
	public const string BookShamanDungEvade2 = "book_shaman_dung_evade_2";
	public const string BookShamanDungEvade3 = "book_shaman_dung_evade_3";
	public const string BookShamanDungEvade4 = "book_shaman_dung_evade_4";
	public const string BookShamanDungEvade5 = "book_shaman_dung_evade_5";
	public const string BookShamanDungEvade6 = "book_shaman_dung_evade_6";
	public const string BookShamanDungEvade7 = "book_shaman_dung_evade_7";
	public const string BookShamanDungEvade8 = "book_shaman_dung_evade_8";
	public const string BookShamanDungEvade9 = "book_shaman_dung_evade_9";
	public const string BookShamanDungEvade10 = "book_shaman_dung_evade_10";
	public const string BookTorturerDungEvade1 = "book_torturer_dung_evade_1";
	public const string BookTorturerDungEvade2 = "book_torturer_dung_evade_2";
	public const string BookTorturerDungEvade3 = "book_torturer_dung_evade_3";
	public const string BookTorturerDungEvade4 = "book_torturer_dung_evade_4";
	public const string BookTorturerDungEvade5 = "book_torturer_dung_evade_5";
	public const string BookTorturerDungEvade6 = "book_torturer_dung_evade_6";
	public const string BookTorturerDungEvade7 = "book_torturer_dung_evade_7";
	public const string BookTorturerDungEvade8 = "book_torturer_dung_evade_8";
	public const string BookTorturerDungEvade9 = "book_torturer_dung_evade_9";
	public const string BookTorturerDungEvade10 = "book_torturer_dung_evade_10";
	public const string BookAxeThrowerHeadhunterDungEvade1 = "book_axe_thrower_headhunter_dung_evade_1";
	public const string BookAxeThrowerHeadhunterDungEvade2 = "book_axe_thrower_headhunter_dung_evade_2";
	public const string BookAxeThrowerHeadhunterDungEvade3 = "book_axe_thrower_headhunter_dung_evade_3";
	public const string BookAxeThrowerHeadhunterDungEvade4 = "book_axe_thrower_headhunter_dung_evade_4";
	public const string BookAxeThrowerHeadhunterDungEvade5 = "book_axe_thrower_headhunter_dung_evade_5";
	public const string BookAxeThrowerHeadhunterDungEvade6 = "book_axe_thrower_headhunter_dung_evade_6";
	public const string BookAxeThrowerHeadhunterDungEvade7 = "book_axe_thrower_headhunter_dung_evade_7";
	public const string BookAxeThrowerHeadhunterDungEvade8 = "book_axe_thrower_headhunter_dung_evade_8";
	public const string BookAxeThrowerHeadhunterDungEvade9 = "book_axe_thrower_headhunter_dung_evade_9";
	public const string BookAxeThrowerHeadhunterDungEvade10 = "book_axe_thrower_headhunter_dung_evade_10";
	public const string BookHangmanPunisherDungEvade1 = "book_hangman_punisher_dung_evade_1";
	public const string BookHangmanPunisherDungEvade2 = "book_hangman_punisher_dung_evade_2";
	public const string BookHangmanPunisherDungEvade3 = "book_hangman_punisher_dung_evade_3";
	public const string BookHangmanPunisherDungEvade4 = "book_hangman_punisher_dung_evade_4";
	public const string BookHangmanPunisherDungEvade5 = "book_hangman_punisher_dung_evade_5";
	public const string BookHangmanPunisherDungEvade6 = "book_hangman_punisher_dung_evade_6";
	public const string BookHangmanPunisherDungEvade7 = "book_hangman_punisher_dung_evade_7";
	public const string BookHangmanPunisherDungEvade8 = "book_hangman_punisher_dung_evade_8";
	public const string BookHangmanPunisherDungEvade9 = "book_hangman_punisher_dung_evade_9";
	public const string BookHangmanPunisherDungEvade10 = "book_hangman_punisher_dung_evade_10";
	public const string BookCruelTorturerDungEvade1 = "book_cruel_torturer_dung_evade_1";
	public const string BookCruelTorturerDungEvade2 = "book_cruel_torturer_dung_evade_2";
	public const string BookCruelTorturerDungEvade3 = "book_cruel_torturer_dung_evade_3";
	public const string BookCruelTorturerDungEvade4 = "book_cruel_torturer_dung_evade_4";
	public const string BookCruelTorturerDungEvade5 = "book_cruel_torturer_dung_evade_5";
	public const string BookCruelTorturerDungEvade6 = "book_cruel_torturer_dung_evade_6";
	public const string BookCruelTorturerDungEvade7 = "book_cruel_torturer_dung_evade_7";
	public const string BookCruelTorturerDungEvade8 = "book_cruel_torturer_dung_evade_8";
	public const string BookCruelTorturerDungEvade9 = "book_cruel_torturer_dung_evade_9";
	public const string BookCruelTorturerDungEvade10 = "book_cruel_torturer_dung_evade_10";
	public const string BookFireSpawnDungEvade1 = "book_fire_spawn_dung_evade_1";
	public const string BookFireSpawnDungEvade2 = "book_fire_spawn_dung_evade_2";
	public const string BookFireSpawnDungEvade3 = "book_fire_spawn_dung_evade_3";
	public const string BookFireSpawnDungEvade4 = "book_fire_spawn_dung_evade_4";
	public const string BookFireSpawnDungEvade5 = "book_fire_spawn_dung_evade_5";
	public const string BookFireSpawnDungEvade6 = "book_fire_spawn_dung_evade_6";
	public const string BookFireSpawnDungEvade7 = "book_fire_spawn_dung_evade_7";
	public const string BookFireSpawnDungEvade8 = "book_fire_spawn_dung_evade_8";
	public const string BookFireSpawnDungEvade9 = "book_fire_spawn_dung_evade_9";
	public const string BookFireSpawnDungEvade10 = "book_fire_spawn_dung_evade_10";
	public const string BookCursedMartyrEvade1 = "book_cursed_martyr_evade_1";
	public const string BookCursedMartyrEvade2 = "book_cursed_martyr_evade_2";
	public const string BookCursedMartyrEvade3 = "book_cursed_martyr_evade_3";
	public const string BookCursedMartyrEvade4 = "book_cursed_martyr_evade_4";
	public const string BookCursedMartyrEvade5 = "book_cursed_martyr_evade_5";
	public const string BookCursedMartyrEvade6 = "book_cursed_martyr_evade_6";
	public const string BookCursedMartyrEvade7 = "book_cursed_martyr_evade_7";
	public const string BookCursedMartyrEvade8 = "book_cursed_martyr_evade_8";
	public const string BookCursedMartyrEvade9 = "book_cursed_martyr_evade_9";
	public const string BookCursedMartyrEvade10 = "book_cursed_martyr_evade_10";
	public const string BookKnightWarriorEvade1 = "book_knight_warrior_evade_1";
	public const string BookKnightWarriorEvade2 = "book_knight_warrior_evade_2";
	public const string BookKnightWarriorEvade3 = "book_knight_warrior_evade_3";
	public const string BookKnightWarriorEvade4 = "book_knight_warrior_evade_4";
	public const string BookKnightWarriorEvade5 = "book_knight_warrior_evade_5";
	public const string BookKnightWarriorEvade6 = "book_knight_warrior_evade_6";
	public const string BookKnightWarriorEvade7 = "book_knight_warrior_evade_7";
	public const string BookKnightWarriorEvade8 = "book_knight_warrior_evade_8";
	public const string BookKnightWarriorEvade9 = "book_knight_warrior_evade_9";
	public const string BookKnightWarriorEvade10 = "book_knight_warrior_evade_10";
	public const string BookTemplarZealotEvade1 = "book_templar_zealot_evade_1";
	public const string BookTemplarZealotEvade2 = "book_templar_zealot_evade_2";
	public const string BookTemplarZealotEvade3 = "book_templar_zealot_evade_3";
	public const string BookTemplarZealotEvade4 = "book_templar_zealot_evade_4";
	public const string BookTemplarZealotEvade5 = "book_templar_zealot_evade_5";
	public const string BookTemplarZealotEvade6 = "book_templar_zealot_evade_6";
	public const string BookTemplarZealotEvade7 = "book_templar_zealot_evade_7";
	public const string BookTemplarZealotEvade8 = "book_templar_zealot_evade_8";
	public const string BookTemplarZealotEvade9 = "book_templar_zealot_evade_9";
	public const string BookTemplarZealotEvade10 = "book_templar_zealot_evade_10";
	public const string BookWoodGather1 = "book_wood_gather_1";
	public const string BookWoodGather2 = "book_wood_gather_2";
	public const string BookWoodGather3 = "book_wood_gather_3";
	public const string BookWoodGather4 = "book_wood_gather_4";
	public const string BookWoodGather5 = "book_wood_gather_5";
	public const string BookWoodGather6 = "book_wood_gather_6";
	public const string BookWoodGather7 = "book_wood_gather_7";
	public const string BookWoodGather8 = "book_wood_gather_8";
	public const string BookWoodGather9 = "book_wood_gather_9";
	public const string BookWoodGather10 = "book_wood_gather_10";
	public const string BookStoneGather1 = "book_stone_gather_1";
	public const string BookStoneGather2 = "book_stone_gather_2";
	public const string BookStoneGather3 = "book_stone_gather_3";
	public const string BookStoneGather4 = "book_stone_gather_4";
	public const string BookStoneGather5 = "book_stone_gather_5";
	public const string BookStoneGather6 = "book_stone_gather_6";
	public const string BookStoneGather7 = "book_stone_gather_7";
	public const string BookStoneGather8 = "book_stone_gather_8";
	public const string BookStoneGather9 = "book_stone_gather_9";
	public const string BookStoneGather10 = "book_stone_gather_10";
	public const string BookFiberGather1 = "book_fiber_gather_1";
	public const string BookFiberGather2 = "book_fiber_gather_2";
	public const string BookFiberGather3 = "book_fiber_gather_3";
	public const string BookFiberGather4 = "book_fiber_gather_4";
	public const string BookFiberGather5 = "book_fiber_gather_5";
	public const string BookFiberGather6 = "book_fiber_gather_6";
	public const string BookFiberGather7 = "book_fiber_gather_7";
	public const string BookFiberGather8 = "book_fiber_gather_8";
	public const string BookFiberGather9 = "book_fiber_gather_9";
	public const string BookFiberGather10 = "book_fiber_gather_10";
	public const string BookCopperOreGather1 = "book_copper_ore_gather_1";
	public const string BookCopperOreGather2 = "book_copper_ore_gather_2";
	public const string BookCopperOreGather3 = "book_copper_ore_gather_3";
	public const string BookCopperOreGather4 = "book_copper_ore_gather_4";
	public const string BookCopperOreGather5 = "book_copper_ore_gather_5";
	public const string BookCopperOreGather6 = "book_copper_ore_gather_6";
	public const string BookCopperOreGather7 = "book_copper_ore_gather_7";
	public const string BookCopperOreGather8 = "book_copper_ore_gather_8";
	public const string BookCopperOreGather9 = "book_copper_ore_gather_9";
	public const string BookCopperOreGather10 = "book_copper_ore_gather_10";
	public const string BookBerryGather1 = "book_berry_gather_1";
	public const string BookBerryGather2 = "book_berry_gather_2";
	public const string BookBerryGather3 = "book_berry_gather_3";
	public const string BookBerryGather4 = "book_berry_gather_4";
	public const string BookBerryGather5 = "book_berry_gather_5";
	public const string BookBerryGather6 = "book_berry_gather_6";
	public const string BookBerryGather7 = "book_berry_gather_7";
	public const string BookBerryGather8 = "book_berry_gather_8";
	public const string BookBerryGather9 = "book_berry_gather_9";
	public const string BookBerryGather10 = "book_berry_gather_10";
	public const string BookIronOreGather1 = "book_iron_ore_gather_1";
	public const string BookIronOreGather2 = "book_iron_ore_gather_2";
	public const string BookIronOreGather3 = "book_iron_ore_gather_3";
	public const string BookIronOreGather4 = "book_iron_ore_gather_4";
	public const string BookIronOreGather5 = "book_iron_ore_gather_5";
	public const string BookIronOreGather6 = "book_iron_ore_gather_6";
	public const string BookIronOreGather7 = "book_iron_ore_gather_7";
	public const string BookIronOreGather8 = "book_iron_ore_gather_8";
	public const string BookIronOreGather9 = "book_iron_ore_gather_9";
	public const string BookIronOreGather10 = "book_iron_ore_gather_10";
	public const string BookBirchWoodGather1 = "book_birch_wood_gather_1";
	public const string BookBirchWoodGather2 = "book_birch_wood_gather_2";
	public const string BookBirchWoodGather3 = "book_birch_wood_gather_3";
	public const string BookBirchWoodGather4 = "book_birch_wood_gather_4";
	public const string BookBirchWoodGather5 = "book_birch_wood_gather_5";
	public const string BookBirchWoodGather6 = "book_birch_wood_gather_6";
	public const string BookBirchWoodGather7 = "book_birch_wood_gather_7";
	public const string BookBirchWoodGather8 = "book_birch_wood_gather_8";
	public const string BookBirchWoodGather9 = "book_birch_wood_gather_9";
	public const string BookBirchWoodGather10 = "book_birch_wood_gather_10";
	public const string BookPlayerSpeed1 = "book_player_speed_1";
	public const string BookPlayerSpeed2 = "book_player_speed_2";
	public const string BookPlayerSpeed3 = "book_player_speed_3";
	public const string BookPlayerSpeed4 = "book_player_speed_4";
	public const string BookPlayerSpeed5 = "book_player_speed_5";
	public const string BookPlayerSpeed6 = "book_player_speed_6";
	public const string BookPlayerSpeed7 = "book_player_speed_7";
	public const string BookPlayerSpeed8 = "book_player_speed_8";
	public const string BookPlayerSpeed9 = "book_player_speed_9";
	public const string BookPlayerSpeed10 = "book_player_speed_10";
	public const string BookPlayerHealth1 = "book_player_health_1";
	public const string BookPlayerHealth2 = "book_player_health_2";
	public const string BookPlayerHealth3 = "book_player_health_3";
	public const string BookPlayerHealth4 = "book_player_health_4";
	public const string BookPlayerHealth5 = "book_player_health_5";
	public const string BookPlayerHealth6 = "book_player_health_6";
	public const string BookPlayerHealth7 = "book_player_health_7";
	public const string BookPlayerHealth8 = "book_player_health_8";
	public const string BookPlayerHealth9 = "book_player_health_9";
	public const string BookPlayerHealth10 = "book_player_health_10";
	public const string BookPlayerHealth11 = "book_player_health_11";
	public const string BookPlayerHealth12 = "book_player_health_12";
	public const string BookPlayerHealth13 = "book_player_health_13";
	public const string BookPlayerHealth14 = "book_player_health_14";
	public const string BookPlayerHealth15 = "book_player_health_15";
	public const string BookPlayerThirst1 = "book_player_thirst_1";
	public const string BookPlayerThirst2 = "book_player_thirst_2";
	public const string BookPlayerThirst3 = "book_player_thirst_3";
	public const string BookPlayerThirst4 = "book_player_thirst_4";
	public const string BookPlayerThirst5 = "book_player_thirst_5";
	public const string BookPlayerThirst6 = "book_player_thirst_6";
	public const string BookPlayerThirst7 = "book_player_thirst_7";
	public const string BookPlayerThirst8 = "book_player_thirst_8";
	public const string BookPlayerThirst9 = "book_player_thirst_9";
	public const string BookPlayerThirst10 = "book_player_thirst_10";
	public const string BookPlayerHunger1 = "book_player_hunger_1";
	public const string BookPlayerHunger2 = "book_player_hunger_2";
	public const string BookPlayerHunger3 = "book_player_hunger_3";
	public const string BookPlayerHunger4 = "book_player_hunger_4";
	public const string BookPlayerHunger5 = "book_player_hunger_5";
	public const string BookPlayerHunger6 = "book_player_hunger_6";
	public const string BookPlayerHunger7 = "book_player_hunger_7";
	public const string BookPlayerHunger8 = "book_player_hunger_8";
	public const string BookPlayerHunger9 = "book_player_hunger_9";
	public const string BookPlayerHunger10 = "book_player_hunger_10";
	public const string BookTorchDurability1 = "book_torch_durability_1";
	public const string BookTorchDurability2 = "book_torch_durability_2";
	public const string BookTorchDurability3 = "book_torch_durability_3";
	public const string BookTorchDurability4 = "book_torch_durability_4";
	public const string BookTorchDurability5 = "book_torch_durability_5";
	public const string BookTorchDurability6 = "book_torch_durability_6";
	public const string BookTorchDurability7 = "book_torch_durability_7";
	public const string BookTorchDurability8 = "book_torch_durability_8";
	public const string BookTorchDurability9 = "book_torch_durability_9";
	public const string BookTorchDurability10 = "book_torch_durability_10";
	public const string BookMapWalk1 = "book_map_walk_1";
	public const string BookMapWalk2 = "book_map_walk_2";
	public const string BookMapWalk3 = "book_map_walk_3";
	public const string BookMapWalk4 = "book_map_walk_4";
	public const string BookMapWalk5 = "book_map_walk_5";
	public const string BookMapWalk6 = "book_map_walk_6";
	public const string BookMapWalk7 = "book_map_walk_7";
	public const string BookMapWalk8 = "book_map_walk_8";
	public const string BookMapWalk9 = "book_map_walk_9";
	public const string BookMapWalk10 = "book_map_walk_10";
	public const string BookHpRestore1 = "book_hp_restore_1";
	public const string BookHpRestore2 = "book_hp_restore_2";
	public const string BookHpRestore3 = "book_hp_restore_3";
	public const string BookHpRestore4 = "book_hp_restore_4";
	public const string BookHpRestore5 = "book_hp_restore_5";
	public const string BookHpRestore6 = "book_hp_restore_6";
	public const string BookHpRestore7 = "book_hp_restore_7";
	public const string BookHpRestore8 = "book_hp_restore_8";
	public const string BookHpRestore9 = "book_hp_restore_9";
	public const string BookHpRestore10 = "book_hp_restore_10";
	public const string BookPlayerArmor1 = "book_player_armor_1";
	public const string BookPlayerArmor2 = "book_player_armor_2";
	public const string BookPlayerArmor3 = "book_player_armor_3";
	public const string BookPlayerArmor4 = "book_player_armor_4";
	public const string BookPlayerArmor5 = "book_player_armor_5";
	public const string BookPlayerArmor6 = "book_player_armor_6";
	public const string BookPlayerArmor7 = "book_player_armor_7";
	public const string BookPlayerArmor8 = "book_player_armor_8";
	public const string BookPlayerArmor9 = "book_player_armor_9";
	public const string BookPlayerArmor10 = "book_player_armor_10";
	public const string BookPlayerPoison1 = "book_player_poison_1";
	public const string BookPlayerPoison2 = "book_player_poison_2";
	public const string BookPlayerPoison3 = "book_player_poison_3";
	public const string BookPlayerPoison4 = "book_player_poison_4";
	public const string BookPlayerPoison5 = "book_player_poison_5";
	public const string BookPlayerPoison6 = "book_player_poison_6";
	public const string BookPlayerPoison7 = "book_player_poison_7";
	public const string BookPlayerPoison8 = "book_player_poison_8";
	public const string BookPlayerPoison9 = "book_player_poison_9";
	public const string BookPlayerPoison10 = "book_player_poison_10";
	public const string BookPoisonResist1 = "book_poison_resist_1";
	public const string BookPoisonResist2 = "book_poison_resist_2";
	public const string BookPoisonResist3 = "book_poison_resist_3";
	public const string BookPoisonResist4 = "book_poison_resist_4";
	public const string BookPoisonResist5 = "book_poison_resist_5";
	public const string BookPoisonResist6 = "book_poison_resist_6";
	public const string BookPoisonResist7 = "book_poison_resist_7";
	public const string BookPoisonResist8 = "book_poison_resist_8";
	public const string BookPoisonResist9 = "book_poison_resist_9";
	public const string BookPoisonResist10 = "book_poison_resist_10";
	public const string BookPoisonResist11 = "book_poison_resist_11";
	public const string BookPoisonResist12 = "book_poison_resist_12";
	public const string BookPoisonResist13 = "book_poison_resist_13";
	public const string BookPoisonResist14 = "book_poison_resist_14";
	public const string BookPoisonResist15 = "book_poison_resist_15";
	public const string BookStunResist1 = "book_stun_resist_1";
	public const string BookStunResist2 = "book_stun_resist_2";
	public const string BookStunResist3 = "book_stun_resist_3";
	public const string BookStunResist4 = "book_stun_resist_4";
	public const string BookStunResist5 = "book_stun_resist_5";
	public const string BookStunResist6 = "book_stun_resist_6";
	public const string BookStunResist7 = "book_stun_resist_7";
	public const string BookStunResist8 = "book_stun_resist_8";
	public const string BookStunResist9 = "book_stun_resist_9";
	public const string BookStunResist10 = "book_stun_resist_10";
	public const string BookResurrection1 = "book_resurrection_1";
	public const string BookResurrection2 = "book_resurrection_2";
	public const string BookResurrection3 = "book_resurrection_3";
	public const string BookResurrection4 = "book_resurrection_4";
	public const string BookResurrection5 = "book_resurrection_5";
	public const string BookResurrection6 = "book_resurrection_6";
	public const string BookResurrection7 = "book_resurrection_7";
	public const string BookResurrection8 = "book_resurrection_8";
	public const string BookResurrection9 = "book_resurrection_9";
	public const string BookResurrection10 = "book_resurrection_10";
	public const string BookAdrenalin1 = "book_adrenalin_1";
	public const string BookAdrenalin2 = "book_adrenalin_2";
	public const string BookAdrenalin3 = "book_adrenalin_3";
	public const string BookAdrenalin4 = "book_adrenalin_4";
	public const string BookAdrenalin5 = "book_adrenalin_5";
	public const string BookEnergyBoost1 = "book_energy_boost_1";
	public const string BookEnergyBoost2 = "book_energy_boost_2";
	public const string BookEnergyBoost3 = "book_energy_boost_3";
	public const string BookEnergyBoost4 = "book_energy_boost_4";
	public const string BookEnergyBoost5 = "book_energy_boost_5";
	public const string BookEnergyBoost6 = "book_energy_boost_6";
	public const string BookEnergyBoost7 = "book_energy_boost_7";
	public const string BookEnergyBoost8 = "book_energy_boost_8";
	public const string BookEnergyBoost9 = "book_energy_boost_9";
	public const string BookEnergyBoost10 = "book_energy_boost_10";
	public const string BookTrapDamage1 = "book_trap_damage_1";
	public const string BookTrapDamage2 = "book_trap_damage_2";
	public const string BookTrapDamage3 = "book_trap_damage_3";
	public const string BookTrapDamage4 = "book_trap_damage_4";
	public const string BookTrapDamage5 = "book_trap_damage_5";
	public const string BookTrapDamage6 = "book_trap_damage_6";
	public const string BookTrapDamage7 = "book_trap_damage_7";
	public const string BookTrapDamage8 = "book_trap_damage_8";
	public const string BookTrapDamage9 = "book_trap_damage_9";
	public const string BookTrapDamage10 = "book_trap_damage_10";
	public const string BookSpeedBoost1 = "book_speed_boost_1";
	public const string BookSpeedBoost2 = "book_speed_boost_2";
	public const string BookSpeedBoost3 = "book_speed_boost_3";
	public const string BookSpeedBoost4 = "book_speed_boost_4";
	public const string BookSpeedBoost5 = "book_speed_boost_5";
	public const string BookSpeedBoost6 = "book_speed_boost_6";
	public const string BookSpeedBoost7 = "book_speed_boost_7";
	public const string BookSpeedBoost8 = "book_speed_boost_8";
	public const string BookSpeedBoost9 = "book_speed_boost_9";
	public const string BookSpeedBoost10 = "book_speed_boost_10";
	public const string BookArmorBoost1 = "book_armor_boost_1";
	public const string BookArmorBoost2 = "book_armor_boost_2";
	public const string BookArmorBoost3 = "book_armor_boost_3";
	public const string BookArmorBoost4 = "book_armor_boost_4";
	public const string BookArmorBoost5 = "book_armor_boost_5";
	public const string BookArmorBoost6 = "book_armor_boost_6";
	public const string BookArmorBoost7 = "book_armor_boost_7";
	public const string BookArmorBoost8 = "book_armor_boost_8";
	public const string BookArmorBoost9 = "book_armor_boost_9";
	public const string BookArmorBoost10 = "book_armor_boost_10";
	public const string BookArmorBoost11 = "book_armor_boost_11";
	public const string BookArmorBoost12 = "book_armor_boost_12";
	public const string BookArmorBoost13 = "book_armor_boost_13";
	public const string BookArmorBoost14 = "book_armor_boost_14";
	public const string BookArmorBoost15 = "book_armor_boost_15";
	public const string BookLookAround1 = "book_look_around_1";
	public const string BookLookAround2 = "book_look_around_2";
	public const string BookLookAround3 = "book_look_around_3";
	public const string BookLookAround4 = "book_look_around_4";
	public const string BookLookAround5 = "book_look_around_5";
	public const string BookLookAround6 = "book_look_around_6";
	public const string BookLookAround7 = "book_look_around_7";
	public const string BookLookAround8 = "book_look_around_8";
	public const string BookLookAround9 = "book_look_around_9";
	public const string BookLookAround10 = "book_look_around_10";
	public const string BookDamageAround1 = "book_damage_around_1";
	public const string BookDamageAround2 = "book_damage_around_2";
	public const string BookDamageAround3 = "book_damage_around_3";
	public const string BookDamageAround4 = "book_damage_around_4";
	public const string BookDamageAround5 = "book_damage_around_5";
	public const string BookDamageAround6 = "book_damage_around_6";
	public const string BookDamageAround7 = "book_damage_around_7";
	public const string BookDamageAround8 = "book_damage_around_8";
	public const string BookDamageAround9 = "book_damage_around_9";
	public const string BookDamageAround10 = "book_damage_around_10";
	public const string BookDamageAround11 = "book_damage_around_11";
	public const string BookDamageAround12 = "book_damage_around_12";
	public const string BookDamageAround13 = "book_damage_around_13";
	public const string BookDamageAround14 = "book_damage_around_14";
	public const string BookDamageAround15 = "book_damage_around_15";
	public const string BookScareNg1 = "book_scare_ng_1";
	public const string BookScareNg2 = "book_scare_ng_2";
	public const string BookScareNg3 = "book_scare_ng_3";
	public const string BookScareNg4 = "book_scare_ng_4";
	public const string BookScareNg5 = "book_scare_ng_5";
	public const string BookScareNg6 = "book_scare_ng_6";
	public const string BookScareNg7 = "book_scare_ng_7";
	public const string BookScareNg8 = "book_scare_ng_8";
	public const string BookScareNg9 = "book_scare_ng_9";
	public const string BookScareNg10 = "book_scare_ng_10";
	public const string BookSuperHit1 = "book_super_hit_1";
	public const string BookSuperHit2 = "book_super_hit_2";
	public const string BookSuperHit3 = "book_super_hit_3";
	public const string BookSuperHit4 = "book_super_hit_4";
	public const string BookSuperHit5 = "book_super_hit_5";
	public const string BookSuperHit6 = "book_super_hit_6";
	public const string BookSuperHit7 = "book_super_hit_7";
	public const string BookSuperHit8 = "book_super_hit_8";
	public const string BookSuperHit9 = "book_super_hit_9";
	public const string BookSuperHit10 = "book_super_hit_10";
	public const string BookSuperHit11 = "book_super_hit_11";
	public const string BookSuperHit12 = "book_super_hit_12";
	public const string BookSuperHit13 = "book_super_hit_13";
	public const string BookSuperHit14 = "book_super_hit_14";
	public const string BookSuperHit15 = "book_super_hit_15";
	public const string BookDamageReflection1 = "book_damage_reflection_1";
	public const string BookDamageReflection2 = "book_damage_reflection_2";
	public const string BookDamageReflection3 = "book_damage_reflection_3";
	public const string BookDamageReflection4 = "book_damage_reflection_4";
	public const string BookDamageReflection5 = "book_damage_reflection_5";
	public const string BookDamageReflection6 = "book_damage_reflection_6";
	public const string BookDamageReflection7 = "book_damage_reflection_7";
	public const string BookDamageReflection8 = "book_damage_reflection_8";
	public const string BookDamageReflection9 = "book_damage_reflection_9";
	public const string BookDamageReflection10 = "book_damage_reflection_10";
	public const string BookDamageReflection11 = "book_damage_reflection_11";
	public const string BookDamageReflection12 = "book_damage_reflection_12";
	public const string BookDamageReflection13 = "book_damage_reflection_13";
	public const string BookDamageReflection14 = "book_damage_reflection_14";
	public const string BookDamageReflection15 = "book_damage_reflection_15";
	public const string BookSuperHitStun1 = "book_super_hit_stun_1";
	public const string BookSuperHitStun2 = "book_super_hit_stun_2";
	public const string BookSuperHitStun3 = "book_super_hit_stun_3";
	public const string BookSuperHitStun4 = "book_super_hit_stun_4";
	public const string BookSuperHitStun5 = "book_super_hit_stun_5";
	public const string BookSuperHitStun6 = "book_super_hit_stun_6";
	public const string BookSuperHitStun7 = "book_super_hit_stun_7";
	public const string BookSuperHitStun8 = "book_super_hit_stun_8";
	public const string BookSuperHitStun9 = "book_super_hit_stun_9";
	public const string BookSuperHitStun10 = "book_super_hit_stun_10";
	public const string BookSuperHitStun11 = "book_super_hit_stun_11";
	public const string BookSuperHitStun12 = "book_super_hit_stun_12";
	public const string BookSuperHitStun13 = "book_super_hit_stun_13";
	public const string BookSuperHitStun14 = "book_super_hit_stun_14";
	public const string BookSuperHitStun15 = "book_super_hit_stun_15";
	public const string BookBecomeStone1 = "book_become_stone_1";
	public const string BookBecomeStone2 = "book_become_stone_2";
	public const string BookBecomeStone3 = "book_become_stone_3";
	public const string BookBecomeStone4 = "book_become_stone_4";
	public const string BookBecomeStone5 = "book_become_stone_5";
	public const string BookBecomeStone6 = "book_become_stone_6";
	public const string BookBecomeStone7 = "book_become_stone_7";
	public const string BookBecomeStone8 = "book_become_stone_8";
	public const string BookBecomeStone9 = "book_become_stone_9";
	public const string BookBecomeStone10 = "book_become_stone_10";
	public const string BookBecomeStone11 = "book_become_stone_11";
	public const string BookBecomeStone12 = "book_become_stone_12";
	public const string BookBecomeStone13 = "book_become_stone_13";
	public const string BookBecomeStone14 = "book_become_stone_14";
	public const string BookBecomeStone15 = "book_become_stone_15";
	public const string BookRestraint1 = "book_restraint_1";
	public const string BookRestraint2 = "book_restraint_2";
	public const string BookRestraint3 = "book_restraint_3";
	public const string BookRestraint4 = "book_restraint_4";
	public const string BookRestraint5 = "book_restraint_5";
	public const string BookRestraint6 = "book_restraint_6";
	public const string BookRestraint7 = "book_restraint_7";
	public const string BookRestraint8 = "book_restraint_8";
	public const string BookRestraint9 = "book_restraint_9";
	public const string BookRestraint10 = "book_restraint_10";
	public const string BookRestraint11 = "book_restraint_11";
	public const string BookRestraint12 = "book_restraint_12";
	public const string BookRestraint13 = "book_restraint_13";
	public const string BookRestraint14 = "book_restraint_14";
	public const string BookRestraint15 = "book_restraint_15";
	public const string BookCurse1 = "book_curse_1";
	public const string BookCurse2 = "book_curse_2";
	public const string BookCurse3 = "book_curse_3";
	public const string BookCurse4 = "book_curse_4";
	public const string BookCurse5 = "book_curse_5";
	public const string BookCurse6 = "book_curse_6";
	public const string BookCurse7 = "book_curse_7";
	public const string BookCurse8 = "book_curse_8";
	public const string BookCurse9 = "book_curse_9";
	public const string BookCurse10 = "book_curse_10";
	public const string BookCurse11 = "book_curse_11";
	public const string BookCurse12 = "book_curse_12";
	public const string BookCurse13 = "book_curse_13";
	public const string BookCurse14 = "book_curse_14";
	public const string BookCurse15 = "book_curse_15";
	public const string ResearchForTortureChair = "research_for_torture_chair";
	public const string ResearchForBomb = "research_for_bomb";
	public const string ResearchForShieldHeavy = "research_for_shield_heavy";
	public const string ResearchForShieldBuckler = "research_for_shield_buckler";
	public const string ResearchForWorkbenchGrind = "research_for_workbench_grind";
	public const string ResearchForKriegsmesser = "research_for_kriegsmesser";
	public const string ResearchForWorkbenchAlchemist = "research_for_workbench_alchemist";
	public const string ResearchForRackWeapon = "research_for_rack_weapon";
	public const string ResearchForRackArmor = "research_for_rack_armor";
	public const string ResearchForStrappado = "research_for_strappado";
	public const string ResearchForChestShared = "research_for_chest_shared";
	public const string ResearchForChaperonHat = "research_for_chaperon_hat";
	public const string ResearchForAiletteShirt = "research_for_ailette_shirt";
	public const string ResearchForHaltBag = "research_for_halt_bag";
	public const string ResearchForBlastFurnace = "research_for_blast_furnace";
	public const string ResearchForIronmaidenBag = "research_for_ironmaiden_bag";
	public const string ResearchForBechterShirt = "research_for_bechter_shirt";
	public const string ResearchForHornedHat = "research_for_horned_hat";
	public const string ResearchForPlagueHat = "research_for_plague_hat";
	public const string ResearchForPlagueShirt = "research_for_plague_shirt";
	public const string ResearchForPlagueGloves = "research_for_plague_gloves";
	public const string ResearchForPlaguePants = "research_for_plague_pants";
	public const string ResearchForPlagueBoots = "research_for_plague_boots";
	public const string ResearchForFalchionKiller = "research_for_falchion_killer";
	public const string ResearchForPernachNovice = "research_for_pernach_novice";
	public const string ResearchForFlamingBag = "research_for_flaming_bag";
	public const string ResearchForKhopesh = "research_for_khopesh";
	public const string ResearchForRitterschwert = "research_for_ritterschwert";
	public const string ResearchForBarbuteHat = "research_for_barbute_hat";
	public const string ResearchForWarlockHat = "research_for_warlock_hat";
	public const string ResearchForWarlockShirt = "research_for_warlock_shirt";
	public const string ResearchForWarlockPants = "research_for_warlock_pants";
	public const string ResearchForWarlockGloves = "research_for_warlock_gloves";
	public const string ResearchForWarlockBoots = "research_for_warlock_boots";
	public const string ResearchForSoldierHat = "research_for_soldier_hat";
	public const string ResearchForSoldierShirt = "research_for_soldier_shirt";
	public const string ResearchForSoldierGloves = "research_for_soldier_gloves";
	public const string ResearchForSoldierPants = "research_for_soldier_pants";
	public const string ResearchForSoldierBoots = "research_for_soldier_boots";
	public const string ResearchForMorgensternNovice = "research_for_morgenstern_novice";
	public const string ResearchForJambia = "research_for_jambia";
	public const string ResearchForAventailHat = "research_for_aventail_hat";
	public const string ResearchForBearHat = "research_for_bear_hat";
	public const string ResearchForBearShirt = "research_for_bear_shirt";
	public const string ResearchForBearGloves = "research_for_bear_gloves";
	public const string ResearchForBearPants = "research_for_bear_pants";
	public const string ResearchForBearBoots = "research_for_bear_boots";
	public const string ResearchForPullenBoots = "research_for_pullen_boots";
	public const string ResearchForWorkbenchArmor = "research_for_workbench_armor";
	public const string ResearchForMaceAztec = "research_for_mace_aztec";
	public const string ResearchForShovelMonk = "research_for_shovel_monk";
	public const string ResearchForStrawHat = "research_for_straw_hat";
	public const string ResearchForDoubletShirt = "research_for_doublet_shirt";
	public const string ResearchForDragonHat = "research_for_dragon_hat";
	public const string ResearchForDragonShirt = "research_for_dragon_shirt";
	public const string ResearchForDragonPants = "research_for_dragon_pants";
	public const string ResearchForDragonBoots = "research_for_dragon_boots";
	public const string ResearchForDragonGloves = "research_for_dragon_gloves";
	public const string ResearchForNokerHat = "research_for_noker_hat";
	public const string ResearchForNokerShirt = "research_for_noker_shirt";
	public const string ResearchForNokerGloves = "research_for_noker_gloves";
	public const string ResearchForNokerPants = "research_for_noker_pants";
	public const string ResearchForNokerBoots = "research_for_noker_boots";
	public const string ResearchForCitizenHat = "research_for_citizen_hat";
	public const string ResearchForCitizenShirt = "research_for_citizen_shirt";
	public const string ResearchForCitizenGloves = "research_for_citizen_gloves";
	public const string ResearchForCitizenPants = "research_for_citizen_pants";
	public const string ResearchForCitizenBoots = "research_for_citizen_boots";
	public const string ResearchForWoodenSword = "research_for_wooden_sword";
	public const string ResearchForKatana = "research_for_katana";
	public const string ResearchForBardHat = "research_for_bard_hat";
	public const string ResearchForBardShirt = "research_for_bard_shirt";
	public const string ResearchForBardGloves = "research_for_bard_gloves";
	public const string ResearchForBardPants = "research_for_bard_pants";
	public const string ResearchForBardBoots = "research_for_bard_boots";
	public const string ResearchForRapier = "research_for_rapier";
	public const string ResearchForDuelistHat = "research_for_duelist_hat";
	public const string ResearchForDuelistShirt = "research_for_duelist_shirt";
	public const string ResearchForDuelistPants = "research_for_duelist_pants";
	public const string ResearchForDuelistBoots = "research_for_duelist_boots";
	public const string ResearchForDuelistGloves = "research_for_duelist_gloves";
	public const string ResearchForSwordCrusher = "research_for_sword_crusher";
	public const string ResearchForEastChampionHat = "research_for_east_champion_hat";
	public const string ResearchForEastChampionShirt = "research_for_east_champion_shirt";
	public const string ResearchForEastChampionPants = "research_for_east_champion_pants";
	public const string ResearchForEastChampionBoots = "research_for_east_champion_boots";
	public const string ResearchForEastChampionGloves = "research_for_east_champion_gloves";
	public const string ResearchForDiplomatHat = "research_for_diplomat_hat";
	public const string ResearchForDiplomatShirt = "research_for_diplomat_shirt";
	public const string ResearchForDiplomatGloves = "research_for_diplomat_gloves";
	public const string ResearchForDiplomatPants = "research_for_diplomat_pants";
	public const string ResearchForDiplomatBoots = "research_for_diplomat_boots";
	public const string ResearchForYataghan = "research_for_yataghan";
	public const string ResearchForKamiz = "research_for_kamiz";
	public const string ResearchForBlackWarriorHat = "research_for_black_warrior_hat";
	public const string ResearchForBlackWarriorShirt = "research_for_black_warrior_shirt";
	public const string ResearchForBlackWarriorPants = "research_for_black_warrior_pants";
	public const string ResearchForBlackWarriorBoots = "research_for_black_warrior_boots";
	public const string ResearchForBlackWarriorGloves = "research_for_black_warrior_gloves";
	public const string ResearchForBroom = "research_for_broom";
	public const string ResearchForRogvoldBag = "research_for_rogvold_bag";
	public const string ResearchForPiligrimHat = "research_for_piligrim_hat";
	public const string ResearchForPiligrimShirt = "research_for_piligrim_shirt";
	public const string ResearchForPiligrimGloves = "research_for_piligrim_gloves";
	public const string ResearchForPiligrimPants = "research_for_piligrim_pants";
	public const string ResearchForPiligrimBoots = "research_for_piligrim_boots";
	public const string ResearchForPiligrimBag = "research_for_piligrim_bag";
	public const string ResearchForPoleaxe = "research_for_poleaxe";
	public const string ResearchForSnowHunterHat = "research_for_snow_hunter_hat";
	public const string ResearchForSnowHunterShirt = "research_for_snow_hunter_shirt";
	public const string ResearchForSnowHunterGloves = "research_for_snow_hunter_gloves";
	public const string ResearchForSnowHunterPants = "research_for_snow_hunter_pants";
	public const string ResearchForSnowHunterBoots = "research_for_snow_hunter_boots";
	public const string ResearchForWorkbenchWeapon = "research_for_workbench_weapon";
	public const string ResearchForHatchetArtisan = "research_for_hatchet_artisan";
	public const string ResearchForPickaxeArtisan = "research_for_pickaxe_artisan";
	public const string ResearchForMourningReaperHat = "research_for_mourning_reaper_hat";
	public const string ResearchForMourningReaperShirt = "research_for_mourning_reaper_shirt";
	public const string ResearchForMourningReaperGloves = "research_for_mourning_reaper_gloves";
	public const string ResearchForMourningReaperPants = "research_for_mourning_reaper_pants";
	public const string ResearchForMourningReaperBoots = "research_for_mourning_reaper_boots";

	]],
        },
		[9] = {
		 Name = '👑 Instant Lvl 200',
			_Name = '9EXP',
			Method = 'get_amount',
			Class = 'ExperienceResource',
			Edit = {[1] = '~A MOVW R0, #19156',[2] = '~A MOVW R1,  #22418',[3] = '~A MUL R0, R0, R1',[4] = '~A MOVW R1,  #63992',[5] = '~A ADD R1, R0, R1',[6] = '~A VMOV S0, R0',[7] = '~A VCVT.F64.U32 D0, S0',[8] = '~A VMOV R0, R1, D0',[9] = '1EFF2FE1r',},
			},
		[10] = {
			Name = '🏃 Fast Travel',
			_Name = '10Travel',
			Method = 'get_walkSpeed',
			Class = 'MapMovement',
			Edit = {[1] = '~A MOVW R0, #666',[2] = '100A00EEr',[3] = 'C00AB8EEr',[4] = '100A10EEr',[5] = '1EFF2FE1r',},
			  },
		[11] = {
				Name = '⚓️ Max Durability',
				_Name = '11Dura',
				Method = 'get_Durability',
				Class = 'DurabilityInventoryStack',
				Edit = {[1] = '~A MOVW R0, #999',[2] = '~A VMOV S0, R0',[3] = '~A VCVT.F64.U32 D0, S0',[4] = '~A VMOV R0, R1, D0',[5] = '1EFF2FE1r',},
			   },
		[12] = {
			Name = '💣 Attack Damage',
			_Name = '12Dmg',
			Method = 'GetWeaponDamageBonus',
			Class = 'WeaponAttackActivity',
			Edit = {[1] = '~A MOVW R0, #6666',[2] = '~A bx lr'},
		},


    },
    ['Engine'] = {
        MENU = {},
        FN = {},
        One = true,
        Two = false,
		alr = 1,
        update = function(self) 
			info = gg.getTargetInfo()
            if self.One == true then
				if info.x64 == true then gg.alert("This script meant for 32Bit users it wont work for you. \n Thank you for your understanding! \n \n ~ ARC") os.exit(); else
               		gg.toast("♥ Made by Arc ♥",true)

				for i = 1,#ARC.Data do 
                self.FN[ARC.Data[i]._Name] = ARC.Worker(ARC.Data[i])
                self.MENU[ARC.Data[i]._Name] = self.FN[ARC.Data[i]._Name].Name..self.FN[ARC.Data[i]._Name].Status
				end
                self.One = false
				
					
				end
            end
            if self.Two == true then
                for i,v in pairs(self.MENU) do
                    if tempMenu == nil then break; end
                    self.MENU[tempMenu] = self.FN[tempMenu].Name..self.FN[tempMenu].Status
                end
				

            end
        end,
    },
}
gg.clearList()
gg.clearResults()
gg.showUiButton()
while true do
	ARC.Engine:update()
    if gg.isClickedUiButton() then
        tempMenu = gg.choice(ARC.Engine.MENU,nil,nil)
        if tempMenu ~= nil then 
			if tempMenu == '12Dmg' and ARC.Engine.alr == 1 then gg.alert('Please make sure to attack any enemy once.\n Otherwise the script will crash') ARC.Engine.alr = 0
			else
            ARC.Engine.Two = true
			ARC.Engine.FN[tempMenu]:Slave()
			end
        end
    end
end

