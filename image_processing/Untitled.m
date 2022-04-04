% load Frequency
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



T0=reavectumhfss(:,2);
T1=reavectumhfss(:,3);
T2=reavectumhfss1(:,2);
T3=reavectumhfss(:,4);
T4=reavectumhfss(:,5);
T5=imavectumhfss(:,2);
T6=imavectumhfss(:,3);
T7=imavectumhfss1(:,2);
T8=imavectumhfss(:,4);
T9=imavectumhfss(:,5);
% % % % % % % % % % %% Save sans tum %%%%%%%%%%%%%%%%%%%%%%%%%%%

NT0=resanstumhfss(:,2);
NT1=resanstumhfss(:,3);
NT2=resanstumhfss1(:,2);
NT3=resanstumhfss(:,4);
NT4=resanstumhfss(:,5);
NT5=imsanstumhfss(:,2);
NT6=imsanstumhfss(:,3);
NT7=imsanstumhfss1(:,2);
NT8=imsanstumhfss(:,4);
NT9=imsanstumhfss(:,5);
% % % % % Intégrer les signaux enregistrés à chaque point en présence
%%%d'une tumeur % % % % % % % % % % % % % % % 

len = length(T0);
Tumor = zeros(10,1);
for i=1:len
 Tumor(1,1)= Tumor(1,1) + (T0(i));
 Tumor(2,1)= Tumor(2,1) + (T1(i));
 Tumor(3,1)= Tumor(3,1) + (T2(i));
 Tumor(4,1)= Tumor(4,1) + (T3(i));
 Tumor(5,1)= Tumor(5,1) + (T4(i));
 Tumor(6,1)= Tumor(6,1) + (T5(i));
 Tumor(7,1)= Tumor(6,1) + (T6(i));
 Tumor(8,1)= Tumor(6,1) + (T7(i));
 Tumor(9,1)= Tumor(6,1) + (T8(i));
 Tumor(10,1)= Tumor(6,1) + (T9(i));
end

%%%%%% Affecter la valeur du point précédent (dans la direction x négative) 
%%%%%%%% aux points sans données correspondantes
for j=2:length(Tumor)
  if Tumor(j,1) == 0
     Tumor(j,1) = Tumor((j-1),1);
  end
end
Smooth_Tumor = smooth(Tumor);

% % % % % Intégrer les signaux enregistrés à chaque point sans tumeur %%%
lenNT = length(NT0);
NTumor = zeros(10,1);
for i=1:lenNT
 NTumor(1,1)= NTumor(1,1) + (NT0(i));
 NTumor(2,1)= NTumor(2,1) + (NT1(i));
 NTumor(3,1)= NTumor(3,1) + (NT2(i));
 NTumor(4,1)= NTumor(4,1) + (NT3(i));
 NTumor(5,1)= NTumor(5,1) + (NT4(i));
 NTumor(6,1)= NTumor(6,1) + (NT5(i));
 NTumor(7,1)= NTumor(6,1) + (NT6(i));
 NTumor(8,1)= NTumor(6,1) + (NT7(i));
 NTumor(9,1)= NTumor(6,1) + (NT8(i));
 NTumor(10,1)= NTumor(6,1) + (NT9(i));
end
%%%%%% Affecter la valeur du point précédent (dans la direction x négative) 
%%%%%%%% aux points sans données correspondantes %%%%%%%%
for j=2:length(NTumor)
  if NTumor(j,1) == 0
     NTumor(j,1) = NTumor((j-1),1);
  end
end
Smooth_NTumor = smooth(NTumor);
x = linspace(0,9,10);

figure, plot (x, Smooth_Tumor);

figure, plot (x, Smooth_NTumor);

%%%%% Calculez la différence entre les deux résultats d'intégration %%%%

Difference = abs(Smooth_NTumor -Smooth_Tumor);

%%%%%%%

picture = zeros (20,20);
for i=11:20
   for j=1:20
       picture (i,j) = Difference(i-10,1);
    end
end

for i = 1:10
    Difference2(i,1) = Difference ((11-i),1);
end

for i=1:10
  for j=1:20
    picture (i,j) = Difference2(i,1);
  end
end

picture2 = zeros (20,20);

for i=11:20
  for j=1:20
    picture2 (j,i) = Difference(i-11,1);
  end
end

for i=1:10
  for j=1:20
   picture2 (j,i) = Difference2(i,1);
  end
end

Difference1 = [Difference2; Difference];

xd = linspace(-9,9,20);
figure, plot (xd, Difference1);
title '6mm Tumor: Tumor Signature as a funtion of x position';
grid minor;

x1 = linspace(-9,9,20);
picture3 = picture*picture2;
figure, imagesc(x1, x1, picture3);
title '6mm Tumor: 2D Image';