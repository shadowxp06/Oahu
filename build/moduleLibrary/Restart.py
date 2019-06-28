#!/usr/bin/python3
#
# Restart Command
#
# It needs to be either a fully qualified path or a command

from Utilities import command_shell
from Utilities import CoreUtils


class Restart(object):
    __command__ = ""

    def __init__(self):
        self.__command__ = "NoCommand"

    def __init__(self, command):
        self.__command__ = command
        self.runcommand()

    def __init__(self, command, isShellScript):
        fileExists = CoreUtils.doesFileExist(command)
        if isShellScript and fileExists:
            self.__command__ = command
            self.runcommand()
        else:
            print('Script File does not exist')

    def runcommand(self):
        if self.__command__ == 'nginx':
            command_shell.run_shell_command("sudo service nginx restart")
        elif self.__command__ == 'postgresql':
            command_shell.run_shell_command("sudo service ")
        elif self.__command__ == 'api-dev':
            print('place holder')
        elif self.__command__ == 'client-dev':
            print('place holder')
        elif self.__command__ == 'api-prod':
            print('place holder')
        elif self.__command__ == 'client-prod':
            print('place holder')
        else:
            print(CoreUtils.get_help('restart'))