function [] = fixAxis(ax)
    set(ax,'fontSize',12,'fontWeight','bold','fontName','Helvetica')
    % this could be a function...
    col=.85*[1 1 1];
    xt=get(ax,'xtick');
    yt=get(ax,'ytick');
    xlim=get(ax,'xlim');
    ylim=get(ax,'ylim');
    x=[xt;xt];
    y=repmat(ylim.',1,size(x,2));
    line(x(:,2:end-1),y(:,2:end-1),...
            'color',col);
    y=[yt;yt];
    x=repmat(xlim.',1,size(y,2));
    line(x(:,2:end-1),y(:,2:end-1),...
            'color',col);
end