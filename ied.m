%% ------------------------------------------------------------------------
% 0) Profilaxia do MATLAB
% -------------------------------------------------------------------------
close all;     % Fecha todas as janelas de graficos abertas
fclose all;    % Fecha todos os ponteiros (escrita/leitura)
clear all;     % Limpa todas as variaveis do workspace
%% ------------------------------------------------------------------------
% 2. Dados iniciais
% -------------------------------------------------------------------------
f             = 60;                 % 1 ciclo tem 60 Hz
fa            = 1920;               % Frequência de amostragem dos casos de simulação do ATP
num_ciclo     = fa/f;               % Número de amostras por ciclo (valor que pode ser fracionário)
Ts            = 1/fa;               % Período de amostragem = Passo de integração do Simulink

% parâmetros da função
curve_family = 'ieee';  %iec ||ieee
curve_type = 'mui_inv'; % ext_inv || mui_inv || mod_inv || short_inv || A || B || C
ipk = 9.48125*80;
mt = 0.2;

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

tempo = sinais_1_10(1:end, 1);
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



%% ------------------------------------------------------------------------
% 4. Processamento dos sinais de entrada
% -------------------------------------------------------------------------
% 4.1) Especificação do filtro passa-baixa com faixa de passagem de 0 [Hz]
%      a fp e faixa de rejeição de fs pra frente
% -------------------------------------------------------------------------
fp     = 90;       % Frequencia maxima da banda de passagem, em [Hz]
hc     = (fa/f)/2; % Harmonica que se deseja eliminar
fs     = hc*f;     % Frequencia da banda de rejeicao, em [Hz]
Amax   = 3;        % Atenuacao fora da banda de passagem, [dB]
Amin   = 32;       % Atenuacao fora da banda de passagem, [dB]
% -------------------------------------------------------------------------
% 4.2) Efetua a filtragem dos sinais
% -------------------------------------------------------------------------

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



%% ------------------------------------------------------------------------
% 5) Calculo da protecao de sobrecorrente
% -------------------------------------------------------------------------

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                   % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                     % Ponteiro que é atualizado a cada posição de leitura
ia_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ia
ib_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ib
ic_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ic
tempo_lido  = zeros(1, tam_buffer); % Buffer que armazena a referência de tempo


aux = 1;

timer_a = 0;
timer_b = 0;
timer_c = 0;
timer_n = 0;
tempo_pro_trip = -1;

instante_do_trip_a = 0;
instante_do_trip_b = 0;
instante_do_trip_c = 0;
instante_do_trip_n = 0;

instante_de_percepcao_a = 0;
instante_de_percepcao_b = 0;
instante_de_percepcao_c = 0;
instante_de_percepcao_n = 0;

tempo_pro_trip_estimado_a = 0;
tempo_pro_trip_estimado_b = 0;
tempo_pro_trip_estimado_c = 0;
tempo_pro_trip_estimado_n = 0;


deveria_atualizar_a = 1;
deveria_atualizar_b = 1;
deveria_atualizar_c = 1;
deveria_atualizar_n = 1;

sinal_trip_a = zeros(1, length(tempo));
sinal_trip_b = zeros(1, length(tempo));
sinal_trip_c = zeros(1, length(tempo));
sinal_trip_n = zeros(1, length(tempo));

ia_fasores = zeros(1, length(tempo));
ib_fasores = zeros(1, length(tempo));
ic_fasores = zeros(1, length(tempo));
in_fasores = zeros(1, length(tempo));

% % 5.2) Leitura dos ADs
while aux<length(tempo)

%   5.2.3) Atualização dos buffers circulares
    ia_dig(ponteiro_b) = Ia_1_10_f(aux);
    ib_dig(ponteiro_b) = Ib_1_10_f(aux);
    ic_dig(ponteiro_b) = Ic_1_10_f(aux);
    tempo_lido(ponteiro_b)  = tempo(aux);  % Atualização do buffer de tempo


%   5.2.4) Cálculo dos fasores
    ia_ordenada = [ia_dig(ponteiro_b:tam_buffer) ia_dig(1:ponteiro_b-1)];
    ib_ordenada = [ib_dig(ponteiro_b:tam_buffer) ib_dig(1:ponteiro_b-1)];
    ic_ordenada = [ic_dig(ponteiro_b:tam_buffer) ic_dig(1:ponteiro_b-1)];
    in_ordenada = ia_ordenada + ib_ordenada + ic_ordenada;

    ia_fasores(aux) = fourier(ia_ordenada, tam_buffer, fa, f).magnitude;
    ib_fasores(aux) = fourier(ib_ordenada, tam_buffer, fa, f).magnitude;
    ic_fasores(aux) = fourier(ic_ordenada, tam_buffer, fa, f).magnitude;
    in_fasores(aux) = fourier(in_ordenada, tam_buffer, fa, f).magnitude;


%   5.2.5) Cálculo dos tempos de atuação
    
    ta_a = Protecao(curve_family, curve_type, ipk, mt, ia_fasores(aux)); 
    ta_b = Protecao(curve_family, curve_type, ipk, mt, ib_fasores(aux));
    ta_c = Protecao(curve_family, curve_type, ipk, mt, ic_fasores(aux));
    ta_n = Protecao(curve_family, curve_type, ipk, mt, in_fasores(aux));
    
    
%   Fase A
    if(ta_a > 0) 
        sinal_trip_a(aux) = 1;
        if(instante_de_percepcao_a == 0)
            instante_de_percepcao_a = tempo(aux);
        end
        
        if(timer_a > ta_a)
            
            if(deveria_atualizar_a)
                instante_do_trip_a = tempo(aux);
                tempo_pro_trip_estimado_a = ta_a;
            end
            
            deveria_atualizar_a = 0;
            
        end

        timer_a = timer_a + Ts;

    else
        timer_a = max([0 timer_a-Ts]);
    end

%   Fase B
    if(ta_b > 0) 
        sinal_trip_b(aux) = 1;
        if(instante_de_percepcao_b == 0)
            instante_de_percepcao_b = tempo(aux);
        end
        
        if(timer_b > ta_b)
            
            if(deveria_atualizar_b)
                instante_do_trip_b = tempo(aux);
                tempo_pro_trip_estimado_b = ta_b;
            end
            
            deveria_atualizar_b = 0;
            
        end

        timer_b = timer_b + Ts;

    else
        timer_b = max([0 timer_b-Ts]);
    end


%   Fase C
    if(ta_c > 0) 
        sinal_trip_c(aux) = 1;
        if(instante_de_percepcao_c == 0)
            instante_de_percepcao_c = tempo(aux);
        end
        
        if(timer_c > ta_c)
            
            if(deveria_atualizar_c)
                instante_do_trip_c = tempo(aux);
                tempo_pro_trip_estimado_c = ta_c;
            end
            
            deveria_atualizar_c = 0;
            
        end

        timer_c = timer_c + Ts;

    else
        timer_c = max([0 timer_c-Ts]);
    end

%   Neutro
    if(ta_n > 0) 
        sinal_trip_n(aux) = 1;
        if(instante_de_percepcao_n == 0)
            instante_de_percepcao_n = tempo(aux);
        end
        
        if(timer_n > ta_n)
            
            if(deveria_atualizar_n)
                instante_do_trip_n = tempo(aux);
                tempo_pro_trip_estimado_n = ta_n;
            end
            
            deveria_atualizar_n = 0;
            
        end

        timer_n = timer_n + Ts;

    else
        timer_n = max([0 timer_n-Ts]);
    end

    ponteiro_b = ponteiro_b + 1;   % Atualização do ponteiro dos buffers

    if ponteiro_b>tam_buffer
        ponteiro_b = 1;
    end
    
    aux = aux + 1;
end

%% ------------------------------------------------------------------------
% 6) Impressões
% -------------------------------------------------------------------------

iNeutro = Ia_1_10 + Ib_1_10 + Ic_1_10;

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10);
plot(tempo,Ib_1_10);
plot(tempo,Ic_1_10);
legend('iA','iB', 'iC');
title(["Correntes de linha das três fases na barra 10"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
grid on;
plot(tempo,iNeutro);
title(["Correntes de neutro barra 10"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");


figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10);
plot(tempo,Ia_1_10_f);
legend('Normal','Filtrado');
title(["Corrente de linha da fase A na barra 10 após filtragem analógica"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10_f);
plot(tempo,ia_fasores);

plot([instante_de_percepcao_a, instante_de_percepcao_a], ylim, 'black--');
plot([instante_do_trip_a, instante_do_trip_a], ylim, 'r--');

title(["Atuação da função de proteção implementada"]);
legend('sinal analógico iA_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10_f);
plot(tempo,ia_fasores);

plot([instante_de_percepcao_a, instante_de_percepcao_a], ylim, 'black--');
plot([instante_do_trip_a, instante_do_trip_a], ylim, 'r--');

title(["Atuação da função de proteção implementada"]);
legend('sinal analógico iA_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ib_1_10_f);
plot(tempo,ib_fasores);

plot([instante_de_percepcao_b, instante_de_percepcao_b], ylim, 'black--');
plot([instante_do_trip_b, instante_do_trip_b], ylim, 'r--');

title(["Atuação da função de proteção implementada"]);
legend('sinal analógico iB_{10}', 'módulo dos fasores IB_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ic_1_10_f);
plot(tempo,ic_fasores);

plot([instante_de_percepcao_c, instante_de_percepcao_c], ylim, 'black--');
plot([instante_do_trip_c, instante_do_trip_c], ylim, 'r--');

title(["Atuação da função de proteção implementada"]);
legend('sinal analógico iC_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");


figure;
subplot(2, 2, 1);
hold on;
plot(tempo, sinal_trip_a,'b');
plot([instante_do_trip_a, instante_do_trip_a], ylim, 'r--');
title(["Atuação do Relé para fase A"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 2);
hold on;
plot(tempo, sinal_trip_b,'b');
plot([instante_do_trip_b, instante_do_trip_b], ylim, 'r--');
title(["Atuação do Relé para fase B"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 3);
hold on;
plot(tempo, sinal_trip_c,'b');
plot([instante_do_trip_c, instante_do_trip_c], ylim, 'r--');
title(["Atuação do Relé para fase C"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 4);
hold on;
plot(tempo, sinal_trip_n,'b');
plot([instante_do_trip_n, instante_do_trip_n], ylim, 'r--');
title(["Atuação do Relé para o neutro"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;