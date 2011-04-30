# Ps

## About

Ps is a Rack application for introspecting process list on the machine it is
running on. It doesn't implement any authentication/authorization mechanisms and this
should be handled by the user itself (ie. by configuring webserver or
firewall).

Ps is implemented in Sinatra as JSON API.

## Instalation

Ps uses _bundler_ for dependency management. To install all needed gems run
following in app directory:

    bundle install

It provides _config.ru_ boot file for Rack enabled webservers, the only thing
left is to start the server.

## Request & response formats

All calls made to the Ps API should use HTTP GET verb and proper path (see
below).

All responses from API return HTTP 200 status code and JSON encoded data
(unless otherwise stated).

## API calls

API consists of 2 calls:

* listing all processes
* getting detailed information for specified process (by PID)

### Getting list of running processes

To return all processes running on the machine make following request:

    GET /

For example:

    $ curl -s localhost:4000/ | python -mjson.tool
    [
      {
          "cmdline": "zsh",
          "comm": "zsh",
          "pid": 15125,
          "rss": 919,
          "rss_bytes": 3764224,
          "state": "S",
          "vsize": 8523776
      },
      {
          "cmdline": "zsh",
          "comm": "zsh",
          "pid": 15568,
          "rss": 927,
          "rss_bytes": 3796992,
          "state": "S",
          "vsize": 8519680
      }
      ...
    ]

Fields returned for each process: *cmdline, comm, pid, rss, rss_bytes, state,
vsize*. For explanation of their meaning refer to _/proc_ filesystem manual (`man proc`).

Additional *rss\_bytes* field is process' physical memory usage (resident set
size) in bytes as opposed to _rss_ which is the number of process' memory pages
currently in physical memory.

Processes can be filtered by command name by using _filter_ query parameter:

    GET /?filter=zsh

They can be also ordered by specific field by using _order_ query parameter:

    GET /?order=rss

Options can be combined:

    GET /?filter=ruby&order=vsize

### Getting detailed information for specific process

To get detailed information for specific process make following request:

    GET /PID

where PID is the PID of the process you're requesting information for.

For example:

    $ curl -s localhost:4000/15125 | python -mjson.tool
    {
        "blocked": 0,
        "cmajflt": 46,
        "cmdline": "zsh",
        "cminflt": 166838,
        "cnswap": 0,
        "comm": "zsh",
        "cstime": 356,
        "cutime": 1526,
        "cwd": "/home/kill/code/ps",
        "egid": 1000,
        "endcode": 135037840,
        "environ": {
            "COLORTERM": "gnome-terminal",
            "DBUS_SESSION_BUS_ADDRESS": "unix:abstract",
            "DEFAULTS_PATH": "/usr/share/gconf/gnome.default.path",
            "DESKTOP_SESSION": "gnome",
            "DISPLAY": ":0.0",
            "GDMSESSION": "gnome",
            "GDM_KEYBOARD_LAYOUT": "pl",
            "GDM_LANG": "en_US.utf8",
            "GNOME_DESKTOP_SESSION_ID": "this-is-deprecated",
            "GNOME_KEYRING_CONTROL": "/tmp/keyring-CLLMli",
            "GNOME_KEYRING_PID": "1631",
            "GTK_MODULES": "canberra-gtk-module",
            "HOME": "/home/kill",
            "LANG": "en_US.utf8",
            "LC_CTYPE": "pl_PL.utf8",
            "LC_TIME": "en_GB.utf8",
            "LOGNAME": "kill",
            "MANDATORY_PATH": "/usr/share/gconf/gnome.mandatory.path",
            "ORBIT_SOCKETDIR": "/tmp/orbit-kill",
            "PATH": "/home/kill/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
            "PWD": "/home/kill",
            "SESSION_MANAGER": "local/lenny:@/tmp/.ICE-unix/1650,unix/lenny:/tmp/.ICE-unix/1650",
            "SHELL": "/usr/bin/zsh",
            "SSH_AGENT_PID": "1685",
            "SSH_AUTH_SOCK": "/tmp/keyring-CLLMli/ssh",
            "TERM": "xterm",
            "USER": "kill",
            "USERNAME": "kill",
            "WINDOWID": "75497509",
            "WINDOWPATH": "7",
            "XAUTHORITY": "/var/run/gdm/auth-for-kill-sDCBqS/database",
            "XDG_CONFIG_DIRS": "/etc/xdg/xdg-gnome:/etc/xdg",
            "XDG_DATA_DIRS": "/usr/share/gnome:/usr/local/share/:/usr/share/",
            "XDG_SESSION_COOKIE": "aa11096f4c5d692f1d7163080000000d-1302985532.6160-1168950418"
        },
        "euid": 1000,
        "exe": "/bin/zsh4",
        "exit_signal": 17,
        "fd": {
            "0": "/dev/pts/3",
            "1": "/dev/pts/3",
            "10": "/dev/pts/3",
            "12": "/usr/share/zsh/functions/Completion.zwc",
            "15": "/usr/share/zsh/functions/Misc.zwc",
            "16": "/usr/share/zsh/functions/Prompts.zwc",
            "2": "/dev/pts/3"
        },
        "flags": 4202496,
        "gid": 1000,
        "itrealvalue": 0,
        "kstkeip": 3079078934,
        "kstkesp": 3220654232,
        "majflt": 10,
        "minflt": 8283,
        "name": "zsh",
        "nice": 0,
        "nswap": 0,
        "pgrp": 15125,
        "pid": 15125,
        "policy": 0,
        "ppid": 15121,
        "priority": 20,
        "processor": 0,
        "rlim": 4294967295,
        "root": "/",
        "rss": 919,
        "rss_bytes": 3764224,
        "rt_priority": 0,
        "session": 15125,
        "sigcatch": 134291459,
        "sigignore": 3686404,
        "signal": 0,
        "startcode": 134512640,
        "startstack": 3220655744,
        "starttime": 117923339,
        "state": "S",
        "stime": 10,
        "tpgid": 15552,
        "tty_nr": 34819,
        "uid": 1000,
        "utime": 29,
        "vsize": 8523776,
        "wchan": 3222662362
    }

All additional fields are also described in manual for _/proc_ filesystem (`man proc`).

If given PID is invalid or refers to nonexistent process then response status
is set to 404.

## Tests

Test suite for the app can be run by following command:

    rake tests
