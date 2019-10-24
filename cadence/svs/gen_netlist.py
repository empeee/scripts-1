"""Handle gds and cdl netlist creation."""

from os import getcwd, system
from os.path import join
from svs.rules import TECHLIB, SKILL_FILE, MAP_FILE, INCFILE


def run_netlist(lib, cell, view, out_dir, check_type='schematic'):
    """Run netlisting utility."""
    if check_type == 'schematic':
        run_cmd, netlist_name = get_cdl_cmd(lib, cell, view, out_dir)
    else:
        run_cmd, netlist_name = get_gds_cmd(lib, cell, view, out_dir)
    print(run_cmd)
    system(run_cmd)
    return netlist_name
    

def get_gds_cmd(lib, cell, view, rundir):
    """Build command to extract gds."""
    strmfile = lib+"__"+cell+".gds"
    data = {
        "-library": lib,
        "-strmFile": strmfile,
        "-techLib": TECHLIB,
        "-topCell": cell,
        "-view": view,
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


def get_cdl_cmd(lib, cell, view, rundir):
    """Build command to generate cdl netlist."""
    viewlist = '"auCdl" "'+view+'"'
    stoplist = '"auCdl"'
    netlist_name = lib+"__"+cell+'.cdl'
    command_values = {
            'simLibName': '"'+lib+'"',
            'simCellName': '"'+cell+'"',
            'simViewName': '"'+view+'"',
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
    out_file = join(getcwd(), 'si.env')
    f = open(out_file, 'w')
    for key, val in command_values.items():
        f.write(key+" = "+val+"\n")
    f.close()
    print("Created "+out_file)

    run_cmd = "si -batch -command netlist"

    return (run_cmd, netlist_name)