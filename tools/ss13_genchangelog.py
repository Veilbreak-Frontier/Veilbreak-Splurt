from __future__ import print_function
import yaml, os, glob, sys, re, time, argparse
from datetime import datetime, date, timedelta
from time import time

today = date.today()
fileDateFormat = "%Y-%m"

opt = argparse.ArgumentParser()
opt.add_argument('ymlDir', help='The directory of YAML changelogs we will use.')
args = opt.parse_args()

archiveDir = os.path.join(args.ymlDir, 'veilbreak_archive')

validPrefixes = [
    'bugfix', 'wip', 'qol', 'soundadd', 'sounddel', 'rscadd', 'rscdel',
    'imageadd', 'imagedel', 'spellcheck', 'experiment', 'balance',
    'code_imp', 'refactor', 'config', 'admin', 'server', 'sound', 'image', 'map'
]

def dictToTuples(inp):
    return [(k, v) for k, v in inp.items()]

print('Reading changelogs...')

formattedDate = today.strftime(fileDateFormat)
branches = ['veilbreak', 'splurt', 'bubber', 'upstream']
branch_entries = {b: {} for b in branches}

for branch in branches:
    prefix = "" if branch == "upstream" else branch + "_"
    monthFile = os.path.join(args.ymlDir, "{}{}.yml".format(prefix, formattedDate))
    if os.path.exists(monthFile):
        with open(monthFile, 'r', encoding='utf-8') as f:
            branch_entries[branch] = yaml.load(f, Loader=yaml.SafeLoader) or {}

for fileName in glob.glob(os.path.join(args.ymlDir, "*.yml")):
    name, ext = os.path.splitext(os.path.basename(fileName))
    if name.startswith('.'): continue
    if name == 'example': continue

    if "veilbreak" in name:
        target_branch = "veilbreak"
    elif "splurt" in name:
        target_branch = "splurt"
    elif "bubber" in name:
        target_branch = "bubber"
    else:
        target_branch = "upstream"

    fileName = os.path.abspath(fileName)
    print(' Reading {} (Targeting branch: {})...'.format(fileName, target_branch))

    cl = {}
    with open(fileName, 'r', encoding='utf-8') as f:
        cl = yaml.load(f, Loader=yaml.SafeLoader)

    currentEntries = branch_entries[target_branch]

    if today not in currentEntries:
        currentEntries[today] = {}

    author_entries = currentEntries[today].get(cl['author'], [])
    if len(cl['changes']):
        new = 0
        for change in cl['changes']:
            if change not in author_entries:
                (change_type, _) = dictToTuples(change)[0]
                if change_type not in validPrefixes:
                    print('  {0}: Invalid prefix {1}'.format(fileName, change_type), file=sys.stderr)
                    sys.exit(1)
                author_entries += [change]
                new += 1
        currentEntries[today][cl['author']] = author_entries
        if new > 0:
            print('  Added {0} new changelog entries to {1}.'.format(new, target_branch))

    if cl.get('delete-after', False):
        if os.path.isfile(fileName):
            print('  Deleting {0} (delete-after set)...'.format(fileName))
            os.remove(fileName)

print('Writing master consolidated files to directories...')
for branch in branches:
    prefix = "" if branch == "upstream" else branch + "_"

    targetPath = os.path.join(args.ymlDir, "{}{}.yml".format(prefix, formattedDate))
    with open(targetPath, 'w', encoding='utf-8') as f:
        yaml.dump(branch_entries[branch], f, default_flow_style=False)

    if not os.path.exists(archiveDir):
        os.makedirs(archiveDir)
    archiveFile = os.path.join(archiveDir, "{}{}.yml".format(prefix, formattedDate))
    with open(archiveFile, 'w', encoding='utf-8') as f:
        yaml.dump(branch_entries[branch], f, default_flow_style=False)
