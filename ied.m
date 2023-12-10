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

% Parâmetros da função


%% ------------------------------------------------------------------------
% 3. Dados da simulação
% -------------------------------------------------------------------------

ABC002_RED;

% Criando os vetores de tempo e corrente

tempo = matriz(1:end, 1);
Ia_local = matriz(1:end, 2);
Ib_local = matriz(1:end, 3);
Ic_local = matriz(1:end, 4);
Ia_remoto = matriz(1:end, 5);
Ib_remoto = matriz(1:end, 6);
Ic_remoto = matriz(1:end, 7);

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

Ia_local_f = Filtro_Analogico(1, Ia_local, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_local_f = Filtro_Analogico(1, Ib_local, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_local_f = Filtro_Analogico(1, Ic_local, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ia_remoto_f = Filtro_Analogico(1, Ia_remoto, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_remoto_f = Filtro_Analogico(1, Ib_remoto, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_remoto_f = Filtro_Analogico(1, Ic_remoto, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);


figure(1)
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10);
plot(tempo,Ib_1_10);
plot(tempo,Ic_1_10);
legend('iA','iB', 'iC');
title(["Correntes de linha das três fases na barra 10"]);


figure(2)
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10);
plot(tempo,Ia_1_10_f);
legend('Normal','Filtrado');
title(["Corrente de linha da fase A na barra 10 após filtragem analógica"]);



%% ------------------------------------------------------------------------
% 5) Calculo da protecao diferencial
% -------------------------------------------------------------------------

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                          % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                            % Ponteiro que é atualizado a cada posição de leitura
ia_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ia local
ib_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ib local
ic_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ic local
ia_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ia remoto
ib_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ib remoto
ic_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ic remoto
tempo_lido  = zeros(1, tam_buffer);        % Buffer que armazena a referência de tempo



aux = 1;

timer = 0;
tempo_pro_trip = -1;

instante_do_trip = 0;
instante_de_percepcao = 0;
tempo_pro_trip_estimado = 0;
deveria_atualizar = 1;

ia_fasores_local = zeros(1, length(tempo));
ib_fasores_local = zeros(1, length(tempo));
ic_fasores_local = zeros(1, length(tempo));
ia_fasores_remoto = zeros(1, length(tempo));
ib_fasores_remoto = zeros(1, length(tempo));
ic_fasores_remoto = zeros(1, length(tempo));

% % 5.2) Leitura dos ADs
while aux<length(tempo)

%   5.2.3) Atualização dos buffers circulares
    ia_local_dig(ponteiro_b) = Ia_local_f(aux);
    ib_local_dig(ponteiro_b) = Ib_local_f(aux);
    ic_local_dig(ponteiro_b) = Ic_local_f(aux);
    ia_remoto_dig(ponteiro_b) = Ia_remoto_f(aux);
    ib_remoto_dig(ponteiro_b) = Ib_remoto_f(aux);
    ic_remoto_dig(ponteiro_b) = Ic_remoto_f(aux);
    tempo_lido(ponteiro_b)  = tempo(aux); 


%   5.2.4) Cálculo dos fasores
    ia_local_ordenada = [ia_local_dig(ponteiro_b:tam_buffer) ia_local_dig(1:ponteiro_b-1)];
    ib_local_ordenada = [ib_local_dig(ponteiro_b:tam_buffer) ib_local_dig(1:ponteiro_b-1)];
    ic_local_ordenada = [ic_local_dig(ponteiro_b:tam_buffer) ic_local_dig(1:ponteiro_b-1)];
    ia_remoto_ordenada = [ia_remoto_dig(ponteiro_b:tam_buffer) ia_remoto_dig(1:ponteiro_b-1)];
    ib_remoto_ordenada = [ib_remoto_dig(ponteiro_b:tam_buffer) ib_remoto_dig(1:ponteiro_b-1)];
    ic_remoto_ordenada = [ic_remoto_dig(ponteiro_b:tam_buffer) ic_remoto_dig(1:ponteiro_b-1)];

    ia_local_fasores(aux) = fourier(ia_local_ordenada, tam_buffer, fa, f).magnitude;
    ib_local_fasores(aux) = fourier(ib_local_ordenada, tam_buffer, fa, f).magnitude;
    ic_local_fasores(aux) = fourier(ic_local_ordenada, tam_buffer, fa, f).magnitude;
    ia_remoto_fasores(aux) = fourier(ia_remoto_ordenada, tam_buffer, fa, f).magnitude;
    ib_remoto_fasores(aux) = fourier(ib_remoto_ordenada, tam_buffer, fa, f).magnitude;
    ic_remoto_fasores(aux) = fourier(ic_remoto_ordenada, tam_buffer, fa, f).magnitude;


%   5.2.5) Cálculo do menor tempo de atuação dentre os três fasores
    array_tempos = [
        Protecao(curve_family, curve_type, ipk, mt, ia_local_fasores(aux)) 
        Protecao(curve_family, curve_type, ipk, mt, ib_local_fasores(aux)) 
        Protecao(curve_family, curve_type, ipk, mt, ic_local_fasores(aux))
    ];
    
    tempo_pro_trip = min(array_tempos(array_tempos > 0));
   

    if(tempo_pro_trip > 0 & deveria_atualizar) 
        
        if(instante_de_percepcao == 0)
            instante_de_percepcao = tempo(aux);
        end
        
        if(timer > tempo_pro_trip)
            instante_do_trip = tempo(aux);
            tempo_pro_trip_estimado = tempo_pro_trip;
            deveria_atualizar = 0;
            
        end

        timer = timer + Ts;

    else
        timer = max([0 timer-Ts]);
    end


    ponteiro_b = ponteiro_b + 1;   % Atualização do ponteiro dos buffers

    if ponteiro_b>tam_buffer
        ponteiro_b = 1;
    end
    
    aux = aux + 1;
end

figure(3)
hold on;
zoom on;
grid on;
plot(tempo,Ia_1_10_f);
plot(tempo,ia_fasores);

plot([instante_de_percepcao, instante_de_percepcao], ylim, 'black--');
plot([instante_do_trip, instante_do_trip], ylim, 'r--');

title(["Atuação da função de proteção implementada"]);
legend('sinal analógico iA_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');


