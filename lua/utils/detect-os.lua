-- local uv = vim.uv or vim.loop
--
-- local function is_wsl()
--   local uname = uv.os_uname()
--   -- WSL presents as Linux
--   if uname.sysname ~= "Linux" then
--     return false
--   end
--   -- Env signals (WSL1/2)
--   if vim.env.WSL_DISTRO_NAME or vim.env.WSLENV then
--     return true
--   end
--   -- Kernel release often contains "Microsoft" or "microsoft-standard-WSL"
--   local rel = (uname.release or ""):lower()
--   return rel:find("microsoft") ~= nil or rel:find("wsl") ~= nil
-- end
--
-- local IS_WSL = is_wsl()
-- local IS_WINDOWS = uv.os_uname().sysname == "Windows_NT"
-- local IS_MAC = uv.os_uname().sysname == "Darwin"
--
--
--
-- -- lua/utils/detect.lua
local uv = vim.uv or vim.loop

local M = {}

--- Returns true if Neovim is running in WSL (Windows Subsystem for Linux).
function M.is_wsl()
  local uname = uv.os_uname()
  if uname.sysname ~= "Linux" then
    return false
  end

  -- Env signals present in WSL
  if vim.env.WSL_DISTRO_NAME or vim.env.WSLENV then
    return true
  end

  -- Kernel release often contains "Microsoft" or "wsl"
  local rel = (uname.release or ""):lower()
  return rel:find("microsoft") ~= nil or rel:find("wsl") ~= nil
end

--- Returns true if running on native Windows (not WSL).
function M.is_windows()
  -- In WSL, sysname is Linux; Windows_NT indicates native Windows
  return uv.os_uname().sysname == "Windows_NT"
end

--- Returns true if running on macOS.
function M.is_macos()
  return uv.os_uname().sysname == "Darwin"
end

--- Returns true if running on Linux (including WSL).
function M.is_linux()
  return uv.os_uname().sysname == "Linux"
end

-- Cached convenience flags (computed once)
M.IS_WSL     = M.is_wsl()
M.IS_WINDOWS = M.is_windows()
M.IS_MAC     = M.is_macos()
M.IS_LINUX   = M.is_linux()

return M
