function [xout,ystatout]=statplot(x,y,dx,stat,xlims,binmin,lstyle,lwidth,percentile)

% function [xout,ystatout]=statplot(x,y,dx,stat,xlims,binmin,lstyle,lwidth,percentile)
% 
% plots a statistic of y with x in bins of size dx
% stat can be set to 'mean', 'std', 'ster', 'max', 'min' or 'prctile'
% xlims=[xmin xmax] is an optional input to specify the range
% lstyle='ro', 'g-', 'b-x', etc is an optional input to specify the colour and style of the line
% lwidth is an optional input to specify the line width

x=x(:);
y=y(:);

good = ~isnan(x) & ~isnan(y);
x=x(good);
y=y(good);

if nargin<5
    xmin=min(x);
    xmax=max(x);
else
    if isempty(xlims)
        xmin=min(x);
        xmax=max(x);
    else
        xmin=xlims(1);
        xmax=xlims(2);
    end
end
if nargin<6 || isempty(binmin)
    binmin=1;
end
if nargin<7 || isempty(lstyle)
    lstyle='-o';
end
if nargin<8 || isempty(lwidth)
    lwidth=1;
end

xvals=(xmin+dx/2:dx:xmax-dx/2)';
ystat=nan*xvals;
for i=1:length(xvals)
    bin= x>=xvals(i)-dx/2 & x<xvals(i)+dx/2;
    if sum(bin)<binmin
        ystat(i)=NaN;
    else
        if strcmpi(stat,'mean')
            ystat(i)=mean(y(bin));
        elseif strcmpi(stat,'std')
            ystat(i)=std(y(bin));
        elseif strcmpi(stat,'ster')
            ystat(i)=std(y(bin))/mean(y(bin));
        elseif strcmpi(stat,'max')
            ystat(i)=max(y(bin));
        elseif strcmpi(stat,'min')
            ystat(i)=min(y(bin));
        elseif strcmpi(stat,'prctile')
            ystat(i)=prctile(y(bin),percentile);
        elseif strcmpi(stat,'sum')
            ystat(i)=sum(y(bin));
        end
    end
end

if nargout==0
    plot(xvals,ystat,lstyle,'linewidth',lwidth)
    xlabel('x')
    if strcmpi(stat,'mean')
        ylabel('mean(y)')
    elseif strcmpi(stat,'std')
        ylabel('std(y)')
    elseif strcmpi(stat,'ster')
        ylabel('standard error(y)')
    elseif strcmpi(stat,'max')
        ylabel('max(y)')
    elseif strcmpi(stat,'min')
        ylabel('min(y)')
    end
else
    xout=xvals;
    ystatout=ystat;
end
