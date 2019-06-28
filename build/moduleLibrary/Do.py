#!/usr/bin/python3
#
# Do Command

from Utilities import command_shell
from Utilities import CoreUtils


class Do(object):

    def runcommand(self, args):
        if len(args) > 1:
            if args[0] == 'maintenance':
                self.__runmaintenance(args[1])
            elif args[0] == 'install':
                self.__runinstall(args[1])
            elif args[0] == 'audit':
                if len(args) > 1:
                    if args[1] == 'api':
                        self.__audit_api()
                    elif args[1] == 'client':
                        self.__audit_client()
                    else:
                        print(CoreUtils.get_help('do audit'))
                else:
                    print(CoreUtils.get_help('do audit'))
            else:
                print(CoreUtils.get_help('do'))
        else:
            print(CoreUtils.get_help('do'))

    def __runinstall(self, args):
        if args == 'prereqs':
            self.__installpreqs()
        elif args == 'project':
            self.__installproject()
        else:
            print(CoreUtils.get_help('do install'))

    def __runmaintenance(self, args):
        if args == 'db':
            print('run DB Maintenance')
        elif args == 'manage_script_upgrade':
            self.__runmanagementscriptupdate()
        elif args == 'logs':
            print('Logs Maintenance')
        elif args == 'system_upgrades':
            command_shell.run_shell_command('sudo apt-get update -y && sudo apt-get upgrade -y')
        else:
            print(CoreUtils.get_help('do maintenance'))

    @staticmethod
    def __runmanagementscriptupdate():
        command_shell.run_shell_command('git config --global credential.helper \"cache --timeout=3600\"')
        command_shell.run_shell_command('cd \\oms-discussions\\build && sudo git reset --hard HEAD')
        command_shell.run_shell_command('sudo git clean -f')
        command_shell.run_shell_command('sudo git pull')

    @staticmethod
    def __installpreqs():
        command_shell.run_shell_command('sudo apt-add-repository ppa:ansible/ansible-2.6 && sudo apt-get update && sudo apt-get install -y ansible git')

    @staticmethod
    def __installproject():
        command_shell.run_shell_command('git config --global credential.helper \"cache --timeout=3600\"')
        command_shell.run_shell_command('git clone https://github.gatech.edu/wking6/oms-discussions.git ' + CoreUtils.get_option('main_directory'))
        command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/ansible')
        command_shell.run_shell_command('ansible-playbook -c local omsdiscussions.yml -i "localhost"')

    @staticmethod
    def __audit_api():
        command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/api && sudo npm audit')

    @staticmethod
    def __audit_client():
        command_shell.run_shell_command('cd ' + CoreUtils.get_option('main_directory') + '/oms-discussions && sudo npm audit')