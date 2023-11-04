function [ta] = Protecao(curve_family,curve_type,ipk,mt,ifasor)
%                           |            |      |   | 
%                           |            |      |   |
%                           |            |      |   \_______ Multiplicador de tempo
%                           |            |      \___________ Corrente de pickup em valores secundários do TC
%                           |            \__________________ Tipo da curva dentro de cada familia
%                           \________________________________Família de curva (ANSI ou IEC)

m = ifasor/ipk;

switch curve_type
  % ANSI
  case 'ext_inv'
    A = 28.2;
    B = 0.1217;
    p = 2;
  case 'mui_inv'
    A = 19.61;
    B = 0.491;
    p = 2;
  case 'mod_inv'
    A = 0.0515;
    B = 0.1140;
    p = 0.02;
    
  % IEC
  case 'short_inv'
    K = 0.05;
    E = 0.04;
  case 'A'
    K = 0.14;
    E = 0.02;
  case 'B'
    K = 13.5;
    E = 1;
  case 'C'
    K = 80;
    E = 2;
end

switch curve_family
  case 'ieee'
    ta = mt*(A/(m^p - 1) + B);
  case 'iec'
    ta = mt*(K/(m^E - 1));
end
