#!/usr/bin/env python
"""This scripts automatically checks for updates on the used tools."""

import os
import json
import re
import requests
from bs4 import BeautifulSoup

class color:
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    ORANGE = '\033[0;33m'
    BOLD = '\033[1m'
    NORMAL = '\033[0m'

# Load the current version numbers
DOCKER_HOMEBRIDGE_VERSION='4.41.5'
DOCKER_PIHOLE_VERSION='5.6'

def print_warn(message):
    print(color.ORANGE+message+color.NORMAL)

def print_ok(message):
    print(color.GREEN+message+color.NORMAL)

def get_latest_github_version(url, regex):
    """Retrieve the latest released version of a GitHub project."""
    soup = BeautifulSoup(requests.get(url).text, "html.parser")
    prog = re.compile(regex, re.IGNORECASE)
    project_version = ''
    project_href = "https://github.com"

    for anchor in soup.findAll('a', href=True):
        href = anchor['href']
        match = prog.match(href)
        if match:
            project_href = project_href+href
            project_version = match.group(1)
            break

    return project_version, project_href

def check_latest_github_version(url, regex, name, project_version_current):
    """Check if the current used versions is the latest released one foor a GitHub project."""
    project_version, project_href = get_latest_github_version(url, regex)
    if project_version != project_version_current:
        print_warn(name+' - New version available: '+project_version)
    else:
        print_ok(name+' - Version up-to-date: '+project_version)

## Homebridge
check_latest_github_version(
    'https://github.com/oznu/homebridge-config-ui-x/releases/latest',
    r'.*oznu/homebridge-config-ui-x/tree/(.*)',
    'Homebridge Config UI',
    DOCKER_HOMEBRIDGE_VERSION)

## Pihole
check_latest_github_version(
    'https://github.com/pi-hole/pi-hole/releases/latest',
    r'.*pi-hole/pi-hole/tree/v(.*)',
    'Pihole',
    DOCKER_PIHOLE_VERSION)
