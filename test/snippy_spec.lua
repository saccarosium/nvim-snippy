local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local clear, command, eval = helpers.clear, helpers.command, helpers.eval
local feed, alter_slashes, meths = helpers.feed, helpers.alter_slashes, helpers.meths
local insert = helpers.insert
local eq, neq, ok = helpers.eq, helpers.neq, helpers.ok
local sleep = helpers.sleep

describe("Snippy tests", function ()
    local screen

    before_each(function()
        clear()
        screen = Screen.new(81, 15)
        screen:attach()

        command('set rtp+=' .. alter_slashes('../snippy/'))
        command('source ' .. alter_slashes('../snippy/plugin/snippy.vim'))
    end)

    after_each(function ()
        screen:detach()
    end)

    it("Read scopes", function ()
        command("set filetype=lua")
        eq({_ = {}, lua = {}}, meths.execute_lua([[return snippy.snips]], {}))
    end)

    it("Read snippets", function ()
        command("lua snippy.setup({snippet_dirs = '../snippy/test/'})")
        command("set filetype=")
        local snips = {
            test1 = {prefix = 'test1', body = {'This is the first test.'}},
            test2 = {prefix = 'test2', body = {'This is the second test.'}},
        }
        neq(nil, meths.execute_lua([[return require 'snippy.shared'.config.snippet_dirs]], {}))
        neq({}, meths.execute_lua([[return require 'snippy.reader'.list_available_scopes()]], {}))
        eq({_ = snips}, meths.execute_lua([[return snippy.snips]], {}))
    end)

    -- it("Read vim-snippets snippets", function ()
    --     local snippet_dirs = '../vim-snippets/'
    --     command(string.format([[
    --         lua snippy.setup({
    --             snippet_dirs = '%s',
    --             get_scopes = function () return {vim.bo.ft} end,
    --         })
    --     ]], snippet_dirs))
    --     local scopes = eval([[luaeval('require "snippy.reader".list_available_scopes()')]])
    --     neq({}, scopes)
    --     for _, scope in ipairs(scopes) do
    --         command("set filetype=" ..  scope)
    --         local snips = meths.execute_lua([[return snippy.snips]], {})
    --         neq(nil, snips[scope])
    --     end
    -- end)

    it("Insert basic snippet", function ()
        command("lua snippy.setup({snippet_dirs = '../snippy/test/'})")
        command("set filetype=")
        insert("test1")
        feed("a")
        feed("<plug>(snippy-expand)")
        -- screen:snapshot_util()
        screen:expect{grid=[[
        This is the first test.^                                                          |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue1, bold = true};
            [2] = {bold = true};
        }}
    end)

    it("Insert snippet and jump", function ()
        command("lua snippy.setup({snippet_dirs = '../snippy/test/'})")
        command("set filetype=lua")
        insert("for")
        feed("a")
        eq(true, meths.execute_lua([[return snippy.can_expand()]], {}))
        feed("<plug>(snippy-expand)")
        screen:expect{grid=[[
        for ^ in  then                                                                    |
                                                                                         |
        end                                                                              |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue1, bold = true};
            [2] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")
        screen:expect{grid=[[
        for  in ^ then                                                                    |
                                                                                         |
        end                                                                              |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue1, bold = true};
            [2] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")
        neq(true, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Expand and select placeholder", function ()
        command("lua snippy.setup({snippet_dirs = '../snippy/test/'})")
        command("set filetype=lua")
        insert("loc")
        feed("a")
        eq(true, meths.execute_lua([[return snippy.can_expand()]], {}))
        feed("<plug>(snippy-expand)")
        screen:expect{grid=[[
        local ^v{1:ar} =                                                                      |
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {3:-- SELECT --}                                                                     |
        ]], attr_ids={
            [1] = {background = Screen.colors.LightGrey};
            [2] = {foreground = Screen.colors.Blue, bold = true};
            [3] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.can_jump(1)]], {}))
        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        feed("<plug>(snippy-next-stop)")
        screen:expect{grid=[[
        local var = ^                                                                     |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue, bold = true};
            [2] = {bold = true};
        }}
        neq(true, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Expand anonymous snippet", function ()
        command("set filetype=")
        feed("i")
        command("lua snippy.expand_snippet([[local $1 = $0]])")
        screen:expect{grid=[[
        local ^ =                                                                         |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Jump back", function ()
        command("set filetype=")
        feed("i")
        command("lua snippy.expand_snippet([[$1, $2, $0]])")
        eq(true, meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")
        screen:expect{grid=[[
        , ^,                                                                              |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue, bold = true};
            [2] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.can_jump(-1)]], {}))
        feed("<plug>(snippy-previous-stop)")
        screen:expect{grid=[[
        ^, ,                                                                              |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {foreground = Screen.colors.Blue, bold = true};
            [2] = {bold = true};
        }}
    end)

    it("Apply transform", function ()
        command("set filetype=")
        feed("i")
        command("lua snippy.expand_snippet([[local ${1:var} = ${1/foo/bar/g}]])")
        screen:expect{grid=[[
        local ^v{1:ar} = var                                                                  |
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {3:-- SELECT --}                                                                     |
        ]], attr_ids={
            [1] = {background = Screen.colors.LightGrey};
            [2] = {bold = true, foreground = Screen.colors.Blue};
            [3] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        feed('foofoofoo')
        screen:expect{grid=[[
        local foofoofoo^ = barbarbar                                                      |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}
        -- neq({current_stop = 0, stops = {}},
        --     meths.execute_lua([[return require 'snippy.buf'.state()]], {}))
        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Clear state on move", function ()
        command("set filetype=")
        feed("i")
        command("lua snippy.expand_snippet([[local $1 = $0]])")
        screen:expect{grid=[[
        local ^ =                                                                         |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}
        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        feed('<left>')
        screen:expect{grid=[[
        local^  =                                                                         |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}
        sleep(400)
        neq(true, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Jump from select to insert", function ()
        -- command [[lua snippy.setup({ hl_group = 'Search' })]]
        local snip = 'for (\\$${1:foo} = 0; \\$$1 < $2; \\$$1++) {\n\t$0\n}'
        feed("i")
        command("lua snippy.expand_snippet([[" .. snip .. "]])")
        -- feed("bar")

        screen:expect{grid=[[
        for ($^f{1:oo} = 0; $ < ; $++) {                                                      |
                                                                                         |
        }                                                                                |
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {2:~                                                                                }|
        {3:-- SELECT --}                                                                     |
        ]], attr_ids={
            [1] = {background = Screen.colors.LightGrey};
            [2] = {bold = true, foreground = Screen.colors.Blue1};
            [3] = {bold = true};
        }}

        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        ok(meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")

        -- screen:snapshot_util()
        screen:expect{grid=[[
        for ($foo = 0; $foo < ^; $foo++) {                                                |
                                                                                         |
        }                                                                                |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}

        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        ok(meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")

        -- screen:snapshot_util()
        screen:expect{grid=[[
        for ($foo = 0; $foo < ; $foo++) {                                                |
                ^                                                                         |
        }                                                                                |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}

        eq(false, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

    it("Jump and mirror correctly", function ()
        -- command [[lua snippy.setup({ hl_group = 'Search' })]]
        local snip = '${1:var} = $0; // set $1'
        feed("i")
        command("lua snippy.expand_snippet([[" .. snip .. "]])")
        feed("$foo")

        -- screen:snapshot_util()
        screen:expect{grid=[[
        $foo^ = ; // set $foo                                                             |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}

        eq(true, meths.execute_lua([[return snippy.is_active()]], {}))
        ok(meths.execute_lua([[return snippy.can_jump(1)]], {}))
        feed("<plug>(snippy-next-stop)")

        -- screen:snapshot_util()
        screen:expect{grid=[[
        $foo = ^; // set $foo                                                             |
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {1:~                                                                                }|
        {2:-- INSERT --}                                                                     |
        ]], attr_ids={
            [1] = {bold = true, foreground = Screen.colors.Blue};
            [2] = {bold = true};
        }}

        eq(false, meths.execute_lua([[return snippy.is_active()]], {}))
    end)

end)
