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

alfa = cos(120*pi()/180) + 1i*sin(120*pi()/180);
T = [1 1 1; 1 alfa*alfa alfa; 1 alfa alfa*alfa];

% Parâmetros da função
IopMin = 6;  % 120% da corrente nominal dos TCs
k = 0.5;

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


% figure(1)
% hold on;
% zoom on;
% grid on;
% plot(tempo,Ia_1_10);
% plot(tempo,Ib_1_10);
% plot(tempo,Ic_1_10);
% legend('iA','iB', 'iC');
% title(["Correntes de linha das três fases na barra 10"]);


% figure(2)
% hold on;
% zoom on;
% grid on;
% plot(tempo,Ia_1_10);
% plot(tempo,Ia_1_10_f);
% legend('Normal','Filtrado');
% title(["Corrente de linha da fase A na barra 10 após filtragem analógica"]);



%% ------------------------------------------------------------------------
% 5) Calculo da protecao diferencial
% -------------------------------------------------------------------------

% Inicialização dos vetores
s = struct('real', 0, 'imag' ,0, 'magnitude', 0, 'phase_rad', 0, 'phase_deg', 0, 'complex', 0);

ia_local_fasores = repmat(s,length(tempo), 1);
ib_local_fasores = repmat(s,length(tempo), 1);
ic_local_fasores = repmat(s,length(tempo), 1);
ia_remoto_fasores = repmat(s,length(tempo), 1);
ib_remoto_fasores = repmat(s,length(tempo), 1);
ic_remoto_fasores = repmat(s,length(tempo), 1);

izero_local = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de sequência zero local
ipos_local = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de sequência positiva local
ineg_local = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de sequência negativa local
izero_remoto = zeros(1, length(tempo));      % Vetor que armazena a referência o sinal de corrente de sequência zero remoto
ipos_remoto = zeros(1, length(tempo));      % Vetor que armazena a referência o sinal de corrente de sequência positiva remoto
ineg_remoto = zeros(1, length(tempo));      % Vetor que armazena a referência o sinal de corrente de sequência negativa remoto

izero_operacao = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de operação da sequência zero
ipos_operacao = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de operação da sequência positiva
ineg_operacao = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de operação da sequência negativa

izero_resistencia = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de resistencia da sequência zero
ipos_resistencia = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de resistencia da sequência positiva
ineg_resistencia = zeros(1, length(tempo));       % Vetor que armazena a referência o sinal de corrente de resistencia da sequência negativa

% 5.1) Implementação do buffer circular

tam_buffer  = 64;                          % Tamanho do buffer, em numero de amostras
ponteiro_b = 1;                            % Ponteiro que é atualizado a cada posição de leitura

ia_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ia local
ib_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ib local
ic_local_dig = zeros(1, tam_buffer);       % Buffer que armazena a referência o sinal de corrente ic local
ia_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ia remoto
ib_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ib remoto
ic_remoto_dig = zeros(1, tam_buffer);      % Buffer que armazena a referência o sinal de corrente ic remoto


aux = 1;

instante_do_trip_zero = 0;
instante_do_trip_pos = 0;
instante_do_trip_neg = 0;

deveria_atualizar_zero = 1;
deveria_atualizar_pos = 1;
deveria_atualizar_neg = 1;


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

    ia_local_fasores(aux) = fourier(ia_local_ordenada, tam_buffer, fa, f);
    ib_local_fasores(aux) = fourier(ib_local_ordenada, tam_buffer, fa, f);
    ic_local_fasores(aux) = fourier(ic_local_ordenada, tam_buffer, fa, f);
    ia_remoto_fasores(aux) = fourier(ia_remoto_ordenada, tam_buffer, fa, f);
    ib_remoto_fasores(aux) = fourier(ib_remoto_ordenada, tam_buffer, fa, f);
    ic_remoto_fasores(aux) = fourier(ic_remoto_ordenada, tam_buffer, fa, f);


%   5.2.5) Cálculo das componentes simétricas
    componentes_simetricas_local = inv(T)*[ia_local_fasores(aux).complex; ib_local_fasores(aux).complex; ic_local_fasores(aux).complex];
    izero_local(aux) = componentes_simetricas_local(1,:);
    ipos_local(aux) = componentes_simetricas_local(2,:);
    ineg_local(aux) = componentes_simetricas_local(3,:);

    componentes_simetricas_remoto = inv(T)*[ia_remoto_fasores(aux).complex; ib_remoto_fasores(aux).complex; ic_remoto_fasores(aux).complex];
    izero_remoto(aux) = componentes_simetricas_remoto(1,:);
    ipos_remoto(aux) = componentes_simetricas_remoto(2,:);
    ineg_remoto(aux) = componentes_simetricas_remoto(3,:);



%   5.2.5) Função de proteção diferencial para componentes simétricas
    izero_operacao(aux) = abs(izero_local(aux) - izero_remoto(aux));
    izero_resistencia(aux) = (abs(izero_local(aux)) + abs(izero_remoto(aux)))/2;

    ipos_operacao(aux) = abs(ipos_local(aux) - ipos_remoto(aux));
    ipos_resistencia(aux) = (abs(ipos_local(aux)) + abs(ipos_remoto(aux)))/2;

    ineg_operacao(aux) = abs(ineg_local(aux) - ineg_remoto(aux));
    ineg_resistencia(aux) = (abs(ineg_local(aux)) + abs(ineg_remoto(aux)))/2;

    if(izero_operacao(aux) > IopMin && izero_operacao(aux) > k*izero_resistencia(aux) && deveria_atualizar_zero)
        instante_do_trip_zero = tempo(aux);
        deveria_atualizar_zero = 0;
    end
    
    if(ipos_operacao(aux) > IopMin && ipos_operacao(aux) > k*ipos_resistencia(aux) && deveria_atualizar_pos)
        instante_do_trip_pos = tempo(aux);
        deveria_atualizar_pos = 0;
    end
    
    if(ineg_operacao(aux) > IopMin && ineg_operacao(aux) > k*ineg_resistencia(aux) && deveria_atualizar_neg)
        instante_do_trip_neg = tempo(aux);
        deveria_atualizar_neg = 0;
    end
    

   % Atualização do ponteiro dos buffers
    ponteiro_b = ponteiro_b + 1;   

    if ponteiro_b>tam_buffer
        ponteiro_b = 1;
    end
    
    aux = aux + 1;
end

% figure(3)
% hold on;
% zoom on;
% grid on;
% plot(tempo,Ia_1_10_f);
% plot(tempo,ia_fasores);

% plot([instante_do_trip, instante_do_trip], ylim, 'r--');

% title(["Atuação da função de proteção implementada"]);
% legend('sinal analógico iA_{10}', 'módulo dos fasores IA_{10}', 'instante de percepção da falta','instante do trip');


