function nanimage(varargin)
    % nanimage(M)
    % nanimage(x,y,M)
    % produces a scaled image of the non-NaN cells of M
    % x and y are vectors of the locations of the centres of the cells of M
    % [length(y) length(x)]=size(M)

    if nargin==1
    M=varargin{1};
    [nrows ncols]=size(M);
    xmin=1;
    ymin=1;
    dx=1;
    dy=1;
    elseif nargin==3
    M=varargin{3};
    [nrows ncols]=size(M);
    x=varargin{1};
    y=varargin{2};
    if length(x)~=ncols
    error('length(x) must be equal to size(M,2)')
    elseif length(y)~=nrows
    error('length(y) must be equal to size(M,1)')
    end
    dx=x(2)-x(1);
    dy=y(2)-y(1);
    xmin=x(1);
    ymin=y(1);
    else
    error('inputs must be x,y,M or M only')
    end

    x = [xmin-dx/2 xmin+dx/2 xmin+dx/2 xmin-dx/2];
    y = [ymin-dy/2 ymin-dy/2 ymin+dy/2 ymin+dy/2];
    X=zeros(4,nrows*ncols);
    Y=zeros(4,nrows*ncols);
    col=zeros(4,nrows*ncols);
    count=0;
    for i=1:nrows
    for j=1:ncols
    if ~isnan(M(i,j))
    count=count+1;
    X(:,count)=x+(j-1)*dx;
    Y(:,count)=y+(i-1)*dy;
    col(:,count)=M(i,j);
    end
    end
    end
    X=X(:,1:count);
    Y=Y(:,1:count);
    col=col(:,1:count);
    patch(X,Y,col,'edgecolor','none')
end