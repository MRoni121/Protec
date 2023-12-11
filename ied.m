% PEA3416, PEA3424 e PEA5729 - Disciplinas de Proteção de Sistemas Elétricos (2023) - ATIVIDADE 2
% GRUPO 1
% André Lima Alambert               - 11857917
% Davor Kapor Pereira               - 11804702
% Mateus Roni Noronha de Carvalho   - 11805294
% Pedro Kaltenbacher Ruiz           - 11914685

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
% 3. Dados da simulação
% -------------------------------------------------------------------------

% Transformando cada arquivo csv em matriz

arquivo = 'A1rele';

sinais_1_10 = csvread([arquivo, '10.csv']);
sinais_1_20 = csvread([arquivo, '20.csv']);
sinais_1_30 = csvread([arquivo, '30.csv']);

% Criando os vetores de tempo e corrente

tempo = sinais_1_10(1:end, 1);
Ia_10 = sinais_1_10(1:end, 2);
Ib_10 = sinais_1_10(1:end, 3);
Ic_10 = sinais_1_10(1:end, 4);
Ia_20 = sinais_1_20(1:end, 2);
Ib_20 = sinais_1_20(1:end, 3);
Ic_20 = sinais_1_20(1:end, 4);
Ia_30 = sinais_1_30(1:end, 2);
Ib_30 = sinais_1_30(1:end, 3);
Ic_30 = sinais_1_30(1:end, 4);

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

Ia_10_f = Filtro_Analogico(1, Ia_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_10_f = Filtro_Analogico(1, Ib_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_10_f = Filtro_Analogico(1, Ic_10, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_20_f = Filtro_Analogico(1, Ia_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_20_f = Filtro_Analogico(1, Ib_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_20_f = Filtro_Analogico(1, Ic_20, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_30_f = Filtro_Analogico(1, Ia_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_30_f = Filtro_Analogico(1, Ib_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_30_f = Filtro_Analogico(1, Ic_30, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);



%% ------------------------------------------------------------------------
% 5) Calculo da protecao de sobrecorrente
% -------------------------------------------------------------------------

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                   % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                     % Ponteiro que é atualizado a cada posição de leitura
ia_dig_10 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ia lido da barra 10
ib_dig_10 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ib lido da barra 10
ic_dig_10 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ic lido da barra 10

ia_dig_20 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ia lido da barra 20
ib_dig_20 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ib lido da barra 20
ic_dig_20 = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ic lido da barra 20

tempo_lido  = zeros(1, tam_buffer); % Buffer que armazena a referência de tempo


aux = 1;

timer_a_10 = 0;
timer_b_10 = 0;
timer_c_10 = 0;
timer_n_10 = 0;

timer_a_20 = 0;
timer_b_20 = 0;
timer_c_20 = 0;
timer_n_20 = 0;


instante_do_trip_a_10 = 0;
instante_do_trip_b_10 = 0;
instante_do_trip_c_10 = 0;
instante_do_trip_n_10 = 0;

instante_do_trip_a_20 = 0;
instante_do_trip_b_20 = 0;
instante_do_trip_c_20 = 0;
instante_do_trip_n_20 = 0;

instante_de_percepcao_a_10 = 0;
instante_de_percepcao_b_10 = 0;
instante_de_percepcao_c_10 = 0;
instante_de_percepcao_n_10 = 0;

instante_de_percepcao_a_20 = 0;
instante_de_percepcao_b_20 = 0;
instante_de_percepcao_c_20 = 0;
instante_de_percepcao_n_20 = 0;

tempo_pro_trip_estimado_a_10 = 0;
tempo_pro_trip_estimado_b_10 = 0;
tempo_pro_trip_estimado_c_10 = 0;
tempo_pro_trip_estimado_n_10 = 0;

tempo_pro_trip_estimado_a_20 = 0;
tempo_pro_trip_estimado_b_20 = 0;
tempo_pro_trip_estimado_c_20 = 0;
tempo_pro_trip_estimado_n_20 = 0;

deveria_atualizar_a_10 = 1;
deveria_atualizar_b_10 = 1;
deveria_atualizar_c_10 = 1;
deveria_atualizar_n_10 = 1;

deveria_atualizar_a_20 = 1;
deveria_atualizar_b_20 = 1;
deveria_atualizar_c_20 = 1;
deveria_atualizar_n_20 = 1;

sinal_trip_a_10 = zeros(1, length(tempo));
sinal_trip_b_10 = zeros(1, length(tempo));
sinal_trip_c_10 = zeros(1, length(tempo));
sinal_trip_n_10 = zeros(1, length(tempo));

sinal_trip_a_20 = zeros(1, length(tempo));
sinal_trip_b_20 = zeros(1, length(tempo));
sinal_trip_c_20 = zeros(1, length(tempo));
sinal_trip_n_20 = zeros(1, length(tempo));

ia_fasores_10 = zeros(1, length(tempo));
ib_fasores_10 = zeros(1, length(tempo));
ic_fasores_10 = zeros(1, length(tempo));
in_fasores_10 = zeros(1, length(tempo));

ia_fasores_20 = zeros(1, length(tempo));
ib_fasores_20 = zeros(1, length(tempo));
ic_fasores_20 = zeros(1, length(tempo));
in_fasores_20 = zeros(1, length(tempo));

% % 5.2) Leitura dos ADs
while aux<length(tempo)

%   5.2.3) Atualização dos buffers circulares
    ia_dig_10(ponteiro_b) = Ia_10_f(aux);
    ib_dig_10(ponteiro_b) = Ib_10_f(aux);
    ic_dig_10(ponteiro_b) = Ic_10_f(aux);
    
    ia_dig_20(ponteiro_b) = Ia_20_f(aux);
    ib_dig_20(ponteiro_b) = Ib_20_f(aux);
    ic_dig_20(ponteiro_b) = Ic_20_f(aux);
    tempo_lido(ponteiro_b)  = tempo(aux);  % Atualização do buffer de tempo


%   5.2.4) Cálculo dos fasores
    ia_ordenada_10 = [ia_dig_10(ponteiro_b:tam_buffer) ia_dig_10(1:ponteiro_b-1)];
    ib_ordenada_10 = [ib_dig_10(ponteiro_b:tam_buffer) ib_dig_10(1:ponteiro_b-1)];
    ic_ordenada_10 = [ic_dig_10(ponteiro_b:tam_buffer) ic_dig_10(1:ponteiro_b-1)];
    in_ordenada_10 = ia_ordenada_10 + ib_ordenada_10 + ic_ordenada_10;
    
    ia_ordenada_20 = [ia_dig_20(ponteiro_b:tam_buffer) ia_dig_20(1:ponteiro_b-1)];
    ib_ordenada_20 = [ib_dig_20(ponteiro_b:tam_buffer) ib_dig_20(1:ponteiro_b-1)];
    ic_ordenada_20 = [ic_dig_20(ponteiro_b:tam_buffer) ic_dig_20(1:ponteiro_b-1)];
    in_ordenada_20 = ia_ordenada_20 + ib_ordenada_20 + ic_ordenada_20;

    ia_fasores_10(aux) = fourier(ia_ordenada_10, tam_buffer, fa, f).magnitude;
    ib_fasores_10(aux) = fourier(ib_ordenada_10, tam_buffer, fa, f).magnitude;
    ic_fasores_10(aux) = fourier(ic_ordenada_10, tam_buffer, fa, f).magnitude;
    in_fasores_10(aux) = fourier(in_ordenada_10, tam_buffer, fa, f).magnitude;

    ia_fasores_20(aux) = fourier(ia_ordenada_20, tam_buffer, fa, f).magnitude;
    ib_fasores_20(aux) = fourier(ib_ordenada_20, tam_buffer, fa, f).magnitude;
    ic_fasores_20(aux) = fourier(ic_ordenada_20, tam_buffer, fa, f).magnitude;
    in_fasores_20(aux) = fourier(in_ordenada_20, tam_buffer, fa, f).magnitude;


%   5.2.5) Cálculo dos tempos de atuação
    
    ta_a_10 = Protecao(curve_family, curve_type, ipk, mt, ia_fasores_10(aux)); 
    ta_b_10 = Protecao(curve_family, curve_type, ipk, mt, ib_fasores_10(aux));
    ta_c_10 = Protecao(curve_family, curve_type, ipk, mt, ic_fasores_10(aux));
    ta_n_10 = Protecao(curve_family, curve_type, ipk, mt, in_fasores_10(aux));

    ta_a_20 = Protecao(curve_family, curve_type, ipk, mt, ia_fasores_20(aux)); 
    ta_b_20 = Protecao(curve_family, curve_type, ipk, mt, ib_fasores_20(aux));
    ta_c_20 = Protecao(curve_family, curve_type, ipk, mt, ic_fasores_20(aux));
    ta_n_20 = Protecao(curve_family, curve_type, ipk, mt, in_fasores_20(aux));
    
    
%   Fase A - 10
    if(ta_a_10 > 0) 
        sinal_trip_a_10(aux) = 1;
        if(instante_de_percepcao_a_10 == 0)
            instante_de_percepcao_a_10 = tempo(aux);
        end
        
        if(timer_a_10 > ta_a_10)
            
            if(deveria_atualizar_a_10)
                instante_do_trip_a_10 = tempo(aux);
                tempo_pro_trip_estimado_a_10 = ta_a_10;
            end
            
            deveria_atualizar_a_10 = 0;
            
        end

        timer_a_10 = timer_a_10 + Ts;

    else
        timer_a_10 = max([0 timer_a_10-Ts]);
    end

%   Fase B - 10
    if(ta_b_10 > 0) 
        sinal_trip_b_10(aux) = 1;
        if(instante_de_percepcao_b_10 == 0)
            instante_de_percepcao_b_10 = tempo(aux);
        end
        
        if(timer_b_10 > ta_b_10)
            
            if(deveria_atualizar_b_10)
                instante_do_trip_b_10 = tempo(aux);
                tempo_pro_trip_estimado_b_10 = ta_b_10;
            end
            
            deveria_atualizar_b_10 = 0;
            
        end

        timer_b_10 = timer_b_10 + Ts;

    else
        timer_b_10 = max([0 timer_b_10-Ts]);
    end


%   Fase C - 10
    if(ta_c_10 > 0) 
        sinal_trip_c_10(aux) = 1;
        if(instante_de_percepcao_c_10 == 0)
            instante_de_percepcao_c_10 = tempo(aux);
        end
        
        if(timer_c_10 > ta_c_10)
            
            if(deveria_atualizar_c_10)
                instante_do_trip_c_10 = tempo(aux);
                tempo_pro_trip_estimado_c_10 = ta_c_10;
            end
            
            deveria_atualizar_c_10 = 0;
            
        end

        timer_c_10 = timer_c_10 + Ts;

    else
        timer_c_10 = max([0 timer_c_10-Ts]);
    end

%   Neutro - 10
    if(ta_n_10 > 0) 
        sinal_trip_n_10(aux) = 1;
        if(instante_de_percepcao_n_10 == 0)
            instante_de_percepcao_n_10 = tempo(aux);
        end
        
        if(timer_n_10 > ta_n_10)
            
            if(deveria_atualizar_n_10)
                instante_do_trip_n_10 = tempo(aux);
                tempo_pro_trip_estimado_n_10 = ta_n_10;
            end
            
            deveria_atualizar_n_10 = 0;
            
        end

        timer_n_10 = timer_n_10 + Ts;

    else
        timer_n_10 = max([0 timer_n_10-Ts]);
    end

      
%   Fase A - 20
    if(ta_a_20 > 0) 
        sinal_trip_a_20(aux) = 1;
        if(instante_de_percepcao_a_20 == 0)
            instante_de_percepcao_a_20 = tempo(aux);
        end
        
        if(timer_a_20 > ta_a_20)
            
            if(deveria_atualizar_a_20)
                instante_do_trip_a_20 = tempo(aux);
                tempo_pro_trip_estimado_a_20 = ta_a_20;
            end
            
            deveria_atualizar_a_20 = 0;
            
        end

        timer_a_20 = timer_a_20 + Ts;

    else
        timer_a_20 = max([0 timer_a_20-Ts]);
    end

%   Fase B - 20
    if(ta_b_20 > 0) 
        sinal_trip_b_20(aux) = 1;
        if(instante_de_percepcao_b_20 == 0)
            instante_de_percepcao_b_20 = tempo(aux);
        end
        
        if(timer_b_20 > ta_b_20)
            
            if(deveria_atualizar_b_20)
                instante_do_trip_b_20 = tempo(aux);
                tempo_pro_trip_estimado_b_20 = ta_b_20;
            end
            
            deveria_atualizar_b_20 = 0;
            
        end

        timer_b_20 = timer_b_20 + Ts;

    else
        timer_b_20 = max([0 timer_b_20-Ts]);
    end


%   Fase C - 20
    if(ta_c_20 > 0) 
        sinal_trip_c_20(aux) = 1;
        if(instante_de_percepcao_c_20 == 0)
            instante_de_percepcao_c_20 = tempo(aux);
        end
        
        if(timer_c_20 > ta_c_20)
            
            if(deveria_atualizar_c_20)
                instante_do_trip_c_20 = tempo(aux);
                tempo_pro_trip_estimado_c_20 = ta_c_20;
            end
            
            deveria_atualizar_c_20 = 0;
            
        end

        timer_c_20 = timer_c_20 + Ts;

    else
        timer_c_20 = max([0 timer_c_20-Ts]);
    end

%   Neutro - 20
    if(ta_n_20 > 0) 
        sinal_trip_n_20(aux) = 1;
        if(instante_de_percepcao_n_20 == 0)
            instante_de_percepcao_n_20 = tempo(aux);
        end
        
        if(timer_n_20 > ta_n_20)
            
            if(deveria_atualizar_n_20)
                instante_do_trip_n_20 = tempo(aux);
                tempo_pro_trip_estimado_n_20 = ta_n_20;
            end
            
            deveria_atualizar_n_20 = 0;
            
        end

        timer_n_20 = timer_n_20 + Ts;

    else
        timer_n_20 = max([0 timer_n_20-Ts]);
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

iNeutro_10 = Ia_10 + Ib_10 + Ic_10;
iNeutro_20 = Ia_20 + Ib_20 + Ic_20;
iNeutro_30 = Ia_30 + Ib_30 + Ic_30;

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_10);
plot(tempo,Ib_10);
plot(tempo,Ic_10);
legend('iA','iB', 'iC');
title(["Correntes de linha das três fases na barra 10"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
grid on;
plot(tempo,iNeutro_10);
title(["Correntes de neutro barra 10"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");


figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_10);
plot(tempo,Ia_10_f);
legend('Normal','Filtrado');
title(["Corrente de linha da fase A na barra 10 após filtragem analógica"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_20);
plot(tempo,Ib_20);
plot(tempo,Ic_20);
legend('iA','iB', 'iC');
title(["Correntes de linha das três fases na barra 20"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
grid on;
plot(tempo,iNeutro_20);
title(["Correntes de neutro barra 20"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");


figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_30);
plot(tempo,Ib_30);
plot(tempo,Ic_30);
legend('iA','iB', 'iC');
title(["Correntes de linha das três fases na barra 30"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
grid on;
plot(tempo,iNeutro_30);
title(["Correntes de neutro barra 30"]);
ylabel("Corrente [A]");
xlabel("Tempo (s)");



figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_10_f);
plot(tempo,ia_fasores_10);

plot([instante_de_percepcao_a_10, instante_de_percepcao_a_10], ylim, 'black--');
plot([instante_do_trip_a_10, instante_do_trip_a_10], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 10"]);
legend('sinal analógico iA_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ib_10_f);
plot(tempo,ib_fasores_10);

plot([instante_de_percepcao_b_10, instante_de_percepcao_b_10], ylim, 'black--');
plot([instante_do_trip_b_10, instante_do_trip_b_10], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 10"]);
legend('sinal analógico ib_{10}', 'módulo dos fasores Ib_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ic_10_f);
plot(tempo,ic_fasores_10);

plot([instante_de_percepcao_c_10, instante_de_percepcao_c_10], ylim, 'black--');
plot([instante_do_trip_c_10, instante_do_trip_c_10], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 10"]);
legend('sinal analógico iC_{10}', 'módulo dos fasores IC_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,iNeutro_10);
plot(tempo,in_fasores_10);

plot([instante_de_percepcao_n_10, instante_de_percepcao_n_10], ylim, 'black--');
plot([instante_do_trip_n_10, instante_do_trip_n_10], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 10"]);
legend('sinal analógico in_{10}', 'módulo dos fasores In_{10}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ia_20_f);
plot(tempo,ia_fasores_20);

plot([instante_de_percepcao_a_20, instante_de_percepcao_a_20], ylim, 'black--');
plot([instante_do_trip_a_20, instante_do_trip_a_20], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 20"]);
legend('sinal analógico iA_{20}', 'módulo dos fasores IA_{20}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ib_20_f);
plot(tempo,ib_fasores_20);

plot([instante_de_percepcao_b_20, instante_de_percepcao_b_20], ylim, 'black--');
plot([instante_do_trip_b_20, instante_do_trip_b_20], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 20"]);
legend('sinal analógico ib_{20}', 'módulo dos fasores Ib_{20}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,Ic_20_f);
plot(tempo,ic_fasores_20);

plot([instante_de_percepcao_c_20, instante_de_percepcao_c_20], ylim, 'black--');
plot([instante_do_trip_c_20, instante_do_trip_c_20], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 20"]);
legend('sinal analógico iC_{20}', 'módulo dos fasores IC_{20}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

figure;
hold on;
zoom on;
grid on;
plot(tempo,iNeutro_20);
plot(tempo,in_fasores_20);

plot([instante_de_percepcao_n_20, instante_de_percepcao_n_20], ylim, 'black--');
plot([instante_do_trip_n_20, instante_do_trip_n_20], ylim, 'r--');

title(["Atuação da função de proteção implementada - Barra 20"]);
legend('sinal analógico in_{20}', 'módulo dos fasores In_{20}', 'instante de percepção da falta','instante do trip');
ylabel("Corrente [A]");
xlabel("Tempo (s)");

plot([instante_do_trip_a_10, instante_do_trip_a_10], ylim, 'r--');
title(["Atuação do Relé para fase A - Barra 10"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

figure;
subplot(2, 2, 1);
hold on;
plot(tempo, sinal_trip_a_10,'b');
plot([instante_do_trip_a_10, instante_do_trip_a_10], ylim, 'r--');
title(["Atuação do Relé para fase A - Barra 10"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 2);
hold on;
plot(tempo, sinal_trip_b_10,'b');
plot([instante_do_trip_b_10, instante_do_trip_b_10], ylim, 'r--');
title(["Atuação do Relé para fase B - Barra 10"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 3);
hold on;
plot(tempo, sinal_trip_c_10,'b');
plot([instante_do_trip_c_10, instante_do_trip_c_10], ylim, 'r--');
title(["Atuação do Relé para fase C - Barra 10"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 4);
hold on;
plot(tempo, sinal_trip_n_10,'b');
plot([instante_do_trip_n_10, instante_do_trip_n_10], ylim, 'r--');
title(["Atuação do Relé para o neutro - Barra 10"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;


figure;
subplot(2, 2, 1);
hold on;
plot(tempo, sinal_trip_a_20,'b');
plot([instante_do_trip_a_20, instante_do_trip_a_20], ylim, 'r--');
title(["Atuação do Relé para fase A - Barra 20"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 2);
hold on;
plot(tempo, sinal_trip_b_20,'b');
plot([instante_do_trip_b_20, instante_do_trip_b_20], ylim, 'r--');
title(["Atuação do Relé para fase B - Barra 20"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 3);
hold on;
plot(tempo, sinal_trip_c_20,'b');
plot([instante_do_trip_c_20, instante_do_trip_c_20], ylim, 'r--');
title(["Atuação do Relé para fase C - Barra 20"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;

subplot(2, 2, 4);
hold on;
plot(tempo, sinal_trip_n_20,'b');
plot([instante_do_trip_n_20, instante_do_trip_n_20], ylim, 'r--');
title(["Atuação do Relé para o neutro - Barra 20"]);
ylabel("Nível");
xlabel("Tempo [s]");
legend('Nível do sinal de trip', 'Instante de atuação');
grid;