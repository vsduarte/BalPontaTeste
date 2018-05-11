% CalcPerdas    Função para cálculo das perdas por deplecionamento
%
% [Predas] = CalPerdas(nsis,FuncPerdas,EAR)
%
% Retorna as perdas por deplecionamento, cuja função é uma soma de
% exponenciais
% 

function [Perdas] = CalcPerdas_poly(nsis,FuncPerdas,EAR)

for isis = 1:nsis
   a = 3*(isis-1) + 1;
   b = 3*(isis-1) + 2;
   c = 3*(isis-1) + 3;
   for iper = 1:60
      Perdas(iper,isis) = ...
         FuncPerdas(iper,a)*EAR(iper,isis)^2 + ...
         FuncPerdas(iper,b)*EAR(iper,isis) + ...
         FuncPerdas(iper,c);
   end
end

