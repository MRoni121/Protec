
% Dados específicos do grupo
L1020         = 2;   %km 
L2030         = 1.5; %km 
I20           = 250; %corrente de carga na barra 
I30           = 68;  %corrente de carga na barra 

ta = Protecao('iec', 'B', 5, 2, 10);

Imax102F = 6000;
Imax103F = 4800;
Imax102FT = 5300;
Imax10FT = 5600;

Imax202F = 4000;
Imax203F = 2900;
Imax202FT = 3600;
Imax20FT = 2950;

Imax302F = 3280;
Imax303F = 2250;
Imax302FT = 2950;
Imax30FT = 3020;

Imin102F = 790;
Imin103F = 785;
Imin102FT = 680;
Imin10FT = 770;

Imin202F = 780;
Imin203F = 760;
Imin202FT = 675;
Imin20FT = 740;

Imin302F = 600;
Imin303F = 580;
Imin302FT = 520;
Imin30FT = 550;

Z1     = 0.045 + 1i*0.450;
Z0     = 0.150 + 1i*1.500;
alfaf  = real((1/3)*(2*Z1+Z0))/(imag((1/3)*(2*Z1+Z0))/(2*pi*f));