function [Deficit, Sobra, Interc, GH, GT] = resolveBP(nsis,nfic,...
   DispHidro,DispTerm,DispNS,Mercado,LimInterc,Inflex,Sistema,iper, ...
   Agrint,numAgrint);

% Resolve o seguinte problema:
% min sum(def) + PenInterc * sum(interc) + PenSobra * sum(sobra)
%     + PGH sum(GH) + PGT sum(GT) 
% s.a.
% GH + GT + Deficit - Sobra + Imp - Exp = Mercado - Inflex - DispTerm - 
%      - DispNS
% Imp < LimInterc
% Exp < LimInterc
% GH  < DispHidro
% GT  < DispTerm

%---> Declaração de variáveis
f = [];
A = [];
b = [];
Aeq = [];
beq = [];
lb = [];
ub = [];
x0 = [];
PenInterc = 0.01;
PenDeficit = 100;
PenSobra = 0.001;
%PenGH = 1;
PenGH = [30 1 1 1 2 2 1 1 1 1];   % Prioriza a geração dos subsistemas a fio d'agua (Mad., B. Monte e T. Pires)
PenGT = 10;
% opcoes = optimset(...
%     'LargeScale','on',...
%     'Algorithm','interior-point',...
%     'Display','off'...
%     );
opcoes = optimset();
IntercAponta = zeros(size(LimInterc,1),size(LimInterc,1));

%--------------------------------------------------------------------------
% Montagem do problema
%--------------------------------------------------------------------------

ivar = 0;

%---> Variáveis do problema

% Geração Hidroeletrica
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenGH(isis);               % Função objetivo
   lb(ivar,1) = 0;    % Limite Inferior
   ub(ivar,1) = DispHidro(isis);    % Limite Superior
   Aeq(isis,ivar) = 1;              % Restrição de Atendimento ao Merc
end
% Geração Termoelétrica
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenGT;               % Função objetivo
   lb(ivar,1) = Inflex(isis);     % Limite Inferior
   ub(ivar,1) = DispTerm(isis);    % Limite Superior
   Aeq(isis,ivar) = 1;              % Restrição de Atendimento ao Merc
end
% Deficit
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenDeficit;          % Função objetivo
   lb(ivar,1) = 0;                  % Limite Superior
   ub(ivar,1) = inf;                % Limite inferior
   Aeq(isis,ivar) = 1;              % Restrição de Atendimento ao Merc
end
% Sobras
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenSobra;             % Função objetivo
   lb(ivar,1) = 0;                   % Limite Superior
   ub(ivar,1) = inf;                 % Limite inferior
   Aeq(isis,ivar) = -1;              % Restrição de Atendimento ao Merc
end
% Intercambios
ivar1 = 0;
for isis = 1:nsis+nfic
   for jsis = 1:isis-1
      ivar = ivar + 1;
      ivar1 = ivar1 + 1;
      IntercAponta(isis,jsis) = ivar;
      f(ivar,1) = PenInterc;
      if (Sistema(isis).tipo==1 || Sistema(jsis).tipo==1)
         f(ivar,1) = PenInterc/2;
      end
      if (Sistema(isis).tipo==1 && Sistema(jsis).tipo==1)
         f(ivar,1) = 0.0;
      end      
      lb(ivar,1) = 0;                  % Limite Superior
      ub(ivar,1) = LimInterc(ivar1);   % Limite inferior
      Aeq(isis,ivar) = -1;             % Restrição de Atendimento ao Merc
      Aeq(jsis,ivar) =  1;             % Restrição de Atendimento ao Merc
   end
%   ivar1 = ivar1 + 1;
   for jsis = isis+1:nsis+nfic
      ivar = ivar + 1;
      ivar1 = ivar1 + 1;
      IntercAponta(isis,jsis) = ivar;
      f(ivar,1) = PenInterc;
      if (Sistema(isis).tipo==1 || Sistema(jsis).tipo==1)
         f(ivar,1) = PenInterc/2;
      end
      if (Sistema(isis).tipo==1 && Sistema(jsis).tipo==1)
         f(ivar,1) = 0.0;
      end      
      lb(ivar,1) = 0;                  % Limite Superior
      ub(ivar,1) = LimInterc(ivar1);   % Limite inferior
      Aeq(isis,ivar) = -1;             % Restrição de Atendimento ao Merc
      Aeq(jsis,ivar) =  1;             % Restrição de Atendimento ao Merc
   end
end
nvar = ivar;               % Número de variáveis

%---> Restrições do problema

% Atendimento ao mercado
irest = 0;
for isis = 1:nsis
   irest = irest + 1;
   beq(irest,1) = Mercado(isis) - DispNS(isis);
end
% Equação de nós fictícios
for isis = 1:nfic
   irest = irest + 1;
   beq(irest,1) = 0;
end   
nrest = irest;             % Número de restrições

%---> Restrições de Agrupamento de Intercambio
A = zeros(numAgrint,nvar);
for iagr = 1:numAgrint
    for j = 1:Agrint(iagr).nReg
       isis = Agrint(iagr).De(j);
       jsis = Agrint(iagr).Para(j);
       A(iagr,IntercAponta(isis,jsis)) = Agrint(iagr).Fator(j);
    end
    b(iagr,1) = Agrint(iagr).Limite(iper);
end
%--------------------------------------------------------------------------
% Solução do problema
%--------------------------------------------------------------------------

[x,fval,exitflag,output] = linprog(f,A,b,Aeq,beq,lb,ub,x0,opcoes);

if (exitflag ~= 1)
   disp('')
   disp(output)
   error('Não foi encontrada uma solução ótima.')
end
   

%--------------------------------------------------------------------------
% Carrega a solução do problema
%--------------------------------------------------------------------------
ivar = 0;
% Geração Hidroelétrica
for isis = 1:nsis
   ivar = ivar + 1;
   GH(isis,1) = x(ivar);
end
% Geração Termoelétrica
for isis = 1:nsis
   ivar = ivar + 1;
   GT(isis,1) = x(ivar);
end
% Deficit
for isis = 1:nsis
   ivar = ivar + 1;
   Deficit(isis,1) = round(x(ivar));
end
% Sobras
for isis = 1:nsis
   ivar = ivar + 1;
   Sobra(isis,1) = x(ivar);
end
% Intercambios
for isis = 1:nsis+nfic
   for jsis = 1:isis-1
      ivar = ivar + 1;
      Interc(isis,jsis) = x(ivar);
   end
   for jsis = isis+1:nsis+nfic
      ivar = ivar + 1;
      Interc(isis,jsis) = x(ivar);
   end
end
