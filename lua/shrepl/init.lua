-- [[ lingnik/shrepl.nvim - Custom function to use vim as a shell REPL with enhancements. ]]

local M = {}

-- Default configuration
M.config = {
  reselection_enabled = true,
  capture_stderr_seprately = true,
}

function M.setup(user_config)
  -- Merge user_config with default config
  M.config = vim.tbl_extend("force", M.config, user_config or {})

  -- Map <leader>x for normal mode
  vim.keymap.set("n", "<leader>x", function()
    M.execute_command("normal")
  end, { desc = "E[x]ecute Current Line in Shell" })

  -- Map <leader>x for visual mode
  vim.keymap.set("x", "<leader>x", function()
    -- Exit visual mode
    vim.cmd("normal! \027") -- Equivalent to pressing <Esc>
    M.execute_command("visual")
  end, { desc = "E[x]ecute Selected Lines in Shell" })
end

function M.execute_command(mode)
  -- Read configurable options
  local reselection_enabled = M.config.reselection_enabled
  local capture_stderr_separately = M.config.capture_stderr_separately

  -- Initialize variables locally
  local start_line, end_line
  local command_lines = {}

  if mode == "visual" then
    -- Get visual selection range before exiting visual mode
    local pos_start = vim.fn.getpos("'<")
    local pos_end = vim.fn.getpos("'>")
    start_line = math.min(pos_start[2], pos_end[2])
    end_line = math.max(pos_start[2], pos_end[2])

    -- Get the selected lines
    command_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  else
    -- Normal mode: use the current line
    start_line = vim.fn.line(".")
    end_line = start_line

    -- Get the current line
    command_lines = { vim.api.nvim_get_current_line() }
  end

  -- Combine command lines
  local command = table.concat(command_lines, "\n")
  if command == "" then
    vim.api.nvim_err_writeln("No command to execute.")
    return
  end

  -- Generate timestamps and block markers
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local formatted_command = command:gsub("\n", " \\ ")
  local block_header = string.format("# %s `%s`", timestamp, formatted_command)
  local block_start = "``` sh"
  local block_end = "```"

  -- Record start time
  local start_time = vim.loop.hrtime()

  -- Execute the command as a script
  local temp_file = os.tmpname()
  local file = io.open(temp_file, "w")
  if not file then
    vim.api.nvim_err_writeln("Failed to create temporary file.")
    return
  end
  file:write(command)
  file:close()

  -- Prepare for capturing output
  local stdout_data = {}
  local stderr_data = {}
  local exit_code = nil

  local job_opts = {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        stdout_data = data
      end
    end,
    on_exit = function(_, code)
      exit_code = code
    end,
  }

  if capture_stderr_separately then
    job_opts.stderr_buffered = true
    job_opts.on_stderr = function(_, data)
      if data then
        stderr_data = data
      end
    end
  else
    -- Merge stderr into stdout
    job_opts.stderr = "stdout"
  end

  -- Start the job
  local job_id = vim.fn.jobstart({ "bash", temp_file }, job_opts)

  -- Wait for the job to finish
  vim.fn.jobwait({ job_id }, -1)

  -- Remove the temporary file
  os.remove(temp_file)

  -- Record end time and calculate elapsed time
  local end_time = vim.loop.hrtime()
  local elapsed = (end_time - start_time) / 1e9 -- Convert nanoseconds to seconds

  if not exit_code then
    exit_code = "unknown"
  end

  local metadata = string.format("Exit Code: %s | Time: %.3f sec | Timestamp: %s", exit_code, elapsed, timestamp)

  -- Construct the output block
  local block = {}
  table.insert(block, block_header)

  if capture_stderr_separately then
    if #stdout_data > 0 then
      table.insert(block, "``` stdout")
      vim.list_extend(block, stdout_data)
      table.insert(block, "```")
    end
    if #stderr_data > 0 then
      table.insert(block, "``` stderr")
      vim.list_extend(block, stderr_data)
      table.insert(block, "```")
    end
  else
    if #stdout_data > 0 then
      table.insert(block, block_start)
      vim.list_extend(block, stdout_data)
      table.insert(block, block_end)
    end
  end

  table.insert(block, metadata)
  table.insert(block, "") -- Add a blank line between metadata and input command

  local bufnr = vim.api.nvim_get_current_buf()

  -- Ensure the buffer will not become empty
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local keep_line = false
  if total_lines == end_line and total_lines == 1 then
    -- Buffer has only one line, append a dummy line to prevent empty buffer
    -- Note: This is to minimize treesitter errors when the command executed is the only line in the buffer, and the
    -- buffer is being interpreted as a markdown file, e.g. a file with a .md extension. The error occurs when the
    -- execution of this plugin's function is undone, e.g. with `u`.
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "" })
    keep_line = true
  end

  -- Delete the command lines from their original location
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, {})

  -- Insert the output block at the original command position
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, start_line - 1, false, block)

  -- Insert the command lines after the output block
  local new_command_start = start_line - 1 + #block
  vim.api.nvim_buf_set_lines(bufnr, new_command_start, new_command_start, false, command_lines)

  -- Move cursor to the start of the command lines
  vim.api.nvim_win_set_cursor(0, { new_command_start + 1, 0 })

  -- Reselect the command lines in visual mode if enabled
  if reselection_enabled and mode == "visual" then
    -- Enter visual line mode
    vim.cmd("normal! V")
    -- Move cursor to the end of the command lines
    local num_lines = #command_lines
    if num_lines > 1 then
      vim.cmd("normal! " .. (num_lines - 1) .. "j")
    end
  end

  -- Remove the dummy line if it was added
  if keep_line then
    local new_total_lines = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, new_total_lines - 1, new_total_lines, false, {})
  end
end

return M
