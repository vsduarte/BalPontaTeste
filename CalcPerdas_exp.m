% CalcPerdas    Função para cálculo das perdas por deplecionamento
%
% [Predas] = CalPerdas(nsis,FuncPerdas,EAR)
%
% Retorna as perdas por deplecionamento, cuja função é uma soma de
% exponenciais
% 

function [Perdas] = CalcPerdas_exp(nsis,FuncPerdas,EAR)

for isis = 1:nsis
   a = 4*(isis-1) + 1;
   b = 4*(isis-1) + 2;
   c = 4*(isis-1) + 3;
   d = 4*(isis-1) + 4;
   for iper = 1:60
      Perdas(iper,isis) = FuncPerdas(iper,a)*exp(FuncPerdas(iper,b)*...
         EAR(iper,isis)) + ...
         FuncPerdas(iper,c)*exp(FuncPerdas(iper,d)*EAR(iper,isis));
   end
end

