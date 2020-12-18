from pdb import DefaultConfig


class Config(DefaultConfig):
    sticky_by_default = True
    pygments_formatter_class = "pygments.formatters.TerminalTrueColorFormatter"
    pygments_formatter_kwargs = {"style": "paraiso-dark"}
