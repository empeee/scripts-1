"""
Generates cdl netlists for use in SVS.

Author: Kevin Fronczak
Date: 2019-09-10
"""

import sys
import os
from svs.gen_runset import gen_svs_runset, gen_lvl_runset
from svs.gen_netlist import run_netlist
from svs.helpers import PRINT_CORRECT, PRINT_INCORRECT
from svs.rules import RULE_FILE, DRC_FILE, MAP_FILE, INCFILE, TECHLIB, SKILL_FILE

# Version based on date YYYYY.MM.DD.patch
version="2019.10.21.1"

COMMAND_HELP = (
"svs.py version "+version+"\n" \
"USAGE:\n" \
"\n" \
"python svs.py [lvl] lib1 lib2 topcell [opts]\n" \
"\n" \
"Generates CDL netlists for schematic views of given cellname and library\n" \
"and then runs SVS to compare.  The netlist is saved in your workdir/CDL\n" \
"and the LVS report is in workdir/CALIBRE\n" \
"Calling svs.py with the first argument of 'lvl' will run layout-vs-layout instead\n" \
"\n" \
"OPTIONS:"\
"  --views            List of views relative to lib1 and lib2\n"
"\n")

def parse_args():
    """Dumb method to parse arguments."""
    start_index = 2
    run_lvl = True
    view1 = 'layout'
    view2 = 'layout'
    if len(sys.argv) < 4:
        print(COMMAND_HELP)
        sys.exit(1)
    elif len(sys.argv) < 5:
        start_index = 1
        run_lvl = False
        view1 = 'schematic'
        view2 = 'schematic'
    else:
        if sys.argv[1] != 'lvl':
            run_lvl = False
            start_index = 1
            view1 = 'schematic'
            view2 = 'schematic'
        if len(sys.argv) > (start_index + 3):
            if sys.argv[start_index+3] == '--views':
                if len(sys.argv) < (start_index + 5):
                    print(COMMAND_HELP)
                    sys.exit(1)
                else:
                    view1 = sys.argv[start_index+4]
                    view2 = sys.argv[start_index+5]
            else:
              print(COMMAND_HELP)
              sys.exit(1)

    args = sys.argv[start_index:]
    # We're hoping the user doesn't screw up the argument order
    # because I'm too lazy to add a check
    lib1 = args[0]
    lib2 = args[1]
    cell = args[2]

    return {lib1: [cell, view1], lib2: [cell, view2], 'lvl': run_lvl}


def get_working_dir(layout=False):
    """
    Gets the current working directory and output netlist dir.
    """
    cwd = os.getcwd()
    print("Current directory found: " + cwd)

    out_dir = os.path.join(cwd, "CDL")
    if layout:
        out_dir = os.path.join(cwd, "STRMINOUT")

    if not os.path.exists(out_dir):
        print(out_dir + " doesn't exist!\n")
        sys.exit(1)

    return out_dir

def open_report(top_cell, layout=False):
    if not layout:
        report_file = top_cell+'.lvs.report'
        report = os.path.join(os.getcwd(), "CALIBRE/"+report_file)
        os.system("more "+report)
        return

    report_file = 'rules.fxor.summary'
    report = os.path.join(os.getcwd(), "CALIBRE/"+report_file)
    os.system("tail -20 "+report)
    fh = open(report, 'r')
    # Store last line in file
    for line in fh:
        if line.rstrip():
            last = line.rstrip()
    fh.close()
    if last == "--- FASTXOR: DESIGNS ARE SAME":
        print(PRINT_CORRECT)
    else:
        print(PRINT_INCORRECT)
    return


def move_netlist(out_dir, fname):
    src = os.path.join(os.getcwd(), fname)
    dst = os.path.join(out_dir, fname)
    os.system("mv "+src+" "+dst)
    return dst
    

def run(data, layout=False):
    """Runs SVS/LVL for provided netlists."""
    if layout:
        runset = gen_lvl_runset(data)
        cmd = "calibre -gui -drc -runset "+runset+" -batch"
    else:
        runset = gen_svs_runset(data)
        cmd = "calibre -gui -lvs -runset "+runset+" -batch"
    os.system(cmd)
    return


if __name__ == "__main__":
    cells = parse_args()
    out_dir = get_working_dir(layout=cells['lvl'])
    files = list()
    check_type = 'schematic'
    if cells['lvl']:
        check_type = 'layout'
    libs = []
    views = []
    for lib, cell in cells.items():
        if lib == "lvl":
            continue
        cell_name = cell[0]
        cell_view = cell[1]
        netlist_name = run_netlist(lib, cell_name, cell_view, out_dir, check_type=check_type)
        netlist_result = os.path.join(out_dir, netlist_name)
        if check_type == 'schematic':
            netlist_result = move_netlist(out_dir, netlist_name)
        files.append(netlist_result)
        libs.append(lib)
        views.append(cell_view)
        top_cell = cell_name
    print("\n")
    print("Created:\n")
    print("\t"+files[0]+"\n")
    print("\t"+files[1]+"\n")
    data = {
        'top': top_cell,
        'library': libs,
        'views': views,
        'netlist': files,
    }

    run(data, layout=cells['lvl'])
    open_report(top_cell, layout=cells['lvl'])

    print("\nComplete!\n")




