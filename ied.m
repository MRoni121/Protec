% PEA3416, PEA3424 e PEA5729 - Disciplinas de Proteção de Sistemas Elétricos (2023) - ATIVIDADE 4
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

tamanho_janela_de_trip = 16;        % São necessários tamanho_janela_de_trip / 2 amostras para o trip
delay_espurios = num_ciclo;       % Delay para filtrar pulsos espúrios

alfa = cos(120*pi()/180) + 1i*sin(120*pi()/180);
T = [1 1 1; 1 alfa*alfa alfa; 1 alfa alfa*alfa];


% Parâmetros da linha (Colina/Ribeiro Gonçalves)
Z0 = 0.333129333333333 + 1.199437700000000i;
Z1 = 0.018456633333333 + 0.267354800000000i;
L = 366.37;

K = (Z0 - Z1)/Z1;

% Parâmetros da função
angulo_zona_protecao = 90*pi/180;
multiplicador_zona_protecao = 1.2;

%% ------------------------------------------------------------------------
% 3. Dados da simulação
% -------------------------------------------------------------------------

arquivo = 'COLRGV_2019_03_28_SECol.csv';
matriz = table2array(readtable(arquivo, 'NumHeaderLines',3, 'ReadVariableNames',false));

% Criando os vetores de tempo, tensão e corrente

tempo = matriz(1:end, 1);
Ia = matriz(1:end, 2);
Ib = matriz(1:end, 3);
Ic = matriz(1:end, 4);
Va = matriz(1:end, 5);
Vb = matriz(1:end, 6);
Vc = matriz(1:end, 7);
TRIP = matriz(1:end, 8);

for i = 1:length(tempo)
  tempo(i) = (i-1)*Ts;
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

Ia_f = Filtro_Analogico(1, Ia, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ib_f = Filtro_Analogico(1, Ib, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Ic_f = Filtro_Analogico(1, Ic, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Va_f = Filtro_Analogico(1, Va, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Vb_f = Filtro_Analogico(1, Vb, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);
Vc_f = Filtro_Analogico(1, Vc, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax);


%% ------------------------------------------------------------------------
% 5) Calculo da protecao diferencial
% -------------------------------------------------------------------------

% Inicialização dos vetores
s = struct('real', 0, 'imag' ,0, 'magnitude', 0, 'phase_rad', 0, 'phase_deg', 0, 'complex', 0);

ia_fasores = repmat(s,length(tempo), 1);
ib_fasores = repmat(s,length(tempo), 1);
ic_fasores = repmat(s,length(tempo), 1);
va_fasores = repmat(s,length(tempo), 1);
vb_fasores = repmat(s,length(tempo), 1);
vc_fasores = repmat(s,length(tempo), 1);

vab =  zeros(1, length(tempo));
vbc =  zeros(1, length(tempo));
vca =  zeros(1, length(tempo));

izero = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de sequência zero
sinal_trip_a = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da fase A
sinal_trip_b = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da fase B
sinal_trip_c = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da fase C

sinal_trip_ab = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da linha AB
sinal_trip_bc = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da linha BC
sinal_trip_ca = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de trip da linha CA

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                          % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                            % Ponteiro que é atualizado a cada posição de leitura

ia_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ia
ib_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ib
ic_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ic
va_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de tensão va 
vb_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de tensão vb 
vc_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de tensão vc 


aux = 1;

instante_do_trip_zero = 0;
instante_do_trip_pos = 0;
instante_do_trip_neg = 0;

deveria_atualizar_zero = 1;
deveria_atualizar_pos = 1;
deveria_atualizar_neg = 1;


counter_a = 0;
counter_b = 0;
counter_c = 0;
counter_ab = 0;
counter_bc = 0;
counter_ca = 0;

% % 5.2) Leitura dos ADs
while aux<length(tempo)

%   5.2.3) Atualização dos buffers circulares
    ia_dig(ponteiro_b) = Ia_f(aux);
    ib_dig(ponteiro_b) = Ib_f(aux);
    ic_dig(ponteiro_b) = Ic_f(aux);
    va_dig(ponteiro_b) = Va_f(aux);
    vb_dig(ponteiro_b) = Vb_f(aux);
    vc_dig(ponteiro_b) = Vc_f(aux);
    tempo_lido(ponteiro_b)  = tempo(aux); 


%   5.2.4) Cálculo dos fasores
    ia_ordenada = [ia_dig(ponteiro_b:tam_buffer) ia_dig(1:ponteiro_b-1)];
    ib_ordenada = [ib_dig(ponteiro_b:tam_buffer) ib_dig(1:ponteiro_b-1)];
    ic_ordenada = [ic_dig(ponteiro_b:tam_buffer) ic_dig(1:ponteiro_b-1)];
    va_ordenada = [va_dig(ponteiro_b:tam_buffer) va_dig(1:ponteiro_b-1)];
    vb_ordenada = [vb_dig(ponteiro_b:tam_buffer) vb_dig(1:ponteiro_b-1)];
    vc_ordenada = [vc_dig(ponteiro_b:tam_buffer) vc_dig(1:ponteiro_b-1)];

    ia_fasores(aux) = fourier(ia_ordenada, tam_buffer, fa, f);
    ib_fasores(aux) = fourier(ib_ordenada, tam_buffer, fa, f);
    ic_fasores(aux) = fourier(ic_ordenada, tam_buffer, fa, f);
    va_fasores(aux) = fourier(va_ordenada, tam_buffer, fa, f);
    vb_fasores(aux) = fourier(vb_ordenada, tam_buffer, fa, f);
    vc_fasores(aux) = fourier(vc_ordenada, tam_buffer, fa, f);


%   5.2.5) Cálculo da corrente de sequencia zero
    componentes_simetricas_local = inv(T)*[ia_fasores(aux).complex; ib_fasores(aux).complex; ic_fasores(aux).complex];
    izero(aux) = componentes_simetricas_local(1,:);


%   5.2.6) Função de proteção de distância para componentes de fase A B e C | mho-terra
%   5.2.6.1) Fase A
    Z = va_fasores(aux).complex/(ia_fasores(aux).complex + K*izero(aux));
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z)/Z);

    if(angulo <= angulo_zona_protecao)
        counter_a = counter_a + 1;
    end

    if(counter_a > delay_espurios && angulo <= angulo_zona_protecao)
        sinal_trip_a(aux) = 1;
    end

%   5.2.6.2) Fase B
    Z = vb_fasores(aux).complex/(ib_fasores(aux).complex + K*izero(aux));
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z)/Z);

    if(angulo <= angulo_zona_protecao)
        counter_b = counter_b + 1;
    end

    if(counter_b > delay_espurios && angulo <= angulo_zona_protecao)
        sinal_trip_b(aux) = 1;
    end


%   5.2.6.3) Fase C
    Z = vc_fasores(aux).complex/(ic_fasores(aux).complex + K*izero(aux));
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z)/Z);

    if(angulo <= angulo_zona_protecao)
        counter_c = counter_c + 1;
    end

    if(counter_c > delay_espurios && angulo <= angulo_zona_protecao)
        sinal_trip_c(aux) = 1;
    end

%   5.2.7) Cálculo tensões de linha
    vab(aux) = va_fasores(aux).complex - vb_fasores(aux).complex;
    vbc(aux) = vb_fasores(aux).complex - vc_fasores(aux).complex;
    vca(aux) = vc_fasores(aux).complex - va_fasores(aux).complex;

%   5.2.8) Função de proteção de distância para AB, BC e CA | mho-fase
%   5.2.8.1) trip de linha AB
    Z = vab(aux)/(ia_fasores(aux).complex - ib_fasores(aux).complex);
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z )/Z);

    if(angulo <= angulo_zona_protecao )
        counter_ab = counter_ab+1;
    end

    if(counter_ab > delay_espurios & angulo <= angulo_zona_protecao)
        sinal_trip_ab(aux) = 1;
    end

%   5.2.8.2) trip de linha BC
    Z = vbc(aux)/(ib_fasores(aux).complex - ic_fasores(aux).complex);
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z )/Z);

    if(angulo <= angulo_zona_protecao )
        counter_bc = counter_bc+1;
    end

    if(counter_bc > delay_espurios & angulo <= angulo_zona_protecao)
        sinal_trip_bc(aux) = 1;
    end

%   5.2.8.3) trip de linha CA
    Z = vca(aux)/(ic_fasores(aux).complex - ia_fasores(aux).complex);
    angulo = angle((multiplicador_zona_protecao*L*Z1 - Z )/Z);

    if(angulo <= angulo_zona_protecao )
        counter_ca = counter_ca+1;
    end

    if(counter_ca > delay_espurios & angulo <= angulo_zona_protecao)
        sinal_trip_ca(aux) = 1;
    end

   % Atualização do ponteiro dos buffers
    ponteiro_b = ponteiro_b + 1;   

    if ponteiro_b>tam_buffer
        ponteiro_b = 1;
    end
    
    aux = aux + 1;
end

%% ------------------------------------------------------------------------
% 6) Impressões
% -------------------------------------------------------------------------
ineutro = Ia_f + Ib_f + Ic_f;

% 6.1) Correntes de linha filtradas

figure;
subplot(2, 2, 1);
plot(tempo, Ia_f,'r');
hold on
plot(tempo, [ia_fasores.magnitude],'k');
title(["Corrente da Fase A do arquivo " arquivo]);
ylabel("Ia [A]");
xlabel("Tempo [s]");
legend('Corrente filtrada', 'Módulo do fasor calculado')
grid;

subplot(2, 2, 2);
plot(tempo, Ib_f,'g');
hold on
plot(tempo, [ib_fasores.magnitude],'k');
title(["Corrente da Fase B do arquivo " arquivo]);
ylabel("Ib [A]");
xlabel("Tempo [s]");
legend('Corrente filtrada', 'Módulo do fasor calculado')
grid;

subplot(2, 2, 3);
plot(tempo, Ic_f,'b');
hold on
plot(tempo, [ic_fasores.magnitude],'k');
title(["Corrente da Fase C do arquivo " arquivo]);
ylabel("Ic [A]");
xlabel("Tempo [s]");
legend('Corrente filtrada', 'Módulo do fasor calculado')
grid;

subplot(2, 2, 4);
plot(tempo, ineutro);
title(["Corrente de neutro do arquivo " arquivo]);
ylabel("I Neutro [A]");
xlabel("Tempo [s]");
grid;

% % 6.2) Valores de fase remotos
figure;
subplot(2, 2, 1);
plot(tempo, Va_f,'r');
hold on
plot(tempo, [va_fasores.magnitude],'k');
title(["Tensão da Fase A do arquivo " arquivo]);
ylabel("Va [V]");
xlabel("Tempo [s]");
legend('Tensão filtrada', 'Módulo do fasor calculado')
grid;

subplot(2, 2, 2);
plot(tempo, Vb_f,'g');
hold on
plot(tempo, [vb_fasores.magnitude],'k');
title(["Tensão da Fase B do arquivo " arquivo]);
ylabel("Vb [V]");
xlabel("Tempo [s]");
legend('Tensão filtrada', 'Módulo do fasor calculado')
grid;

subplot(2, 2, 3);
plot(tempo, Vc_f,'b');
hold on
plot(tempo, [vc_fasores.magnitude],'k');
title(["Tensão da Fase C do arquivo " arquivo]);
ylabel("Vc [V]");
xlabel("Tempo [s]");
legend('Tensão filtrada', 'Módulo do fasor calculado')
grid;

% 6.3) Sinais de trip de fase
  figure;
  subplot(3, 1, 1);
  plot(sinal_trip_a,'r');
  hold on
  title(["Trip A - " arquivo]);


  subplot(3, 1, 2);
  plot(sinal_trip_b,'g');
  hold on
  title(["Trip B - " arquivo]);

  subplot(3, 1, 3);
  plot(sinal_trip_c,'b');
  hold on
  title(["Trip C - " arquivo]);

% 6.4) Sinais de trip de linha
  figure;
  subplot(3, 1, 1);
  plot(sinal_trip_ab,'r');
  hold on
  title(["Trip AB - " arquivo]);


  subplot(3, 1, 2);
  plot(sinal_trip_bc,'g');
  hold on
  title(["Trip BC - " arquivo]);

  subplot(3, 1, 3);
  plot(sinal_trip_ca,'b');
  hold on
  title(["Trip CA - " arquivo]);
