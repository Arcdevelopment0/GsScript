

ARCEXE = {
	['SB'] = function(str)
		local strtab = {}
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
	local adr = 8
	if Info.x64 == true then adr = adr * 2 end
		local val1 = string.format('%08X', val):sub(-adr)
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
    local Final = {}
    local check = {}
    local ch = nil
    for mark,id in str:gmatch('public const string (%g+) = "(%g+)";') do 
        if not id:match('tome') and not id:match('perk') then 
        if id:match('(.-%_*)(%d+)') ~= nil and id:match('book') ~= nil or id:match('grind') ~= nil  then 
          local ne,ol = id:match('(.-%_*)(%d+)')
          if ch ~= ne and ch~= nil then 
            Final[#Final+1] = {['Mark'] = tostring(mark:gsub("(%l)(%u)", "%1 %2")):gsub('%d+',''),['ID'] = tostring(check[#check])}
          end
          check[#check + 1 ] = id
          ch = ne
        else
        Final[#Final+1] = {['Mark'] = tostring(mark:gsub("(%l)(%u)", "%1 %2")),['ID'] = tostring(id)} 
        end
      end
    end
    for k,v in ipairs(Final) do 
      Final[k]['Pointer'] = nil
      Final[k]['FS'] = ''
      Final[k].update = function(self)
        if self.Pointer ~= nil then self.FS = 'Fast ►  ' else
        self.FS = 'Slow ►  '
        end
      end
    end
	return Final
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
		local method_name_edit = {}
		for i = 1 ,edit do 
			method_name_edit[i] = {address = nil ,flags = FLAG() }
		end
        local flag_type = FLAG()
        gg.setRanges(gg.REGION_OTHER)
                gg.clearResults()
                gg.searchNumber(ARCEXE.SB(method_name), gg.TYPE_BYTE, false, gg.SIGN_EQUAL,nil,nil,1)
                String_address = gg.getResults(1)
                String_address = String_address[1].address
                gg.clearResults()
                gg.setRanges(gg.REGION_C_ALLOC)
				::try_C::
                gg.searchNumber(String_address, flag_type)
                local class_headers = gg.getResults(gg.getResultsCount())
                local class_headers_pointer = class_headers
                if gg.getResultsCount() == 1 then 
                    class_headers_pointer[1].address =  class_headers_pointer[1].address - OFFSET(8)
                    class_headers_pointer = gg.getValues(class_headers_pointer)

                    method_name_edit[1].address = ARCEXE.hex(class_headers_pointer[1].value,true)
                elseif gg.getResultsCount() > 1 then
                    for i, v in pairs(class_headers) do
                            class_headers[i].address = class_headers[i].address + OFFSET(4)
                            class_headers = gg.getValues(class_headers)
                            class_headers[i].address = ARCEXE.hex(class_headers[i].value + OFFSET(8) ,true)
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
                            
                    class_headers_pointer[k].address =  class_headers_pointer[k].address - OFFSET(8) 
                    class_headers_pointer = gg.getValues(class_headers_pointer)

                    method_name_edit[1].address = ARCEXE.hex(class_headers_pointer[k].value,true)
                        end
                    end
                end
                    gg.clearResults()
					if method_name_edit[1].address == nil then gg.setRanges(gg.REGION_C_DATA | gg.REGION_ANONYMOUS | gg.REGION_C_BSS) goto try_C else
					for k = 2 ,#method_name_edit do 
						method_name_edit[k].address = method_name_edit[k-1].address + 4
					end
					
                    return method_name_edit
                    end
                end,
	['CH'] = function(class,offset) 
		Result = {}
		flag_type = FLAG()
		FieldSearch = ARCEXE.SB(class)
		gg.setRanges(gg.REGION_OTHER)
		gg.clearResults()
		gg.searchNumber(FieldSearch, gg.TYPE_BYTE, false, gg.SIGN_EQUAL,nil,nil,1)
		String_address = gg.getResults(1)
		String_address = String_address[1].address
		gg.clearResults()
		gg.setRanges(gg.REGION_C_ALLOC)
		::try_emulator::
		gg.searchNumber(String_address, flag_type)
		class_headers = gg.getResults(gg.getResultsCount())
		if gg.getResultsCount() == 0 then gg.setRanges(gg.REGION_C_DATA | gg.REGION_ANONYMOUS | gg.REGION_C_BSS) goto try_emulator end
			for i, v in pairs(class_headers) do
					class_headers[i].address = class_headers[i].address - OFFSET(8)
			end
		
			gg.setRanges(gg.REGION_ANONYMOUS)
			gg.loadResults(class_headers)
			gg.searchPointer(0)
			Result =  gg.getResults(gg.getResultsCount())
			for i, v in pairs(Result) do
				Result[i].address = Result[i].address + OFFSET(offset)
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
                                  self.val.Pointer = ARCEXE.MH(self.Method,self.Class,#self.val.Edit[OFFSET(1)]) 
								  self.val.Pointer = gg.getValues(self.val.Pointer)
					  end
                                  for i=1,#self.val.Edit[OFFSET(1)] do 
                                    self.val.Restore[i] = self.val.Pointer[i].value
                                    if self.val.Pointer[i].address == nil or self.val.Pointer[i].value == nil then 
                                    self.val.Pointer[i].address = self.val.Pointer[i-1].address + 4
                                    self.val.Pointer[i].flags = gg.TYPE_DWORD
                                    self.val.Pointer = gg.getValues(self.val.Pointer) end
                                  end
                      for k,v in pairs(self.val.Pointer) do 
                        self.val.Pointer[k].value = self.val.Edit[OFFSET(1)][k]
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
                        self.val.Items = ARCEXE.CL(self.val.Enum) end
                        
                        self.val.Temp_ = ARCEXE.CH(self.Class,self.offset)
						self.val.Temp_ = gg.getValues(self.val.Temp_)
						for k = 1, #self.val.Temp_ do 
				
							self.val.Restore[k] = self.val.Temp_[k].value
						end
						for k,v in pairs(self.val.Temp_) do 
							if self.val.Temp_[k].value == '0' or self.val.Temp_[k].value == '1' and self.val.Temp_[k].value ~= nil 
							then table.remove(self.val.Temp_,k) end
						end
                        gg.clearResults()
                        Lowend = gg.choice({"Low-End Device","High End Device"},"Low End will set all items to Slow",nil)
						if Lowend == 1 then goto low else
                        for k,v in pairs(self.val.Temp_) do  
                        DumpedItem = {
                            [1] = {address = ARCEXE.hex(self.val.Temp_[k].value,true),
                            flags = gg.TYPE_DWORD,
                            name = "START"},
                            [2]= {
                            address = ARCEXE.hex(self.val.Temp_[k].value + OFFSET(8) ,true) ,
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
                        Item_name[i-2] = ARCEXE.DT(DumpedItem[i].value)
                        end
                        local iden = table.concat(Item_name)
                          for index,value in pairs(self.val.Items) do 
                            if self.val.Items[index].ID == iden and self.val.Items[index].Pointer == nil then
                            self.val.Items[index].Pointer =  ARCEXE.hex(self.val.Temp_[k].value,true)
                            end
                          end
							end
						end
						::low::
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
                                     local busted = string.find(self.val.Items[i].ID,t)
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
								if self.val.Restore[1] == self.val.Restore[666] then gg.alert('~ARCEXE: SORRY !\nRestore failed to load. \nif You want to restore Items please Restart the game.') else
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
                                      gg.searchNumber(tostring(#self.val.Items[ind].ID)..';'..ARCEXE.TD(self.val.Items[ind].ID,true), gg.TYPE_DWORD, false, gg.SIGN_EQUAL,nil,nil,1)
                                      local t = {}
                                      t = gg.getResults(1)
                                         t[1].address = t[1].address - OFFSET(8)
                                         gg.getValues(t)
                                         self.val.Items[ind].Pointer = ARCEXE.hex(t[1].address,false)
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
            Name = '🎁x20 Stacks',
            _Name = '1Stack',
            Method = 'ChangeAmount',
            Class = 'LimitedInventoryStack',
            Edit = {[1] = {[1] = '~A mvn r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 mvn W0, #1',[2] = '~A8 RET',}},
              },
        [2] = {
            Name = '⚒️Crafting Cheat',
            _Name = '2Craft',
            Method = 'get_canCraft',
            Class = 'Research',
            Edit = {[1] = {[1] = '~A mov r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, #1',[2] = '~A8 RET',}},
              },
        [3] = {
            Name = '✂️Split Weapons',
            _Name = '3Sp',
            Method = 'CanSplit',
            Class = 'InventorySet',
            Edit = {[1] = {[1] = '~A mov r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, #1',[2] = '~A8 RET',}},
              },
        [4] = {
            Name = '🛡 Free Assemble',
            _Name = '4Assemble',
            Method = 'CanComplete',
            Class = 'BuildingCollection',
            Edit = {[1] = {[1] = '~A mov r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, #1',[2] = '~A8 RET',}},
              },
        [5] = {
            Name = '🌐Unlock Maps',
            _Name = '5Maps',
            Method = 'get_isVisible',
            Class = 'MapPointPresenter',
            Edit = {[1] = {[1] = '~A mov r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, #1',[2] = '~A8 RET',}},
              },
        [6] = {
            Name = '🗂Unlock Blueprints',
            _Name = '6BP',
            Method = 'get_isLocked',
            Class = 'Research',
            Edit = {[1] = {[1] = '~A mov r0, #0',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, WZR',[2] = '~A8 RET',}},
              },
        [7] = {
            Name = '🛡Free Upgrade Tier',
            _Name = '7Assembly_v1',
            Method = 'CanUpgrade',
            Class = 'ConstructionTierModel',
            Edit = {[1] = {[1] = '~A mov r0, #1',[2] = '~A bx lr'},[2]={[1] = '~A8 MOV W0, #1',[2] = '~A8 RET',}},
              },
        [8] = {
            Name = '🔎 Items Hack',
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
	public const string Battlepass12StampTiny = "battlepass12_stamp_tiny";
	public const string Battlepass12StampSmall = "battlepass12_stamp_small";
	public const string Battlepass12StampMiddle = "battlepass12_stamp_middle";
	public const string Battlepass12StampLarge = "battlepass12_stamp_large";
	public const string Battlepass12BannerInfantryman = "battlepass12_banner_infantryman";
	public const string Battlepass12BannerPaladin = "battlepass12_banner_paladin";
	public const string Book = "book";
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
	public const string ResearchChestShared1 = "research_chest_shared_1";
	public const string ProtectiveOintment = "protective_ointment";
	public const string PetFood = "pet_food";
	public const string PetFoodAlchemy = "pet_food_alchemy";
	public const string PetCollar = "pet_collar";
	public const string CatFood = "cat_food";
	public const string TrainingMannequin = "training_mannequin";
	public const string ResearchSanctum1 = "research_sanctum_1";
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
	public const string StrongBowstring = "strong_bowstring";
	public const string Moonflower = "moonflower";
	public const string Cinnabar = "cinnabar";
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
	public const string Tattoo09 = "tattoo_09";
	public const string Tattoo10 = "tattoo_10";
	public const string Tattoo11 = "tattoo_11";
	public const string Tattoo12 = "tattoo_12";
	public const string XmasAmulet = "xmas_amulet";
	public const string Wine = "wine";
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
	public const string ResearchWorkbenchWeapon1 = "research_workbench_weapon_1";
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
		--[9] = {
			--Name = '👑Instant Lvl 200',
			--_Name = '9EXP',
			--Method = 'get_amount',
			--'Class = 'ExperienceResource',
			--Edit = {[1] = {[1] = '~A MOVW R0, #19156',[2] = '~A MOVW R1,  #22418',[3] = '~A MUL R0, R0, R1',[4] = '~A MOVW R1,  #63992',[5] = '~A ADD R1, R0, R1',[6] = '~A VMOV S0, R0',[7] = '~A VCVT.F64.U32 D0, S0',[8] = '~A VMOV R0, R1, D0',[9] = '1EFF2FE1r',},[2] = {[1] = '~A8 MOV W0, #19156',[2] = '~A8 MOV W1,  #22418',[3] = '~A8 MUL W0, W0, W1',[4] = '~A8 MOV W1,  #63992',[5] = '~A8 ADD W0, W0, W1',[6] = '~A8 SCVTF D0, W0',[7] = 'C0035FD6r',
		-- },}
			--  },
		[10] = {
			Name = '🏃Instant Travel',
			_Name = '10Travel',
			Method = 'get_walkSpeed',
			Class = 'MapMovement',
			Edit = {[1] = {[1] = '~A MOVW R0, #666',[2] = '100A00EEr',[3] = 'C00AB8EEr',[4] = '100A10EEr',[5] = '1EFF2FE1r',},[2] = {[1] = '~A8 MOV W0, #666',[2] = '0000271Er',[3] = '00D8215Er',[4] = '0000261Er',[5] = 'C0035FD6r',},},},
		[11] = {
				Name = '🗿Unlimited Durability',
				_Name = '11Dura',
				Method = 'get_Durability',
				Class = 'DurabilityInventoryStack',
				Edit = {[1] = {[1] = '~A MOVW R0, #999',[2] = '~A VMOV S0, R0',[3] = '~A VCVT.F64.U32 D0, S0',[4] = '~A VMOV R0, R1, D0',[5] = '1EFF2FE1r',},[2] = {[1] = '~A8 MOV W0, #999',[2] = '~A8 SCVTF D0, W0',[3] = 'C0035FD6r',},},},
		[12] = {
			Name = '🗡Attack Damage',
			_Name = '12Dmg',
			Method = 'GetWeaponDamageBonus',
			Class = 'WeaponAttackActivity',
			Edit = {[1] = {[1] = '~A MOVW R0, #6666',[2] = '~A bx lr'},[2] = {[2]={[1] = '~A8 MOVW W0, #6666',[2] = '~A8 RET',},},},},},

    ['Engine'] = {
        MENU = {},
        FN = {},
        One = true,
		alr = 1,
        update = function(self) 
            if self.One == true then
				for i = 1,#ARCEXE.Data do 
                self.FN[ARCEXE.Data[i]._Name] = ARCEXE.Worker(ARCEXE.Data[i])
                self.MENU[ARCEXE.Data[i]._Name] = self.FN[ARCEXE.Data[i]._Name].Name..self.FN[ARCEXE.Data[i]._Name].Status
				end
                self.One = false
            end
                for i,v in pairs(self.MENU) do
                    if tempMenu == nil then break; end
                    self.MENU[tempMenu] = self.FN[tempMenu].Name..self.FN[tempMenu].Status
                end
        end,
    },

}
Info = gg.getTargetInfo()
OFFSET = function(offset)
if Info.x64 == true then offset = offset * 0x2 return offset else return offset end
end
FLAG = function()
if Info.x64 == true then  return gg.TYPE_QWORD else return gg.TYPE_DWORD end
end
gg.clearList()
gg.clearResults()
gg.showUiButton()
title = function() if Info.x64 == true then return 'x64 Script (Beta)' else return 'x32 Script' end end
while true do
	ARCEXE.Engine:update()
    if gg.isClickedUiButton() then

		tempMenu = gg.choice(ARCEXE.Engine.MENU,nil,title())
        if tempMenu ~= nil then 
			if tempMenu == '12Dmg' and ARCEXE.Engine.alr == 1 then gg.alert('Please make sure to attack any enemy once.\n Otherwise the script will crash') ARCEXE.Engine.alr = 0
			else
      ARCEXE.Engine.Two = true
			ARCEXE.Engine.FN[tempMenu]:Slave()
			end
        end
    end
end

