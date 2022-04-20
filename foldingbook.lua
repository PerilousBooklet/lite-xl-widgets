--
-- FoldingBook Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "widget"
local Button = require "widget.button"

---Represents a notebook pane
---@class widget.foldingbook.pane
---@field public name string
---@field public tab widget.button
---@field public container widget
---@field public expanded boolean
local FoldingBookPane = {}

---@class widget.foldingbook : widget
---@field public panes widget.foldingbook.pane[]
local FoldingBook = Widget:extend()

---Notebook constructor
---@param parent widget
function FoldingBook:new(parent)
  FoldingBook.super.new(self, parent)
  self.panes = {}
  self.scrollable = true
end

---@param pane widget.foldingbook.pane
function FoldingBook:on_tab_click(pane)
  pane.expanded = not pane.expanded
end

---Adds a new pane to the foldingbook and returns a container widget where
---you can add more child elements.
---@param name string
---@param label string
---@return widget container
function FoldingBook:add_pane(name, label)
  ---@type widget.button
  local tab = Button(self, label)
  tab.border.width = 0
  tab:toggle_expand(true)
  tab:set_icon("+")

  if #self.panes > 0 then
    if self.panes[#self.panes].expanded then
      tab:set_position(0, self.panes[#self.panes].container:get_bottom() + 2)
    else
      tab:set_position(0, self.panes[#self.panes].tab:get_bottom() + 2)
    end
  else
    tab:set_position(0, 10)
  end

  local container = Widget(self)
  container:set_position(0, tab:get_bottom() + 4)
  container:set_size(self:get_width(), 0)

  local pane = {
    name = name,
    tab = tab,
    container = container,
    expanded = false
  }

  tab.on_click = function()
    self:on_tab_click(pane)
  end

  table.insert(self.panes, pane)

  return container
end

---@param name string
---@return widget.foldingbook.pane
function FoldingBook:get_pane(name)
  for _, pane in pairs(self.panes) do
    if pane.name == name then
      return pane
    end
  end
  return nil
end

---Activates the given pane
---@param name string
---@param visible boolean | nil
function FoldingBook:toggle_pane(name, visible)
  local pane = self:get_pane(name)
  if pane then
    if type(visible) == "boolean" then
      pane.expanded = visible
    else
      pane.expanded = not pane.expanded
    end
  end
end

---Change the tab label of the given pane.
---@param name string
---@param label string
function FoldingBook:set_pane_label(name, label)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_label(label)
    return true
  end
  return false
end

---Set or remove the icon for the given pane.
---@param name string
---@param icon? renderer.color|nil
---@param color? renderer.color|nil
---@param hover_color? renderer.color|nil
function FoldingBook:set_pane_icon(name, icon, color, hover_color)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_icon(icon, color, hover_color)
    return true
  end
  return false
end

---Recalculate the position of the elements on resizing or position
---changes and also make changes to properly render active pane.
function FoldingBook:update()
  if not FoldingBook.super.update(self) then return false end

  ---@type widget.foldingbook.pane
  local prev_pane = nil

  for _, pane in ipairs(self.panes) do
    local tx, ty = 0, 10
    local cx, cy = 0, 0
    local cw, ch = 0, 0

    if prev_pane then
      if prev_pane.expanded then
        ty = prev_pane.container:get_bottom() + 2
      else
        ty = prev_pane.tab:get_bottom() + 2
      end
    end

    pane.tab:set_position(tx, ty)

    cy = pane.tab:get_bottom() + 4
    cw = self:get_width() - (pane.container.border.width * 2)
    if #pane.container.childs > 0 then
      ch = pane.container:get_scrollable_size()
    end

    pane.container.border.color = style.divider

    if pane.expanded then
      pane.container:set_position(cx, cy)
      pane.container:set_size(cw, ch)
      pane.container:show()
      pane.tab:set_icon("-")
    else
      pane.tab:set_icon("+")
      pane.container:hide()
    end

    prev_pane = pane
  end

  return true
end

---Here we draw the bottom line on each tab.
function FoldingBook:draw()
  if not FoldingBook.super.draw(self) then return false end

  for _, pane in ipairs(self.panes) do
    local x = pane.tab.position.x
    local y = pane.tab.position.y + pane.tab:get_height()
    local w = self:get_width() - (pane.container.border.width * 2)
    renderer.draw_rect(x, y, w, 2, style.caret)
  end

  return true
end


return FoldingBook
