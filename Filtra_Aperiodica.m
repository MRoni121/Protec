% -------------------------------------------------------------------------
% PROGRAMA PARA Filtragem da componente APERIODICA
%
% -------------------------------------------------------------------------
% Autor: Giovanni Manassero Junior
% Data: 22/09/2005
% -------------------------------------------------------------------------
function [sinal_filtrado] = Filtra_Aperiodica...
    (alfa,sinal_entrada,fa,n_ciclo);
% -------------------------------------------------------------------------
% Dados dos sinais para a filtragem digital
% -------------------------------------------------------------------------
ta      = 1/fa;
% -----------------------------------------------------------------
% Coeficientes do filtro FIR (16 am/ciclo)
% -----------------------------------------------------------------
% dc_filter = gg*[aa 0 0 0 -1];
% -----------------------------------------------------------------
m  = round(n_ciclo/4);
aa = exp(alfa*m*ta);
gg = 1/sqrt(aa^2-2*aa*cos(2*pi*m/n_ciclo)+1);
b1 = gg*aa;    % coeficiente da k_esima amostra
b5 = gg*(-1);  % coeficiente da (k_esima - m) amostra
% -----------------------------------------------------------------
% Filtragem dos sinais
% -----------------------------------------------------------------
nta = length(sinal_entrada); % numero total de pontos amostrados pelo rele
% -----------------------------------------------------------------
for aux=1:nta
    if aux<m+1
        sinal_filtrado(aux)   = b1*sinal_entrada(aux);
    else
        sinal_filtrado(aux)   = b1*sinal_entrada(aux) + ...
            b5*sinal_entrada(aux-m);
    end
end