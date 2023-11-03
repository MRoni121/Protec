function [X] = protege(curve_family,curve_type,ipk,mt)
%                           |            |      |   | 
%                           |            |      |   |
%                           |            |      |   \_______ Família de curva (ANSI ou IEC)
%                           |            |      \___________ Corrente de pickup em valores secundários do TC
%                           |            \__________________ Tipo da curva dentro de cada familia
%                           \________________________________Família de curva (ANSI ou IEC)
