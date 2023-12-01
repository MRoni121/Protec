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

% parâmetros da função
curve_family = 'iec'; %iec ||ieee
curve_type = 'A'; % ext_inv || mui_inv || mod_inv || short_inv || A || B || C
ipk = 3000;
mt = 0.15;
ifasor = 3;

%% ------------------------------------------------------------------------
% 3. Dados da simula��o
% -------------------------------------------------------------------------

% Transformando cada arquivo csv em matriz

sinais_1_10 = csvread('A1rele10.csv');
sinais_1_20 = csvread('A1rele20.csv');
sinais_1_30 = csvread('A1rele30.csv');
sinais_2_10 = csvread('A2rele10.csv');
sinais_2_20 = csvread('A2rele20.csv');
sinais_2_30 = csvread('A2rele30.csv');

% Criando os vetores de tempo e corrente

tempo = sinais_1_20(1:end, 1);
Ia_1_10 = sinais_1_10(1:end, 2);
Ib_1_10 = sinais_1_10(1:end, 3);
Ic_1_10 = sinais_1_10(1:end, 4);
Ia_1_20 = sinais_1_20(1:end, 2);
Ib_1_20 = sinais_1_20(1:end, 3);
Ic_1_20 = sinais_1_20(1:end, 4);
Ia_1_30 = sinais_1_30(1:end, 2);
Ib_1_30 = sinais_1_30(1:end, 3);
Ic_1_30 = sinais_1_30(1:end, 4);
Ia_2_10 = sinais_2_10(1:end, 2);
Ib_2_10 = sinais_2_10(1:end, 3);
Ic_2_10 = sinais_2_10(1:end, 4);
Ia_2_20 = sinais_2_20(1:end, 2);
Ib_2_20 = sinais_2_20(1:end, 3);
Ic_2_20 = sinais_2_20(1:end, 4);
Ia_2_30 = sinais_2_30(1:end, 2);
Ib_2_30 = sinais_2_30(1:end, 3);
Ic_2_30 = sinais_2_30(1:end, 4);

for k = 1:length(tempo)
  tempo(k) = (k-1)*Ts;
end


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


Ia_1_10_f = Filtro_Analogico(1, Ia_1_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_1_10_f = Filtro_Analogico(1, Ib_1_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_1_10_f = Filtro_Analogico(1, Ic_1_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_1_20_f = Filtro_Analogico(1, Ia_1_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_1_20_f = Filtro_Analogico(1, Ib_1_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_1_20_f = Filtro_Analogico(1, Ic_1_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_1_30_f = Filtro_Analogico(1, Ia_1_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_1_30_f = Filtro_Analogico(1, Ib_1_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_1_30_f = Filtro_Analogico(1, Ic_1_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_2_10_f = Filtro_Analogico(1, Ia_2_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_2_10_f = Filtro_Analogico(1, Ib_2_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_2_10_f = Filtro_Analogico(1, Ic_2_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_2_20_f = Filtro_Analogico(1, Ia_2_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_2_20_f = Filtro_Analogico(1, Ib_2_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_2_20_f = Filtro_Analogico(1, Ic_2_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_2_30_f = Filtro_Analogico(1, Ia_2_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_2_30_f = Filtro_Analogico(1, Ib_2_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_2_30_f = Filtro_Analogico(1, Ic_2_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);

% figure(1)
% hold on;
% zoom on;
% grid on;
% plot(tempo,Ia_1_10);
% plot(tempo,Ia_1_10_f);
% legend('Normal','Filtrado');


% hold on;
% zoom on;
% grid on;
% plot(tempo,Ia_2_30);
% plot(tempo,Ib_2_30);
% plot(tempo,Ic_2_30);
% legend('iA','iB', 'iC');

%% ------------------------------------------------------------------------
% 5) Calculo da protecao de distancia
% -------------------------------------------------------------------------

% ir varrendo os dados e implementar um buffer circular
% montar os vetores de correntes para calculo de fourier 
% (https://drive.google.com/file/d/1gqpuzEJbBnoEcdpN-3Jhix25CniElQAo/view - 19:54)
% olhar também 1:10:00 para relatório - entender onde ocorreu o defeito

% close all;
% clear all;
%

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                   % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                     % Ponteiro que é atualizado a cada posição de leitura
ia_dig = zeros(1, tam_buffer); % Buffer que armazena a referência o sinal de corrente ia da barra 10 digitalizado
ib_dig = zeros(1, tam_buffer); % Buffer que armazena a referência o sinal de corrente ib da barra 10 digitalizado
ic_dig = zeros(1, tam_buffer); % Buffer que armazena a referência o sinal de corrente ic da barra 10 digitalizado
tempo_lido  = zeros(1, tam_buffer); % Buffer que armazena a referência de tempo
corren_nova = zeros(1, tam_buffer); % Buffer que armazena a referência o sinal de corrente digitalizado e filtrado
tempo_novo  = zeros(1, tam_buffer); % Buffer que armazena a referência de tempo


% %
% % 2) Loop infinito
% %
aux = 1;

timer = 0;
tempo_pro_trip = -1;

instante_do_trip = 0;
instante_de_percepcao = 0;
tempo_pro_trip_estimado = 0;

ia_fasores = zeros(1, length(tempo));
ib_fasores = zeros(1, length(tempo));
ic_fasores = zeros(1, length(tempo));
Ia_super_fasores = zeros(1, length(tempo));

% % 5.1.2) Leitura dos ADs
while aux<length(tempo)

%     % 5.1.3) Atualização dos buffers circulares
    ia_dig(ponteiro_b) = Ia_1_10_f(aux);
    ib_dig(ponteiro_b) = Ib_1_10_f(aux);
    ic_dig(ponteiro_b) = Ic_1_10_f(aux);
    tempo_lido(ponteiro_b)  = tempo(aux);       % Atualização do buffer de tempo


% faz fourier

    ia_ordenada = [ia_dig(ponteiro_b:tam_buffer) ia_dig(1:ponteiro_b-1)];
    ib_ordenada = [ib_dig(ponteiro_b:tam_buffer) ib_dig(1:ponteiro_b-1)];
    ic_ordenada = [ic_dig(ponteiro_b:tam_buffer) ic_dig(1:ponteiro_b-1)];

    ia_fasores(aux) = fourier(ia_ordenada, tam_buffer, fa, f).magnitude;
    ib_fasores(aux) = fourier(ib_ordenada, tam_buffer, fa, f).magnitude;
    ic_fasores(aux) = fourier(ic_ordenada, tam_buffer, fa, f).magnitude;

    Ia_super_fasores(aux) = fourier(Ia_1_10_f, aux, fa, f).magnitude;


% chama Protecao
    array_tempos = [Protecao(curve_family, curve_type, ipk, mt, ia_fasores(aux)) Protecao(curve_family, curve_type, ipk, mt, ib_fasores(aux)) Protecao(curve_family, curve_type, ipk, mt, ic_fasores(aux))];
    tempo_pro_trip = min(array_tempos(array_tempos > 0));
   

    if(tempo_pro_trip > 0) 
        
        if(instante_de_percepcao == 0)
            instante_de_percepcao = tempo(aux);
        end
        
        if(timer > tempo_pro_trip)
            instante_do_trip = tempo(aux);
            tempo_pro_trip_estimado = tempo_pro_trip;
            break;
        end

        timer = timer + Ts;

    else
        timer = max([0 timer-Ts]);
    end


    ponteiro_b = ponteiro_b + 1;   % Atualização do ponteiro dos buffers

    if ponteiro_b>tam_buffer
        ponteiro_b = 1;
    end
    
   
    %
    % 2.4) Funçoes de proteção
    %
    aux = aux + 1;
end

figure(1)
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10_f);
% plot(tempo,ia_fasores);
plot(tempo,Ia_super_fasores);
legend('sinal', 'fourier grandao');



% %% ------------------------------------------------------------------------
% % 8) Impress�o dos c�lculos feitos pelos dois rel�s:
% % -------------------------------------------------------------------------
% if imprime
%     figure(1)
%     subplot(3,1,1)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo2,vaa);
%     plot(tempo2,va_fan);
%     plot(tempo,van);
%     title('Tens�o na fase A - V_a');
%     legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
%     subplot(3,1,2)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo2,vbb);
%     plot(tempo2,vb_fan);
%     plot(tempo,vbn);
%     title('Tens�o na fase B - V_b');
%     legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
%     subplot(3,1,3)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo2,vcc);
%     plot(tempo2,vc_fan);
%     plot(tempo,vcn);
%     title('Tens�o na fase C - V_c');
%     legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');

%     figure(2)
%     subplot(3,1,1)
% 	hold on;
% 	zoom on;
% 	grid on;
% 	plot(tempo2,iaa);
% 	plot(tempo2,ia_fan);
% 	plot(tempo,ia);
% 	title('Corrente na fase A - I_a');
% 	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
% 	subplot(3,1,2)
% 	hold on;
% 	zoom on;
% 	grid on;
% 	plot(tempo2,ibb);
% 	plot(tempo2,ib_fan);
% 	plot(tempo,ib);
% 	title('Corrente na fase B - I_b');
% 	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');
% 	subplot(3,1,3)
% 	hold on;
% 	zoom on;
% 	grid on;
% 	plot(tempo2,icc);
% 	plot(tempo2,ic_fan);
% 	plot(tempo,ic);
% 	title('Corrente na fase C - I_c');
% 	legend('Sinal puro','Filtro_{An}', 'Filtro_{An+Ap}');

%     figure(3)
% 	subplot(2,1,1)
% 	hold on;
% 	zoom on;
% 	grid on;
% 	plot(tempo2,vaa);
% 	plot(tempo2,vbb);
% 	plot(tempo2,vcc);
% 	string1 = strcat('Tens�es - Caso  ',CasoSimulado);
% 	title(string1);
% 	legend('Va','Vb', 'Vc');
% 	subplot(2,1,2)
% 	hold on;
% 	zoom on;
% 	grid on;
% 	plot(tempo2,iaa);
% 	plot(tempo2,ibb);
% 	plot(tempo2,icc);
% 	string2 = strcat('Correntes - Caso  ',CasoSimulado);
% 	title(string2);
% 	legend('Ia','Ib', 'Ic');

%     figure(4)   % Unidades de Neutro
%     % Unidade AN
%     subplot(3,1,1)
%     hold on;
%     zoom on;
%     grid on;
%     % axis equal;
%     plot(tempo,RanF);
%     plot(tempo,RanDT);
%     plot(tempo,XanF);
%     plot(tempo,XanDT);
%     % axis([0 250 -1e2 1e2])
%     string3 = strcat('Resist�ncia Ran - Caso  ',CasoSimulado);
%     title(string3);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
%     % Unidade BN
%     subplot(3,1,2)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo,RbnF);
%     plot(tempo,RbnDT);
%     plot(tempo,XbnF);
%     plot(tempo,XbnDT);
%     string4 = strcat('Resist�ncia Rbn - Caso  ',CasoSimulado);
%     title(string4);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
%     % Unidade CN
%     subplot(3,1,3)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo,RcnF);
%     plot(tempo,RcnDT);
%     plot(tempo,XcnF);
%     plot(tempo,XcnDT);
%     string5 = strcat('Resist�ncia Rcn - Caso  ',CasoSimulado);
%     title(string5);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')


%     figure(5)   % Unidades de Fase
%     % Unidade AB
%     subplot(3,1,1)
%     hold on;
%     zoom on;
%     grid on;
%     % axis equal;
%     plot(tempo,RabF);
%     plot(tempo,RabDT);
%     plot(tempo,XabF);
%     plot(tempo,XabDT);
%     % axis([0 250 -1e2 1e2])
%     string6 = strcat('Resist�ncia Rab - Caso  ',CasoSimulado);
%     title(string6);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
%     % Unidade BC
%     subplot(3,1,2)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo,RbcF);
%     plot(tempo,RbcDT);
%     plot(tempo,XbcF);
%     plot(tempo,XbcDT);
%     string7 = strcat('Resist�ncia Rbc - Caso  ',CasoSimulado);
%     title(string7);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
%     % Unidade CA
%     subplot(3,1,3)
%     hold on;
%     zoom on;
%     grid on;
%     plot(tempo,RcaF);
%     plot(tempo,RcaDT);
%     plot(tempo,XcaF);
%     plot(tempo,XcaDT);
%     string8 = strcat('Resist�ncia Rca - Caso  ',CasoSimulado);
%     title(string8);
%     legend('R Fourier', 'R DT', 'X Fourier', 'X DT')
    
%     figure(6)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento AN');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RanF(num_ciclo_int+1:end),  XanF(num_ciclo_int+1:end),'--c')
%     plot(RanDT(num_ciclo_int+1:end), XanDT(num_ciclo_int+1:end),'-.k')
%     plot(RanF(end),  XanF(end),'*c')
%     plot(RanDT(end), XanDT(end),'*k')
%     plot([0 elemen(num_elem,02).Ran],[0 elemen(num_elem,03).Xan], '--y')
    
%     figure(7)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento BN');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RbnF(num_ciclo_int+1:end),  XbnF(num_ciclo_int+1:end),'--c')
%     plot(RbnDT(num_ciclo_int+1:end), XbnDT(num_ciclo_int+1:end),'-.k')
%     plot(RbnF(end),  XbnF(end),'*c')
%     plot(RbnDT(end), XbnDT(end),'*k')
%     plot([0 elemen(num_elem,04).Rbn],[0 elemen(num_elem,05).Xbn], '--y')
    
%     figure(8)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento CN');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RcnF(num_ciclo_int+1:end),  XcnF(num_ciclo_int+1:end),'--c')
%     plot(RcnDT(num_ciclo_int+1:end), XcnDT(num_ciclo_int+1:end),'-.k')
%     plot(RcnF(end),  XcnF(end),'*c')
%     plot(RcnDT(end), XcnDT(end),'*k')
%     plot([0 elemen(num_elem,06).Rcn],[0 elemen(num_elem,07).Xcn], '--y')
    
%     figure(9)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento AB');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RabF(num_ciclo_int+1:end),  XabF(num_ciclo_int+1:end),'--c')
%     plot(RabDT(num_ciclo_int+1:end), XabDT(num_ciclo_int+1:end),'-.k')
%     plot(RabF(end),  XabF(end),'*c')
%     plot(RabDT(end), XabDT(end),'*k')
%     plot([0 elemen(num_elem,08).Rab],[0 elemen(num_elem,09).Xab], '--y')
    
%     figure(10)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento BC');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RbcF(num_ciclo_int+1:end),  XbcF(num_ciclo_int+1:end),'--c')
%     plot(RbcDT(num_ciclo_int+1:end), XbcDT(num_ciclo_int+1:end),'-.k')
%     plot(RbcF(end),  XbcF(end),'*c')
%     plot(RbcDT(end), XbcDT(end),'*k')
%     plot([0 elemen(num_elem,10).Rbc],[0 elemen(num_elem,11).Xbc], '--y')
    
%     figure(11)
%     hold on;
%     grid on;
%     axis equal;
%     title('Elemento CA');
%     plot(Rzona1F, Xzona1F, 'b');
%     plot(Rzona2F, Xzona2F, 'g');
%     plot(Rzona3F, Xzona3F, 'm');
%     plot(RzonarF, XzonarF, 'b');
%     plot(RcaF(num_ciclo_int+1:end),  XcaF(num_ciclo_int+1:end),'--c')
%     plot(RcaDT(num_ciclo_int+1:end), XcaDT(num_ciclo_int+1:end),'-.k')
%     plot(RcaF(end),  XcaF(end),'*c')
%     plot(RcaDT(end), XcaDT(end),'*k')
%     plot([0 elemen(num_elem,12).Rca],[0 elemen(num_elem,13).Xca], '--y')
   
% end

