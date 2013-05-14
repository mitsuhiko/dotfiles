def _init():
    import atexit
    import os
    import sys
    import readline
    import types
    import time
    import uuid
    import pprint
    import hashlib
    import datetime
    try:
        import __builtin__
    except ImportError:
        import builtins as __builtin__

    __import__('rlcompleter')
    histdir = os.path.expanduser('~/.pyhist')
    try:
        os.makedirs(histdir)
    except OSError:
        pass

    def _b(x):
        if not isinstance(x, bytes):
            x = x.encode('utf-8')
        return x

    histfile = os.path.join(histdir, hashlib.sha1(
        os.path.normpath(_b(os.path.abspath(sys.prefix)))).hexdigest())

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
    __builtin__.h = helpers


_init()
del _init
