function GetCharCount()
    local text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local full_text = table.concat(text, "\n")
    -- Unicodeの文字数としてカウントする
    local count = vim.fn.strdisplaywidth(full_text) -- これだと2になるため代替案

    -- UTF-8文字列の文字数を正確に数えるためのLua標準手法
    local _, count = string.gsub(full_text, "[^\128-\193]", "")
    print("文字数: " .. count)
end

-- コマンド登録
vim.api.nvim_create_user_command('CountChars', GetCharCount, {})
