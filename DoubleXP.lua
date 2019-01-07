-- doubleXP
-- Author: Vexira on WoW-Mania Redemption
-- License: GNU GPL v3, 28 December 2018 (see LICENSE.txt)
--
-- Inspired by several addons code and http://wowwiki.wikia.com
--
-- hour, minute = GetGameTime()
-- dateValue = date()
-- weekday, month, day, year = CalendarGetDate()


SLASH_DXP1 = "/dxp";
SLASH_DXP2 = "/doublexp";

local DXP_TITLE = "DoubleXP";
local DXP_VERSION = "version " .. GetAddOnMetadata(..., "Version"):match("^([%d.]+)") .. " (" .. GetAddOnMetadata(..., "X-Date") ..")";

local DXP_Date = date("*t");
local DXP_ON = false;
local DXP_PS = false;			-- previous state
local DXP_PlayerHide = false;		-- player did hide the frame
local DXP_PlayerShow = false;		-- player did show the frame
local DXP_LastTimePublishInWorld = 0;	-- don't spam world chat

local DXP_TooltipScale;			-- size of tooltips before we change it

local DXP_Msg = "";
local DXP_Help_Text = "|cff00afc6<Ctrl Left Click>|r to hide frame\n|cff00afc6<Alt Left Click>|r to whisper info to target player (if any)\n|cff00afc6<Shift Left Click>|r to publish info in world chat (once per minute max)";

-- The OnEvent function handles the SavedVariables states
-- Second event doesn't seem to work though (hence the empty
-- case).
function DoubleXP_OnEvent(self, event, arg1)
	if ( event == "ADDON_LOADED" and arg1 == "DoubleXP" ) then
		if ( DXP_Visible == nil or DXP_Visible == true ) then
			-- If we are here for the first time or if
			-- the player wanted the frame shown last time,
			-- then show the frame.
			DXP_Visible = true;
		end
	elseif ( event == "PLAYER_LOGOUT" ) then
	end
end


-- Magic to convert slash command names to functions.
SlashCmdList["DXP"] = function(msg, editbox)
	local _, _, cmd = string.find(msg, "%s?(%w+)%s?.*")
   
	if ( cmd == "show" ) then
		DoubleXPFrame:Show()
		DXP_PlayerShow = true;
		DXP_Visible = true;
	elseif ( cmd == "hide" ) then
		DoubleXPFrame:Hide()
		DXP_PlayerHide = true;
		DXP_Visible = false;
	elseif (cmd == nil ) then
		ChatLog(DXP_Msg);
	else
		ChatLog("");
		ChatLog(DXP_TITLE .. " " .. DXP_VERSION);
		ChatLog(" /doublexp [show|hide]: show/hide frame");
		ChatLog(" /doublexp: report remaining time in chat frame");
		ChatLog("");
		ChatLog(DXP_Help_Text);
	end
end


-- This function is run once when the character logs in
-- (or when '/reload ui' is used).
function DoubleXP_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_LOGOUT");

	DXP_Date = date("*t");
	ChatLog(DXP_TITLE .. " " .. DXP_VERSION);
	ChatLog(DXP_Msg);

	DoubleXPFrame.title = DoubleXPFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");

	DoubleXPFrame.title:SetPoint("TOP", 0, -5);
	DoubleXPFrame.title:SetText("Double XP Weekend");

	DoubleXPFrame.text = DoubleXPFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	DoubleXPFrame.text:SetPoint("BOTTOM", 0, 5);
end


-- This function is run everytime the update event is fired
-- (this means very often).
-- It is responsible for updating the current date variable, the
-- content of the frame and the default message.
function DoubleXP_OnUpdate(self)
	local theText = "";
	local dt, pp;

	DXP_Date = date("*t");

	if ( DXP_Date.wday == 7 or DXP_Date.wday == 1 ) then
		DXP_ON = true;
	else
		DXP_ON = false;
	end

	dt, pp = DoubleXP_TimeLeft();

	theText = "is " .. DoubleXP_Report();
	theText = theText .. "\n\n" .. pp .. " to go"

	DXP_Msg = "Double XP Weekend is " .. DoubleXP_Report() .. " (" .. pp;
	if ( DXP_ON ) then
		DXP_Msg = DXP_Msg .. " left)";
	else
		DXP_Msg = DXP_Msg .. " until next)";
	end

	DoubleXPFrame.text:SetText(theText);

	-- show frame one day before WE unless player want it hidden
	if ( DXP_Date.wday >= 6 ) then
		-- only if player hasn't closed it already
		if ( not DXP_PlayerHide or DXP_Visible ) then
			DoubleXPFrame:Show();
			DXP_PlayerShow = false;
			DXP_Visible = true;
		end
	end
	-- hide frame when Double XP WE is over
	-- but only if player doesn't want it to be shown
	if ( ((DXP_Date.wday == 2 and DXP_Date.hour > 12) or DXP_Date.wday > 2) and DXP_Date.wday < 7 ) then
		if ( not DXP_PlayerShow and not DXP_Visible ) then
			DoubleXPFrame:Hide();
			DXP_PlayerHide = true;
			DXP_Visible = false;
		end
	end
end


-- What happens when the mouse cursor enters the frame?
-- We show the tooltip!
function DoubleXP_OnEnter(obj)
	obj.tooltipText = DXP_Help_Text;

	GameTooltip:SetOwner(obj,"ANCHOR_RIGHT");
	GameTooltip:SetText(obj.tooltipText, nil, nil, nil, nil, false);
	DXP_TooltipScale = GameTooltip:GetScale();
	GameTooltip:SetScale(0.8);
	GameTooltip:Show();
end


-- When mouse cursor leaves the frame, we hide the tooltip.
function DoubleXP_OnLeave(obj)
	GameTooltip:SetScale(DXP_TooltipScale);
	GameTooltip:Hide();
end


-- This function changes frame backgound color and return the right
-- message.
function DoubleXP_Report()
	if ( DXP_ON ) then
		DoubleXPFrame:SetBackdropColor(0.25,0.5,0,1);
		return "|cffffffffON!|r";
	else
		DoubleXPFrame:SetBackdropColor(0,0,0,1);
		return "off";
	end
end


function ChatLog(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end


-- This function does the real job, computing time left to the next event.
function DoubleXP_TimeLeft()
	local date_limit;
	local time_limit;
	local delta_t;
	local d,hd,h,m,s;
	local pretty;

	date_limit = deepcopy(DXP_Date);	-- now
	date_limit.hour = 23;			-- end ...
	date_limit.min = 59;			-- ... of current ...
	date_limit.sec = 59;			-- ... day

	if ( DXP_ON ) then
		if ( date_limit.wday == 1 ) then
			time_limit = time(date_limit);
		else
			time_limit = time(date_limit) + 3600*24;
		end
	else
		time_limit = time(date_limit) + (6-DXP_Date.wday)*3600*24;
	end
	time_limit = time_limit + 1; -- one more second to switch to the next day

	delta_t = time_limit - time(DXP_Date);

	d = floor(delta_t/3600/24);
	if ( d >= 2 ) then
		h = floor((delta_t-d*3600*24)/3600);
		m = floor((delta_t-d*3600*24-h*3600)/60);
		s = delta_t-d*3600*24-h*3600-m*60;
	else
		h = floor(delta_t/3600);
		m = floor((delta_t-h*3600)/60);
		s = delta_t-h*3600-m*60;
	end

	pretty = "";
	if ( h < 10 ) then
		pretty = pretty .. "0";
	end
	pretty = pretty .. h .. "h ";
	
	if ( m < 10 ) then
		pretty = pretty .. "0";
	end
	pretty = pretty .. m .. "m ";
	
	if ( d >= 2 ) then
		pretty = d .. "d " .. pretty ;
	else
		-- if you don't want to see seconds in the countdown,
		-- comment out the four following lines
		if ( s < 10 ) then
			pretty = pretty .. "0";
		end
		pretty = pretty .. s .. "s";
		--
	end

	return delta_t,pretty
end


-- Function to handle mouse clicks
--  . SHIFT + click: publish remaining time in world chat
--  . ALT   + click: whisper remaining time to selected player if any
--  . CTRL  + click: hide frame
function DoubleXP_OnClick(f)

	if ( IsShiftKeyDown() ) then
		local index = GetChannelName("World");
		local now = time();


		if ( index ~= nil and now >= DXP_LastTimePublishInWorld + 60 ) then
			DXP_LastTimePublishInWorld = time();
			SendChatMessage(DXP_Msg, "CHANNEL", nil, index);
			-- ChatLog(DXP_Msg);
		end
	elseif ( IsAltKeyDown() ) then
		local unit = GetUnitName("PLAYERTARGET");

		if ( unit ~= nil ) then
			SendChatMessage(DXP_Msg, "WHISPER", nil, unit);
		end
	elseif ( IsControlKeyDown() ) then
		DoubleXPFrame:Hide()
		DXP_PlayerHide = true;
		DXP_Visible = false;
	end
end


-- Deep copy function thanks to LUA documentation website
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
