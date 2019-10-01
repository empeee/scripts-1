"""
Generates cdl netlists for use in SVS.

Author: Kevin Fronczak, ISDC
Date: 2019-09-10
"""

version="2019.09.11.1"

import sys
import os

COMMAND_HELP = (
"svs.py version "+version+"\n" \
"USAGE:\n" \
"\n" \
"python svs.py [lvl] lib1 lib2 topcell\n" \
"\n" \
"Generates CDL netlists for schematic views of given cellname and library\n" \
"and then runs SVS to compare.  The netlist is saved in your workdir/CDL\n" \
"and the LVS report is in workdir/CALIBRE\n" \
"Calling svs.py with the first argument of 'lvl' will run layout-vs-layout instead\n")


#Probably shouldn't be hard-coded...
RULE_FILE = "/path/to/rule/file"
DRC_FILE = "/path/to/drc/file"
MAP_FILE = "/path/to/object/map"
INCFILE = "/path/to/lvs/source.added"
TECHLIB = "pdk_identifier"
SKILL_FILE = "/path/to/skillfile.ile"

def parse_args():
    """Dumb method to parse arguments."""
    start_index = 2
    run_lvl = True
    if len(sys.argv) < 4:
        print(COMMAND_HELP)
        sys.exit(1)
    elif len(sys.argv) < 5:
        start_index = 1
        run_lvl = False
    elif sys.argv[1] != "lvl":
        print(COMMAND_HELP)
        sys.exit(1)

    args = sys.argv[start_index:]
    # We're hoping the user doesn't screw up the argument order
    # because I'm too lazy to add a check
    lib1 = args[0]
    lib2 = args[1]
    cell = args[2]

    return {lib1: cell, lib2: cell, 'lvl': run_lvl}


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


def get_gds_cmd(lib, cell, rundir):
    """Build command to extract gds."""
    strmfile = lib+"__"+cell+".gds"
    data = {
        "-library": lib,
        "-strmFile": strmfile,
        "-techLib": TECHLIB,
        "-topCell": cell,
        "-view": "layout",
        "-logFile": "strmOut.log",
        "-outputDir": rundir,
        "-userSkillFile": SKILL_FILE,
        "-objectMap": MAP_FILE,
        "-maxVertices": "199",
    }
    run_cmd = "strmout"
    for key, item in data.items():
        run_cmd = run_cmd + " " + key + " " + item

    return (run_cmd, strmfile)

def get_cdl_cmd(lib, cell, rundir):
    """Build command to generate cdl netlist."""
    viewlist = '"auCdl" "schematic"'
    stoplist = '"auCdl"'
    netlist_name = lib+"__"+cell+'.cdl'
    command_values = {
            'simLibName': '"'+lib+'"',
            'simCellName': '"'+cell+'"',
            'simViewName': '"schematic"',
            'simSimulator': '"auCdl"',
            'simNotIncremental': "'t",
            'simViewList': "'(" + viewlist + ")",
            'simStopList': "'(" + stoplist + ")",
            'simNetlistHier': "'t",
            'nlFormatterClass': "'spectreFormatter",
            'hnlNetlistFileName': '"'+netlist_name+'"',
            'shortRes': "2000.0",
            'preserveRES': "'t",
            'checkRESVAL': "'t",
            'preservceCAP': "'t",
            'checkCAPVAL': "'t",
            'preserveDIO': "'t",
            'checkDIOAREA': "'t",
            'checkDIOPERI': "'t",
            'checkCAPPERI': "'t",
            'checkScale': '"meter"',
            'shrinkFACTOR': "0.0",
            'displayPININFO': "'t",
            'setEQUIV': '""',
            'preserveALL': "'t",
            'incFILE': '"'+INCFILE+'"',
            'auCdlDefNetlistProc': '"ansCdlSubcktCall"'
    }
    out_file = os.path.join(os.getcwd(), 'si.env')
    f = open(out_file, 'w')
    for key, val in command_values.items():
        f.write(key+" = "+val+"\n")
    f.close()
    print("Created "+out_file)

    run_cmd = "si -batch -command netlist"

    return (run_cmd, netlist_name)


def gen_svs_runset(data):
    """Generate SVS runset."""
    view = 'schematic'
    info = {
        "*lvsRulesFile": RULE_FILE,
        "*lvsRunDir": os.path.join(os.getcwd(), "CALIBRE"),
        "*lvsLayoutPaths": data['top']+'.calibre.db',
        "*lvsLayoutPrimary": data['top'],
        "*lvsLayoutLibrary": data['library'][0],
        "*lvsLayoutView": "layout",
        "*lvsLayoutGetFromViewer": "1",
        "*lvsSourcePath": data['netlist'][0],
        "*lvsSourcePrimary": data['top'],
        "*lvsSourceLibrary": data['library'][0],
        "*lvsSourceView": view,
        "*lvsSourceLibrary2": data['library'][1],
        "*lvsSourceView2": view,
        "*lvsRunWhat": "NVN",
        "*lvsSpiceFile": data['netlist'][1],
        "*lvsAutoMatch": "1",
        "*lvsPlacementMatch": "1",
        "*lvsRecognizeGates": "NONE",
        "*lvsReduceSplitGates": "0",
        "*lvsReduceParallelMOS": "0",
        "*lvsERCDatabase": data['top']+'.erc.results',
        "*lvsERCSummaryFile": data['top']+'.erc.summary',
        "*lvsReportFile": data['top']+'.lvs.report',
        "*lvsReportMaximumAll": "1",
        "*cmnShowOptions": "1",
        "*cmnSlaveHosts": "{use {}} {hostName {}} {cpuCount {}} {a32a64 {}} {rsh {}} {maxMem {}} {workingDir {}} {layerDir {}} {mgcLibPath {}} {launchName {}}",
        "*cmnLSFSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*cmnGridSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*cmnFDILayoutLibrary": data['library'][0],
        "*cmnFDILayoutView": "layout",
        "*cmnFDIDEFLayoutPath": data['top']+'.def',
    }
    runset = os.path.join(os.getcwd(), "CALIBRE/svs.runset")
    f = open(runset, 'w')
    for key, item in info.items():
        f.write(key +': '+item+'\n')
    f.close()
    print("Created runset\n")
    return runset


def gen_lvl_runset(data):
    """Generate LVL Runset."""

    info = {
        "*drcRulesFile": DRC_FILE,
        "*drcRunDir": os.path.join(os.getcwd(), "CALIBRE"),
        "*drcLayoutPaths": data['netlist'][0],
        "*drcLayoutPrimary": data['top'],
        "*drcLayoutLibrary": data['library'][0],
        "*drcLayoutView": "layout",
        "*drcResultsFile": data['top']+'.drc.results',
        "*drcCreateXORRule": "1",
        "*drcLayoutPaths2": data['netlist'][1],
        "*drcLayoutPrimary2": data['top'],
        "*drcLayoutLibrary2": data['library'][1],
        "*drcLayoutView2": "layout",
        "*drcSummaryFile": data['top']+'.drc.summary',
        "*drcIncrDRCSlaveHosts": "{use {}} {hostName {}} {cpuCount {}} {a32a64 {}} {rsh {}} {maxMem {}} {workingDir {}} {layerDir {}} {mgcLibPath {}} {launchName {}}",
        "*drcIncrDRCLSFSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*drcIncrDRCGridSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*cmnShowOptions": "1",
        "*cmnRunHier": "4",
        "*cmnSlaveHosts": "{use {}} {hostName {}} {cpuCount {}} {a32a64 {}} {rsh {}} {maxMem {}} {workingDir {}} {layerDir {}} {mgcLibPath {}} {launchName {}}",
        "*cmnLSFSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*cmnGridSlaveTbl": "{use 1} {totalCpus 1} {minCpus 1} {architecture {{}}} {minMemory {{}}} {resourceOptions {{}}} {submitOptions {{}}}",
        "*cmnFDILayoutLibrary": data['library'][0],
        "*cmnFDILayoutView": "layout",
        "*cmnFDIDEFLayoutPath": data['top']+'.def',
    }
    runset = os.path.join(os.getcwd(), "CALIBRE/lvl.runset")
    f = open(runset, 'w')
    for key, item in info.items():
        f.write(key +': '+item+'\n')
    f.close()
    print("Created runset\n")
    return runset


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
        print("\n")
        print("\t       #     ####################     _   _")
        print("\t      #      #                  #     *   *")
        print("\t #   #       #      CORRECT     #       |  ")
        print("\t  # #        #                  #     \\___/")
        print("\t   #         ####################      ")
        print("\n")
    else:
        print("\n")
        print("\t #   #       ####################")
        print("\t  # #        #                  #")
        print("\t   #         #     INCORRECT    #")
        print("\t  # #        #                  #")
        print("\t #   #       ####################")
        print("\n")
    return


def move_netlist(out_dir, fname):
    src = os.path.join(os.getcwd(), fname)
    dst = os.path.join(out_dir, fname)
    os.system("mv "+src+" "+dst)
    return dst


if __name__ == "__main__":
    cells = parse_args()
    out_dir = get_working_dir(layout=cells['lvl'])
    files = list()
    check_type = 'schematic'
    if cells['lvl']:
        check_type = 'layout'
    for lib, cell in cells.items():
        if lib == "lvl":
            continue
        if check_type == 'schematic':
            run_cmd, netlist_name = get_cdl_cmd(lib, cell, out_dir)
        else:
            run_cmd, netlist_name = get_gds_cmd(lib, cell, out_dir)
        print(run_cmd)
        os.system(run_cmd)
        netlist_result = os.path.join(out_dir, netlist_name)
        if check_type == 'schematic':
            netlist_result = move_netlist(out_dir, netlist_name)
        files.append(netlist_result)
        top_cell = cell
    print("\n")
    print("Created:\n")
    print("\t"+files[0]+"\n")
    print("\t"+files[1]+"\n")
    data = {
        'top': top_cell,
        'library': cells.keys(),
        'netlist': files,
    }

    run(data, layout=cells['lvl'])
    open_report(top_cell, layout=cells['lvl'])

    print("\nComplete!\n")




