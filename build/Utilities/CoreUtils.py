#!/usr/bin/python
#

import os
import string
import random
import json


def doesFileExist(file):
    return os.path.exists(file)


def generate_random_pass():
    length = 18
    chars = string.ascii_letters + string.digits + '!@#$%^&*()+-_[]'
    rnd = random.SystemRandom()
    print(''.join(rnd.choice(chars) for i in range(length)))


def read_json(file):
    file = open(file)
    js = json.loads(file.read())
    return js


def get_option(option):
    js = read_json('./options.json')
    return js[option]


def get_help(option):
    js = read_json('./help.json')
    return js[option]