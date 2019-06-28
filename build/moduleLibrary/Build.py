#!/usr/bin/python3
#


from Utilities import CoreUtils
from Utilities import command_shell


class Build(object):
    __json = ""
    __command = ""

    def __init__(self):
        self.__json = CoreUtils.read_json('./options.json')
        self.__command = "NoCommand"

    def __init__(self, command):
        self.__json = CoreUtils.read_json('./options.json')
        self.__command = command

    def setCommand(self, command):
        self.__command = command

    def build(self):
        if self.__command == 'api-dev':
            command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/api')
            command_shell.run_shell_command('npm install')
        elif self.__command == 'client-dev':
            command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/client && sudo npm install && sudo ng build')
        elif self.__command == 'api-prod':
            command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/api && sudo npm install')
        elif self.__command == 'client-prod':
            command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/client && sudo npm install && sudo ng build --dist --prod --build-optimizer')
        else:
            print(CoreUtils.get_help('show'))