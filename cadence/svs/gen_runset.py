"""Generates runsets."""
from os import getcwd
from os.path import join
from svs.rules import RULE_FILE, DRC_FILE


def gen_svs_runset(data):
    """Generate SVS runset."""
    info = {
        "*lvsRulesFile": RULE_FILE,
        "*lvsRunDir": join(getcwd(), "CALIBRE"),
        "*lvsLayoutPaths": data['top']+'.calibre.db',
        "*lvsLayoutPrimary": data['top'],
        "*lvsLayoutLibrary": data['library'][0],
        "*lvsLayoutView": "layout",
        "*lvsLayoutGetFromViewer": "1",
        "*lvsSourcePath": data['netlist'][0],
        "*lvsSourcePrimary": data['top'],
        "*lvsSourceLibrary": data['library'][0],
        "*lvsSourceView": data['views'][0],
        "*lvsSourceLibrary2": data['library'][1],
        "*lvsSourceView2": data['views'][1],
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
    runset = join(getcwd(), "CALIBRE/svs.runset")
    return _write_to_runset(runset, info)


def gen_lvl_runset(data):
    """Generate LVL Runset."""
    info = {
        "*drcRulesFile": DRC_FILE,
        "*drcRunDir": join(getcwd(), "CALIBRE"),
        "*drcLayoutPaths": data['netlist'][0],
        "*drcLayoutPrimary": data['top'],
        "*drcLayoutLibrary": data['library'][0],
        "*drcLayoutView": data['views'][0],
        "*drcResultsFile": data['top']+'.drc.results',
        "*drcCreateXORRule": "1",
        "*drcLayoutPaths2": data['netlist'][1],
        "*drcLayoutPrimary2": data['top'],
        "*drcLayoutLibrary2": data['library'][1],
        "*drcLayoutView2": data['views'][1],
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
    runset = join(getcwd(), "CALIBRE/lvl.runset")
    return _write_to_runset(runset, info)


def _write_to_runset(runset, info):
    """Write info to runset file."""
    f = open(runset, 'w')
    for key, item in info.items():
        f.write(key +': '+item+'\n')
    f.close()
    print("Created "+runset+"\n")
    return runset