function fixFig(fig, options)
%FIXFIG takes in a figure handle of 'fig' and an 'options' structure
%
% fixFig(fig, options)
%
% Typical usage involves the use of 'legend' and 'location' to set the
% figure's legend (a cell array) and the location of the legend.
% 'useColor' will force the plot to change the color of each line and
% 'markerCount' will change the number of markers per line.  'noMark' will
% disable the addition of markers for each line.
%
% Options:
%   -boxPlt     (def=0)
%   -thinLine   (def=0)
%   -allMark    (def=0)
%   -noLine     (def=0)
%   -offMark    (def=0)
%   -repMark    (def=0)
%   -linMark    (def=0)
%   -noMark     (def=0)
%   -useColor   (def=0)
%   -noLineFormat (def=0)
%   -markerCount (def=11)
%   -legend     (def=0)
%   -location   (def=Southeast)
%   -figWidth   (def=7)
%   -figHeight  (def=4)
%
% Examples:
% figure(1)
% plot(x,y1,x,y2);
% myLegend = legend({'y1', 'y2'});
% fh = gcf;
% opts=struct('legend',myLegend,'location','Northwest','useColor',1,'noMark',1);
% fixFig(fh, opts);


set(findall(fig,'type','text'),'fontName','Helvetica','fontSize',10, 'fontWeight', 'bold')

def = struct(...
        'boxPlt',       0, ...
        'thinLine',     0, ...
        'allMark',      0, ...
        'noLine',       0, ...
        'noLineFormat', 0, ...
        'offMark',      0, ...
        'repMark',      0, ...
        'linMark',      0, ...
        'noMark',       0, ...
        'useColor',     0, ...
        'markerCount', 11, ...
        'legend',       0, ...
        'location', 'Southeast', ...
        'figWidth',     7, ...
        'figHeight',    4);

% Check number of input arguments
if ~nargin
    options = def;
else
    if ~isstruct(options)
        error('MATLAB:anneal:badOptions',...
              'Input argument ''options'' is not a structure')
    end
    params = {'boxPlt', 'thinLine', 'allMark', 'noLine', 'offMark', ...
              'repMark', 'linMark', 'noMark', 'useColor', 'markerCount',...
              'legend', 'location', 'figWidth', 'figHeight', 'noLineFormat'};
    for nm = 1:length(params)
        if ~isfield(options, params{nm})
            options.(params{nm}) = def.(params{nm});
        end
    end
   
end


figure(fig)
A = axis;
axis(A);


set(fig,'Units','inches');
curPos = get(fig,'Position');
set(fig,'Position',[curPos(1) curPos(2) options.figWidth options.figHeight]);
set(fig,'PaperPosition', [0 0 options.figWidth options.figHeight])

if options.legend ~= 0
    set(options.legend, 'Location', options.location);
    set(options.legend, 'fontsize', 10);
    set(options.legend, 'fontName', 'Helvetica');
    set(options.legend, 'Box', 'off');
end

if options.boxPlt
    lineH = findall(fig,'type','line');
else
    lineH = get(gca,'Children');
end

if ~options.noLineFormat
    for i=1:length(lineH)
        marker = ['o' 'd' 's' '^' 'v' '<' '>' '+' '*' 'x'];
        colors  = ['b' 'r' 'g' 'y' 'm' 'c' 'k'];

        if options.noLine
            set(lineH(i),'LineStyle','none');
        end

        if(options.thinLine)
            set(lineH(i),'LineWidth',0.5);
        else
            set(lineH(i),'LineWidth',2);
        end

        markIndex = mod(i,options.repMark) + options.offMark;
        colorIndex = mod(i,length(colors)+1);
        if markIndex == 0
            markIndex = options.repMark + options.offMark;
        end

        if ~options.noLine
            if options.useColor
                set(lineH(i), 'Color', colors(colorIndex));
            else
                set(lineH(i),'Color','k');
            end
        end

        if ~options.noMark
            set(lineH(i),'Marker',marker(markIndex));
            set(lineH(i),'MarkerSize',6);
        end
    end
end

if ~options.noMark && ~options.allMark && ~options.noLineFormat
    nummarkers(gca,options.markerCount,options.linMark);
end

grid on

fig.PaperSize = [options.figWidth options.figHeight];
% lineAxes = gca;
% 
% if (strcmp(get(lineAxes,'color'),'none'))
%     set(lineAxes,'color','none')
%     set(lineAxes,'xcolor','k')
%     set(lineAxes,'ycolor','k')
%     uistack(lineAxes,'top')
% else
%     gridAxes = copyobj(lineAxes,gcf);
%     
%     delete(get(gridAxes,'children'))
%     
%     set(gridAxes,'xgrid','on')
%     set(gridAxes,'xcolor',[0.75 0.75 0.75])
%     set(gridAxes,'ygrid','on')
%     set(gridAxes,'ycolor',[0.75 0.75 0.75])
%     set(gridAxes,'gridlinestyle','-')
%     set(gridAxes,'minorgridlinestyle','-')
%     
%     set(lineAxes,'color','none')
%     set(lineAxes,'xcolor','k')
%     set(lineAxes,'ycolor','k')
%     
%     uistack(gridAxes,'top')
%     uistack(lineAxes,'top')
% end





