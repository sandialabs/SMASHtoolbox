% hidden method
function object=createWindow(object,name,parameter)

assert(ischar(name),'ERROR: invalid window name');
name=lower(name);

switch name
    case 'boxcar'
        local=@(t) ones(size(t));
        object.Name='Boxcar';
    case 'blackman'
        local=@(t) 0.42+0.5*cos(2*pi*t)+0.08*cos(4*pi*t);
        object.Name='Blackman';
    case 'bspline'
        if isempty(parameter)
            order=3;
        else
            order=parameter;
            assert(isnumeric(order) && isscalar(order) && any(order == 3:5),...
                'ERROR: order must be 3, 4, or 5');
        end
        local=@(t) bspline(t,order);
        object.Name=sprintf('B-spline (order %d)',order);
    case 'connes'
        local=@(t) (1-4*t.^2).^2;
        object.Name='Connes';
    case 'flattop'   
        if isempty(parameter)
            order=3;
        else
            order=parameter;
            assert(isnumeric(order) && isscalar(order) && any(order == [3 5]),...
                'ERROR: order must be 3 or 5');
        end
        local=@(t) flattop(t,order);
        object.Name=sprintf('Flat top (order %d)',order);
    case 'hann'
        %local=@(t) 0.50+0.50*cospi(2*t);
        local=@(t) 0.50+0.50*cos(2*pi*t);
        object.Name='Hann';
    case 'kaiser'
        if isempty(parameter)
            beta=16;
        else
            beta=parameter(1);
            assert(isnumeric(beta) && isscalar(beta) && (beta >= 1),...
                'ERROR: beta must be >= 1');
        end
        local=@(t) kaiser(t,beta);
        object.Name=sprintf('Kaiser (\\beta = %g)',beta);
    case 'pcosine'
        if isempty(parameter)
            order=2;
        else
            order=parameter(1);
            assert(isnumeric(order) && isscalar(order) && (order >= 1),...
                'ERROR: order must be greater than or equal to 1');
        end
        local=@(t) cos(pi*t).^order;
        object.Name=sprintf('P-cosine (order %d)',order);
    case 'psinc'
        if isempty(parameter)
            order=2;
        else
            order=parameter;
            assert(isnumeric(order) && isscalar(order) && (order >= 1),...
                'ERROR: order must be greater than or equal to 1');
        end
        local=@(t) psinc(t,order);
        object.Name=sprintf('P-sinc (order %d)',order);
    case 'singla'
        if isempty(parameter)
            order=1;
        else
            order=parameter;
            assert(isnumeric(order) && isscalar(order) && any(order == [1 2]),...
                'ERROR: order must be 1 or 2');
        end
        local=@(t) singla(t,order);
        object.Name=sprintf('Singla (order %d)',order);
    case 'triangle'
        if isempty(parameter)
            order=1;
        else
            order=parameter;
            assert(isnumeric(order) && isscalar(order) && (order >= 1),...
                'ERROR: order must be >= 1 ');
        end
        local=@(t) (1-2*abs(t)).^order;
        object.Name=sprintf('Triangle (order %d)',order);
    case 'tukey'        
        if isempty(parameter)
            beta=0.5;
        else
            beta=parameter;
            assert(isnumeric(beta) && isscalar(beta) && (beta > 0) && (beta < 1),...
                'ERROR: alpha must be greater than 0 and less than 1');                       
        end
        local=@(t) tukey(t,beta);     
        object.Name=sprintf('Tukey (alpha %d)',beta);
    case 'vorbis'
        local=@(t) sin(pi/2*cos(pi*t).^2);
        object.Name='Vorbis';
    otherwise
        error('ERROR: unrecognized window name');
end
object.Function=local;

end

%% advanced window functions

function out=flattop(t,order)

switch order  
    case 3
        a=[0.2811 0.5209 0.1980];
    case 5
        a=[0.21557895 0.41663158 0.277263158 0.083578947 0.006947368];
end

out=zeros(size(t));
for k=0:(order-1)
    out=out+a(k+1)*cos(2*pi*k*t);
end
out=out/sum(a);

end

function out=bspline(t,order)

out=ones(size(t));
switch order
    case 3
        k=abs(t) <= (1/6);
        out(k)=9/8*(2-24*abs(t(k)).^2);
        k=~k;
        out(k)=(9/8)*(3-12*abs(t(k))+12*abs(t(k)).^2);
        out=out*(4/9);
    case 4 % parzen window
        k=abs(t) < 0.25;
        tk=abs(t(k));
        out(k)=(8/3)*(1-24*tk.^2+48*tk.^3);
        k=~k;
        tk=abs(t(k));
        out(k)=(8/3)*(2-12*tk+24*tk.^2-16*tk.^3);
        out=out*(3/8);
    case 5
        k=abs(t) <= (1/10);
        tk=abs(t(k));
        out(k)=(25/384)*(46-1200*tk.^2+12000*tk.^4);
        k=(abs(t) > (1/10)) & (abs(t) <= (3/10));
        tk=abs(t(k));
        out(k)=(25/384)*(44+80*tk-2400*tk.^2+8000*tk.^3-8000*tk.^4);
        k=(abs(t) > (3/10));
        tk=abs(t(k));
        out(k)=(25/384)*(125-1000*tk+3000*tk.^2-4000*tk.^3+2000*tk.^4);
        out=out*(384/1150);
end

end

function out=kaiser(t,beta)

arg=sqrt(1-4*t.^2);
out=besseli(0,beta*arg)/besseli(0,beta);

end

function out=psinc(t,order)

out=ones(size(t));
threshold=6*eps(class(t));
arg=2*pi*t;
k=(abs(arg) > threshold);
out(k)=sin(arg(k))./arg(k);
out=out.^order;

end

function out=singla(t,order)

t=2*t;
switch order  
    case 1
        out=1-t.^2.*(3-2*abs(t));
    case 2
        out=1-abs(t).^3.*(10-15*abs(t)+6*t.^2);        
end

end

function out=tukey(t,alpha)

out=ones(size(t));
t0=alpha/2;
k=(abs(t) >= t0);
out(k)=(1+cos(pi*(abs(t(k))-t0)/(0.5-t0)))/2;

end