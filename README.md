# scripts
Different general purpose scripts that make my life easier

bulk_convert.pl
-----------------
```
$ bulk_convert.pl [options] <extension> <directory of files>
```
Bulk converts images into vector (eps) format.  Basically, I'll have large directories of BMP or PNG images saved from simulation and when documentation time comes around, I need to supply the images in a vector format (otherwise we get really fuzzy, crappy images).  So this script will go through and create the eps images for me and I never have to do any extra work.

WeatherLog
-----------------

Python 3+ only.  I wrote this to help me debug some problems that I speculated had to do with weather patterns (humidity, pressure, etc)

#### Installation
```
python setup.py install
```

#### Usage
Create a config file that looks like so:
```ini
[Setup]
api=YOURAPIKEY FOR PYOWM
location=LOCATION (see city.list.json)
logpath=LOGPATH LOCATION
interval=INTERVALTOSCAN
runtime=HOW LONG TO RUN FOR
temp_unit=fahrenheit/celsius
```

Then call the module and set the path.
```python
import WeatherLog.WeatherLog as w

w.CONFIG_PATH = 'PATH TO YOUR CONFIG'
w.main()
```


matlab_plotting
-----------------
```
> fixFig(fig, options)
```
fixFig takes in a figure handle of 'fig' and an 'options' structure

Typical usage involves the use of 'legend' and 'location' to set the figure's legend (a cell array) and the location of the legend.  'useColor' will force the plot to change the color of each line and 'markerCount' will change the number of markers per line.  'noMark' will disable the addition of markers for each line.

Options:
  - boxPlt     (def=0)
  - thinLine   (def=0)
  - allMark    (def=0)
  - noLine     (def=0)
  - offMark    (def=0)
  - repMark    (def=0)
  - linMark    (def=0)
  - noMark     (def=0)
  - useColor   (def=0)
  - noLineFormat (def=0)
  - markerCount (def=11)
  - legend     (def=0)
  - location   (def=Southeast)
  - figWidth   (def=7)
  - figHeight  (def=4)

Examples:
```matlab
figure(1)
plot(x,y1,x,y2);
myLegend = legend({'y1', 'y2'});
fh = gcf;
opts=struct('legend',myLegend,'location','Northwest','useColor',1,'noMark',1);
fixFig(fh, opts);
```
