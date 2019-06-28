#!/usr/bin/python3
#
# Show Command

from Utilities import command_shell
from Utilities import CoreUtils


class Show(object):
    __command__ = ""

    def __init__(self):
        self.__command__ = "NoCommand"

    def __init__(self, command):
        self.__command__ = command
        self.runcommand()

    def runcommand(self):
        if self.__command__ == 'about':
            print('--- ' + CoreUtils.get_option('prodname') + ' ---')
            print('v ' + CoreUtils.get_option('version'))
        elif self.__command__ == 'service_status':
            print('Holder')
        elif self.__command__ == 'netstat_listening':
            command_shell.run_shell_command('netstat -anltp | grep LISTEN')
        else:
            print(CoreUtils.get_help('show'))
