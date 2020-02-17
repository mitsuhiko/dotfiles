def _init():
    import atexit
    import os
    import sys
    try:
        import readline
    except Exception:
        readline = None
    import types
    import time
    import uuid
    import pprint
    import hashlib
    import subprocess
    import datetime
    try:
        import __builtin__
    except ImportError:
        import builtins as __builtin__

    PY2 = sys.version_info[0] == 2
    __import__('rlcompleter')
    histdir = os.path.expanduser('~/.pyhist')
    try:
        os.makedirs(histdir)
    except OSError:
        pass

    if PY2:
        text_type = unicode
    else:
        text_type = str

    def _b(x):
        if not isinstance(x, bytes):
            x = x.encode('utf-8')
        return x

    histfile = os.path.join(histdir, hashlib.sha1(
        os.path.normpath(_b(os.path.abspath(sys.prefix)))).hexdigest())

    if readline is not None:
        try:
            readline.read_history_file(histfile)
        except IOError:
            pass

        if 'libedit' in readline.__doc__:
            readline.parse_and_bind("bind '\t' rl_complete")
        else:
            readline.parse_and_bind("tab: complete")

        atexit.register(readline.write_history_file, histfile)


    def _magic_uuid(val=None):
        if val is None:
            return uuid.uuid4()
        elif isinstance(val, uuid.UUID):
            return val
        elif len(val) == 16:
            return uuid.UUID(bytes=val)
        return uuid.UUID(val)


    def _dump_json(x, as_string=False, indent=2, cp=False):
        import json
        s = '\n'.join(x.rstrip() for x in json.dumps(x, indent=indent).rstrip().splitlines())
        if cp:
            _copy(s)
        if as_string:
            return s
        print(s)

    def _cat(path):
        with open(path, 'rb') as f:
            return f.read()

    def _tcat(path):
        return _cat(path).decode('utf-8')

    def _paste():
        return subprocess.Popen(['pbpaste'], stdout=subprocess.PIPE).communicate()[0]

    def _tpaste():
        return _paste().decode('utf-8')

    def _copy(val):
        if isinstance(val, text_type):
            val = val.encode('utf-8')
        return subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE).communicate(val)


    helpers = types.ModuleType('helpers')
    helpers.histfile = histfile
    helpers.pp = pprint.pprint
    helpers.uuid = _magic_uuid
    helpers.UUID = uuid.UUID
    helpers.uuid3 = uuid.uuid3
    helpers.uuid4 = uuid.uuid4
    helpers.uuid5 = uuid.uuid5
    helpers.dt = datetime.datetime
    helpers.datetime = datetime.datetime
    helpers.td = datetime.timedelta
    helpers.timedelta = datetime.timedelta
    helpers.time = time.time
    helpers.j = _dump_json
    helpers.cat = _cat
    helpers.tcat = _tcat
    helpers.cp = _copy
    helpers.copy = _copy
    helpers.paste = _paste
    helpers.tpaste = _tpaste
    __builtin__.h = helpers
    __builtin__.true = True
    __builtin__.false = False
    __builtin__.null = None


_init()
del _init
