function PLI = phaselagindex(data)
% compute the phase lag index for data

N = size(data,2);
cut = 2; % cut points from hilbert transform
PLI = zeros(N,N);
for i = 1: N
    for j = 1: N
    if i<j
    
    % data
    x = data(:,i);
    y = data(:,j);

    % step 1, compute the hilbert transform and bring him to the origin
    htx=hilbert(x);
    htx([1:cut,end-cut+1:end],:)=[];
    htx = bsxfun(@minus,htx,mean(htx,1));
    hty=hilbert(y);
    hty([1:cut,end-cut+1:end],:)=[];
    hty = bsxfun(@minus,hty,mean(hty,1));
      
    % step 2, compute the instantenous phase
    thetax=angle(htx);
    thetay=angle(hty);

    % step 3, phase difference between -pi and pi
    dtheta=mod(thetax-thetay,2*pi)-pi;         

    % step 4, is this greater or smaller than zero?
    dtheta=sign(sin(dtheta));

    % step 5, is there on average a phase lag or lead
    PLI(i,j)=abs(mean(dtheta));
    end
    end
end

PLI = (PLI + PLI')/2;

end