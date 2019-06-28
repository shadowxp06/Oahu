#!/usr/bin/python3
#

# Source: https://stackoverflow.com/questions/2806897/what-is-the-best-way-for-checking-if-the-user-of-a-script-has-root-like-privileg
import os

if os.getegid() != 0:
    exit("This script requires root or sudo to run.  Exiting...")

import argparse
import moduleLibrary
import Utilities

do_help = Utilities.get_help('do')
restart_help = Utilities.get_help('restart')
show_help = Utilities.get_help('show')
build_help = Utilities.get_help('build')

argparser = argparse.ArgumentParser()
argparser.add_argument('-do', nargs='*', default='', help=do_help, dest='_do')
argparser.add_argument('-restart', nargs='*', default='', help=restart_help, dest='_restart')
argparser.add_argument('-show', nargs='*', default='', help=show_help, dest='_show')
argparser.add_argument('-build', nargs='*', default='', help=build_help, dest='_build')
args = argparser.parse_args()

if args._do != '':
    run = moduleLibrary.Do()
    run.runcommand(args._do)
elif args._restart != '':
    if len(args._show) > 0:
        run = moduleLibrary.Restart(args._restart[0])
    else:
        print(restart_help)
elif args._show != '':
    if len(args._show) > 0:
        run = moduleLibrary.Show(args._show[0])
    else:
        print(show_help)
elif args._build != '':
    if len(args._build) > 0:
        run = moduleLibrary.Build(args._build[0])
        run.build()
    else:
        print(build_help)