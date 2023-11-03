%% ------------------------------------------------------------------------
% 0) Profilaxia do MATLAB
% -------------------------------------------------------------------------
close all;     % Fecha todas as janelas de gr�ficos abertas
fclose all;    % Fecha todos os ponteiros (escrita/leitura)
clear all;     % Limpa todas as vari�veis do workspace
%% ------------------------------------------------------------------------
% 2. Dados iniciais
% -------------------------------------------------------------------------
f             = 60;                 % 1 ciclo tem 60 Hz
fa            = 3840;               % Frequ�ncia de amostragem dos casos de simula��o do ATP
num_ciclo     = fa/f;               % N�mero de amostras por ciclo (valor que pode ser fracion�rio)
Ts            = 1/fa;               % Per�odo de amostragem = Passo de integra��o do Simulink
imprime = 0;

% Dados específicos do grupo
L1020         = 2;   %km 
L2030         = 1.5; %km 
I20           = 250; %corrente de carga na barra 
I30           = 68;  %corrente de carga na barra 

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

%% ------------------------------------------------------------------------
% 3. Dados da simula��o
% -------------------------------------------------------------------------

% TODO - pegar os dados do arquivo CSV (confirmar qual CSV)
% Funções readtable() e csvread() devem funcionar bem
% csv tá em [t, ia, ib, ic] em valores primarios


ABC001_RED3840;
tempo  = sinais(1:end,1);
iaL    = sinais(1:end,2);
ibL    = sinais(1:end,3);
icL    = sinais(1:end,4);
iaR    = sinais(1:end,5);
ibR    = sinais(1:end,6);
icR    = sinais(1:end,7);
% figure(1)
% hold on;
% zoom on;
% grid on;
% plot(tempo,iaL);
% plot(tempo,ibL);
% plot(tempo,icL);
% plot(tempo,iaR);
% plot(tempo,ibR);
% plot(tempo,icR);
% legend('IaL', 'IbL', 'IcL', 'IaR', 'IbR', 'IcR');
%% ------------------------------------------------------------------------
% 4. Processamento dos sinais de entrada
% -------------------------------------------------------------------------
% 4.1) Especifica��o do filtro passa-baixa com faixa de passagem de 0 [Hz]
%      a fp e faixa de rejei��o de fs pra frente
% -------------------------------------------------------------------------
fp     = 90;       % Frequencia maxima da banda de passagem, em [Hz]
hc     = (fa/f)/2; % Harmonica que se deseja eliminar
fs     = hc*f;     % Frequencia da banda de rejeicao, em [Hz]
Amax   = 3;        % Atenuacao fora da banda de passagem, [dB]
Amin   = 32;       % Atenuacao fora da banda de passagem, [dB]
% -------------------------------------------------------------------------
% 4.2) Efetua a filtragem dos sinais
% -------------------------------------------------------------------------
% tempo = [0:(1/faorig):((length(sinais(:,1))-1)/faorig)];
iaLf = Filtro_Analogico(0, iaL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
ibLf = Filtro_Analogico(0, ibL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
icLf = Filtro_Analogico(0, icL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
iaRf = Filtro_Analogico(0, iaR, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
ibRf = Filtro_Analogico(0, ibR, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
icRf = Filtro_Analogico(0, icR, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
% figure(1)
% hold on;
% zoom on;
% grid on;
% plot(tempo,iaL);
% plot(tempo,iaLf);
% legend('Normal','Filtrado');
% -------------------------------------------------------------------------
% 4.3) Filtro da componente aperiodica sintonizado em R/L do sistema
% -------------------------------------------------------------------------
Z1     = 0.045 + 1i*0.450;
Z0     = 0.150 + 1i*1.500;
alfaf  = real((1/3)*(2*Z1+Z0))/(imag((1/3)*(2*Z1+Z0))/(2*pi*f));
iaLfa = Filtra_Aperiodica(alfaf, iaLf, fa, num_ciclo)';
ibLfa = Filtra_Aperiodica(alfaf, ibLf, fa, num_ciclo)';
icLfa = Filtra_Aperiodica(alfaf, icLf, fa, num_ciclo)';
iaRfa = Filtra_Aperiodica(alfaf, iaRf, fa, num_ciclo)';
ibRfa = Filtra_Aperiodica(alfaf, ibRf, fa, num_ciclo)';
icRfa = Filtra_Aperiodica(alfaf, icRf, fa, num_ciclo)';
figure(1)
hold on;
zoom on;
grid on;
plot(tempo,iaL);
plot(tempo,iaLf);
plot(tempo,iaLfa);
legend('Normal','Filtrado PB', 'PB+Aperiodica');
%% ------------------------------------------------------------------------
% 5) C�lculo da prote��o de dist�ncia
% -------------------------------------------------------------------------

% ir varrendo os dados e implementar um buffer circular
% montar os vetores de correntes para calculo de fourier 
% (https://drive.google.com/file/d/1gqpuzEJbBnoEcdpN-3Jhix25CniElQAo/view - 19:54)
% olhar também 1:10:00 para relatório - entender onde ocorreu o defeito


%% ------------------------------------------------------------------------
% 8) Impress�o dos c�lculos feitos pelos dois rel�s:
% -------------------------------------------------------------------------
if imprime
    figure(1)
    subplot(3,1,1)
    hold on;
    zoom on;
    grid on;
    plot(tempo2,vaa);
    plot(tempo2,va_fan);
    plot(tempo,van);
    title('Tens�o na fase A - V_a');
    legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
    subplot(3,1,2)
    hold on;
    zoom on;
    grid on;
    plot(tempo2,vbb);
    plot(tempo2,vb_fan);
    plot(tempo,vbn);
    title('Tens�o na fase B - V_b');
    legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
    subplot(3,1,3)
    hold on;
    zoom on;
    grid on;
    plot(tempo2,vcc);
    plot(tempo2,vc_fan);
    plot(tempo,vcn);
    title('Tens�o na fase C - V_c');
    legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');

    figure(2)
    subplot(3,1,1)
	hold on;
	zoom on;
	grid on;
	plot(tempo2,iaa);
	plot(tempo2,ia_fan);
	plot(tempo,ia);
	title('Corrente na fase A - I_a');
	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
	subplot(3,1,2)
	hold on;
	zoom on;
	grid on;
	plot(tempo2,ibb);
	plot(tempo2,ib_fan);
	plot(tempo,ib);
	title('Corrente na fase B - I_b');
	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
	subplot(3,1,3)
	hold on;
	zoom on;
	grid on;
	plot(tempo2,icc);
	plot(tempo2,ic_fan);
	plot(tempo,ic);
	title('Corrente na fase C - I_c');
	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');

    figure(3)
	subplot(2,1,1)
	hold on;
	zoom on;
	grid on;
	plot(tempo2,vaa);
	plot(tempo2,vbb);
	plot(tempo2,vcc);
	string1 = strcat('Tens�es - Caso  ',CasoSimulado);
	title(string1);
	legend('Va','Vb', 'Vc');
	subplot(2,1,2)
	hold on;
	zoom on;
	grid on;
	plot(tempo2,iaa);
	plot(tempo2,ibb);
	plot(tempo2,icc);
	string2 = strcat('Correntes - Caso  ',CasoSimulado);
	title(string2);
	legend('Ia','Ib', 'Ic');

    figure(4)   % Unidades de Neutro
    % Unidade AN
    subplot(3,1,1)
    hold on;
    zoom on;
    grid on;
    % axis equal;
    plot(tempo,RanF);
    plot(tempo,RanDT);
    plot(tempo,XanF);
    plot(tempo,XanDT);
    % axis([0 250 -1e2 1e2])
    string3 = strcat('Resist�ncia Ran - Caso  ',CasoSimulado);
    title(string3);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    % Unidade BN
    subplot(3,1,2)
    hold on;
    zoom on;
    grid on;
    plot(tempo,RbnF);
    plot(tempo,RbnDT);
    plot(tempo,XbnF);
    plot(tempo,XbnDT);
    string4 = strcat('Resist�ncia Rbn - Caso  ',CasoSimulado);
    title(string4);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    % Unidade CN
    subplot(3,1,3)
    hold on;
    zoom on;
    grid on;
    plot(tempo,RcnF);
    plot(tempo,RcnDT);
    plot(tempo,XcnF);
    plot(tempo,XcnDT);
    string5 = strcat('Resist�ncia Rcn - Caso  ',CasoSimulado);
    title(string5);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')


    figure(5)   % Unidades de Fase
    % Unidade AB
    subplot(3,1,1)
    hold on;
    zoom on;
    grid on;
    % axis equal;
    plot(tempo,RabF);
    plot(tempo,RabDT);
    plot(tempo,XabF);
    plot(tempo,XabDT);
    % axis([0 250 -1e2 1e2])
    string6 = strcat('Resist�ncia Rab - Caso  ',CasoSimulado);
    title(string6);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    % Unidade BC
    subplot(3,1,2)
    hold on;
    zoom on;
    grid on;
    plot(tempo,RbcF);
    plot(tempo,RbcDT);
    plot(tempo,XbcF);
    plot(tempo,XbcDT);
    string7 = strcat('Resist�ncia Rbc - Caso  ',CasoSimulado);
    title(string7);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    % Unidade CA
    subplot(3,1,3)
    hold on;
    zoom on;
    grid on;
    plot(tempo,RcaF);
    plot(tempo,RcaDT);
    plot(tempo,XcaF);
    plot(tempo,XcaDT);
    string8 = strcat('Resist�ncia Rca - Caso  ',CasoSimulado);
    title(string8);
    legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    
    figure(6)
    hold on;
    grid on;
    axis equal;
    title('Elemento AN');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RanF(num_ciclo_int+1:end),  XanF(num_ciclo_int+1:end),'--c')
    plot(RanDT(num_ciclo_int+1:end), XanDT(num_ciclo_int+1:end),'-.k')
    plot(RanF(end),  XanF(end),'*c')
    plot(RanDT(end), XanDT(end),'*k')
    plot([0 elemen(num_elem,02).Ran],[0 elemen(num_elem,03).Xan], '--y')
    
    figure(7)
    hold on;
    grid on;
    axis equal;
    title('Elemento BN');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RbnF(num_ciclo_int+1:end),  XbnF(num_ciclo_int+1:end),'--c')
    plot(RbnDT(num_ciclo_int+1:end), XbnDT(num_ciclo_int+1:end),'-.k')
    plot(RbnF(end),  XbnF(end),'*c')
    plot(RbnDT(end), XbnDT(end),'*k')
    plot([0 elemen(num_elem,04).Rbn],[0 elemen(num_elem,05).Xbn], '--y')
    
    figure(8)
    hold on;
    grid on;
    axis equal;
    title('Elemento CN');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RcnF(num_ciclo_int+1:end),  XcnF(num_ciclo_int+1:end),'--c')
    plot(RcnDT(num_ciclo_int+1:end), XcnDT(num_ciclo_int+1:end),'-.k')
    plot(RcnF(end),  XcnF(end),'*c')
    plot(RcnDT(end), XcnDT(end),'*k')
    plot([0 elemen(num_elem,06).Rcn],[0 elemen(num_elem,07).Xcn], '--y')
    
    figure(9)
    hold on;
    grid on;
    axis equal;
    title('Elemento AB');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RabF(num_ciclo_int+1:end),  XabF(num_ciclo_int+1:end),'--c')
    plot(RabDT(num_ciclo_int+1:end), XabDT(num_ciclo_int+1:end),'-.k')
    plot(RabF(end),  XabF(end),'*c')
    plot(RabDT(end), XabDT(end),'*k')
    plot([0 elemen(num_elem,08).Rab],[0 elemen(num_elem,09).Xab], '--y')
    
    figure(10)
    hold on;
    grid on;
    axis equal;
    title('Elemento BC');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RbcF(num_ciclo_int+1:end),  XbcF(num_ciclo_int+1:end),'--c')
    plot(RbcDT(num_ciclo_int+1:end), XbcDT(num_ciclo_int+1:end),'-.k')
    plot(RbcF(end),  XbcF(end),'*c')
    plot(RbcDT(end), XbcDT(end),'*k')
    plot([0 elemen(num_elem,10).Rbc],[0 elemen(num_elem,11).Xbc], '--y')
    
    figure(11)
    hold on;
    grid on;
    axis equal;
    title('Elemento CA');
    plot(Rzona1F, Xzona1F, 'b');
    plot(Rzona2F, Xzona2F, 'g');
    plot(Rzona3F, Xzona3F, 'm');
    plot(RzonarF, XzonarF, 'b');
    plot(RcaF(num_ciclo_int+1:end),  XcaF(num_ciclo_int+1:end),'--c')
    plot(RcaDT(num_ciclo_int+1:end), XcaDT(num_ciclo_int+1:end),'-.k')
    plot(RcaF(end),  XcaF(end),'*c')
    plot(RcaDT(end), XcaDT(end),'*k')
    plot([0 elemen(num_elem,12).Rca],[0 elemen(num_elem,13).Xca], '--y')
   
end