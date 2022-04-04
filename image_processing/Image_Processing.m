% % % % % % % % load Frequency % % % % % % % % % % % % % 

load IFFT_Without.txt
load reavectumhfss.txt
load imavectumhfss.txt
load resanstumhfss.txt
load imsanstumhfss.txt
load reavectumhfss1.txt
load imavectumhfss1.txt
load resanstumhfss1.txt
load imsanstumhfss1.txt


%%%%%%%%%%%%%%%%%%%%%%%%%%Save avec tum %%%%%%%%%%%%%%%%%%%%%%%%%%%
Freq=imavectumhfss(:,1);

IMT1=imavectumhfss(:,2);
IMT2=imavectumhfss(:,3);
IMT3=imavectumhfss1(:,2);
IMT4=imavectumhfss(:,4);
IMT5=imavectumhfss(:,5);

% % % % % % % % % % % % % % % % % % % % % % % % % % % RE
RET1=reavectumhfss(:,2);
RET2=reavectumhfss(:,3);
RET3=reavectumhfss1(:,2);
RET4=reavectumhfss(:,4);
RET5=reavectumhfss(:,5);

% % % % % % % % % % %%sans tum
% % % % % % % img
IMNT1=imsanstumhfss(:,2);
IMNT2=imsanstumhfss(:,3);
IMNT3=imsanstumhfss1(:,2);
IMNT4=imsanstumhfss(:,4);
IMNT5=imsanstumhfss(:,5);

% % % % % % % re
RENT1=resanstumhfss(:,2);
RENT2=resanstumhfss(:,3);
RENT3=resanstumhfss1(:,2);
RENT4=resanstumhfss(:,4);
RENT5=resanstumhfss(:,5);

% % % % % % % % % % % % % % % % % % % % % % % % % % 
T1=(RET1+j*IMT1);
T2=(RET2+j*IMT2);
T3=(RET3+j*IMT3);
T4=(RET4+j*IMT4);
T5=(RET5+j*IMT5);

% % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % 
NT1=(RENT1+j*IMNT1);
NT2=(RENT2+j*IMNT2);
NT3=(RENT3+j*IMNT3);
NT4=(RENT4+j*IMNT4);
NT5=(RENT5+j*IMNT5);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % Les matrices : Avec et sans tumeurs % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % Intégrer les signaux enregistrés à chaque point en présence
%%%d'une tumeur % % % % % % % % % % % % % % % 




With=[T1 T2 T3 T4 T5];
Without=[NT1 NT2 NT3 NT4 NT5];


% % % % % % % % Application de la fenetre de Hamming % % % % % % % % % % 


rows = 2001; cols =5;
Window=hamming(2001);
Without_window= zeros(rows,cols);
With_window= zeros(rows,cols);
for k = 1:cols
    Without_window(:,k) = Without(:,k).*Window;
    With_window(:,k) = With(:,k).*Window;
end
TimeResolution = (rows-1)/(max(Freq) - min(Freq));
SampleSize = TimeResolution/(rows-1);

Time = linspace(-(rows-1)/2*SampleSize,(rows-1)/2*SampleSize,2001);

% % % %  Transformation des données du fréquentiel au temporel  % % % % %

IFFT_Without= ifftshift (ifft(Without_window));
IFFT_With = ifftshift(ifft(With_window));

% % % % % % % % CALIBRATION % % % % % % % % % %

Calibrated_With = (IFFT_With - IFFT_Without);

% % % % % % % % Suppression du bruit % % % % % % % % % % 


Average = zeros(rows,5);
l = 1;
for k = 1:cols
    Average(:,l)= Average(:,l) + Calibrated_With(:,k);
  if (rem(k,5)==0)
     l = l+1;
  end
end
Average = Average./5;
New_With = zeros(rows,cols);
l = 1;
for k = 1:cols
    New_With(:,k) = Calibrated_With(:,k) - Average(:,l);
   if(rem(k,5)==0)
     l=l+1;
   end
end

RemovedSignal = angle((New_With));

% % % % DISTANCE DE L'EMPLACEMENT D'ANTENNE DE CHAQUE POINT FOCAL % % % % %

[a,b] = meshgrid(linspace(0,10,5),linspace(0,10,5));
AntennaDistance = 1;
AntennaLocations_x = b(:)';
AntennaLocations_y = a(:)';
MAX = 256;
[X,Y]=meshgrid(linspace(-25,25,MAX),linspace(-25,25,MAX));%-10:0.1:20);
X=X(:);
Y=Y(:);
Distance = zeros(length(X),cols);

for k = 1:cols
    for m = 1:length(X)
      D1 = sqrt((AntennaLocations_x(k) - X(m) )^2 + (AntennaLocations_y(k) - Y(m) )^2);
      Distance(m,k) = sqrt(D1^2 + AntennaDistance^2);
    end 
end

% % VALEURS TEMPORELLES POUR LA DISTANCE D'ANTENNE DE CHAQUE POINT FOCAL% %

Er = 1;
vdelt = 3e10/sqrt(Er);
TmR=zeros(length(X),cols);
for k=1:cols
   for l=1:length(X)
       TmR(l,k)=2*Distance(l,k)/vdelt ;
   end
end

% % % % % % % % INTERPOLATION % % % % % % % % % %

InterpolatedData = zeros(length(TmR),cols);
for k = 1:cols
    InterpolatedData(:,k) = interp1(Time,RemovedSignal(:,k),TmR(:,k),'spline');
end


IntensityValues=zeros(length(InterpolatedData),1,'double');
for i=1:length(InterpolatedData)
    IntensityValues(i)=sum(InterpolatedData(i,:));
end
IntensityValues=IntensityValues./max(IntensityValues);
Intensity=IntensityValues.^4;



figure;
%Intensite=corrcoef(Intensity);
scatter(X,Y,500,Intensity,'.');
%imagesc(X,Y,Intensite);
axis([min(X) 22 min(Y) max(Y)]); 
