# Supported 16 color values:
#   'h0' (color number 0) through 'h15' (color number 15)
#    or
#   'default' (use the terminal's default foreground),
#   'black', 'dark red', 'dark green', 'brown', 'dark blue',
#   'dark magenta', 'dark cyan', 'light gray', 'dark gray',
#   'light red', 'light green', 'yellow', 'light blue',
#   'light magenta', 'light cyan', 'white'
#
# Supported 256 color values:
#   'h0' (color number 0) through 'h255' (color number 255)
#
# 256 color chart: http://en.wikipedia.org/wiki/File:Xterm_color_chart.png
#
# "setting_name": (foreground_color, background_color),

# See pudb/theme.py
# (https://github.com/inducer/pudb/blob/master/pudb/theme.py) to see what keys
# there are.

# Note, be sure to test your theme in both curses and raw mode (see the bottom
# of the preferences window). Curses mode will be used with screen or tmux.

# {{{ monokai-256
palette.update({
    "header": ("h252", "h241", "standout"),

    # {{{ variables view
    "variables": ("yellow", "h233"),
    "variable separator": ("h23", "h252"),

    "var label": ("h111", "h233"),
    "var value": ("h255", "h233"),
    "focused var label": ("h237", "h172"),
    "focused var value": ("h237", "h172"),

    "highlighted var label": ("h252", "h22"),
    "highlighted var value": ("h255", "h22"),
    "focused highlighted var label": ("h252", "h64"),
    "focused highlighted var value": ("h255", "h64"),

    "return label": ("h113", "h233"),
    "return value": ("h113", "h233"),
    "focused return label": (add_setting("h192", "bold"), "h24"),
    "focused return value": ("h237", "h172"),
    # }}}

    # {{{ stack view
    "stack": ("h235", "h233"),

    "frame name": ("h192", "h233"),
    "focused frame name": ("h237", "h172"),
    "frame class": ("h111", "h233"),
    "focused frame class": ("h237", "h172"),
    "frame location": ("h252", "h233"),
    "focused frame location": ("h237", "h172"),

    "current frame name": ("h255", "h22"),
    "focused current frame name": ("h255", "h64"),
    "current frame class": ("h111", "h22"),
    "focused current frame class": ("h255", "h64"),
    "current frame location": ("h252", "h22"),
    "focused current frame location": ("h255", "h64"),
    # }}}

    # {{{ breakpoint view
    "breakpoint": ("h80", "h233"),
    "disabled breakpoint": ("h60", "h233"),
    "focused breakpoint": ("h237", "h172"),
    "focused disabled breakpoint": ("h182", "h24"),
    "current breakpoint": (add_setting("h255", "bold"), "h22"),
    "disabled current breakpoint": (add_setting("h016", "bold"), "h22"),
    "focused current breakpoint": (add_setting("h255", "bold"), "h64"),
    "focused disabled current breakpoint": (
	add_setting("h016", "bold"), "h64"),
    # }}}

    # {{{ ui widgets

    "selectable": ("h252", "h235"),
    "focused selectable": ("h255", "h24"),

    "button": ("h252", "h235"),
    "focused button": ("h255", "h24"),

    "background": ("h252", "h241"),
    "hotkey": (add_setting("h252", "underline"), "h241", "underline"),
    "focused sidebar": ("h23", "h241", "standout"),

    "warning": (add_setting("h255", "bold"), "h124", "standout"),

    "label": ("h235", "h252"),
    "value": ("h255", "h17"),
    "fixed value": ("h252", "h17"),
    "group head": (add_setting("h25", "bold"), "h252"),

    "search box": ("h255", "h235"),
    "search not found": ("h255", "h124"),

    "dialog title": (add_setting("h255", "bold"), "h235"),

    # }}}

    # {{{ source view
    "breakpoint marker": ("h160", "h235"),

    "breakpoint source": ("h252", "h124"),
    "breakpoint focused source": ("h192", "h124"),
    "current breakpoint source": ("h192", "h124"),
    "current breakpoint focused source": (
	    add_setting("h192", "bold"), "h124"),
    # }}}

    # {{{ highlighting
    "source": ("h255", "h235"),
    "focused source": ("h237", "h172"),
    "highlighted source": ("h252", "h22"),
    "current source": (add_setting("h252", "bold"), "h23"),
    "current focused source": (add_setting("h192", "bold"), "h23"),
    "current highlighted source": ("h255", "h22"),

    "line number": ("h241", "h235"),
    "keyword2": ("h51", "h235"),
    "name": ("h155", "h235"),
    "literal": ("h141", "h235"),

    "namespace": ("h198", "h235"),
    "operator": ("h198", "h235"),
    "argument": ("h208", "h235"),
    "builtin": ("h51", "h235"),
    "pseudo": ("h141", "h235"),
    "dunder": ("h51", "h235"),
    "exception": ("h51", "h235"),
    "keyword": ("h198", "h235"),

    "string": ("h228", "h235"),
    "doublestring": ("h228", "h235"),
    "singlestring": ("h228", "h235"),
    "docstring": ("h243", "h235"),

    "punctuation": ("h255", "h235"),
    "comment": ("h243", "h235"),

    # }}}

    # {{{ shell
    "command line edit": ("h255", "h233"),
    "command line prompt": (add_setting("h192", "bold"), "h233"),

    "command line output": ("h80", "h233"),
    "command line input": ("h255", "h233"),
    "command line error": ("h160", "h233"),

    "focused command line output": (add_setting("h192", "bold"), "h24"),
    "focused command line input": ("h255", "h24"),
    "focused command line error": ("h235", "h24"),

    "command line clear button": (add_setting("h255", "bold"), "h233"),
    "command line focused button": ("h255", "h24"),
    # }}}
})
# }}}

