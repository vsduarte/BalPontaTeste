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

%---> Declara��o de vari�veis
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
PenGH = [30 1 1 1 2 2 1 1 1 1];   % Prioriza a gera��o dos subsistemas a fio d'agua (Mad., B. Monte e T. Pires)
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

%---> Vari�veis do problema

% Gera��o Hidroeletrica
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenGH(isis);               % Fun��o objetivo
   lb(ivar,1) = 0;    % Limite Inferior
   ub(ivar,1) = DispHidro(isis);    % Limite Superior
   Aeq(isis,ivar) = 1;              % Restri��o de Atendimento ao Merc
end
% Gera��o Termoel�trica
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenGT;               % Fun��o objetivo
   lb(ivar,1) = Inflex(isis);     % Limite Inferior
   ub(ivar,1) = DispTerm(isis);    % Limite Superior
   Aeq(isis,ivar) = 1;              % Restri��o de Atendimento ao Merc
end
% Deficit
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenDeficit;          % Fun��o objetivo
   lb(ivar,1) = 0;                  % Limite Superior
   ub(ivar,1) = inf;                % Limite inferior
   Aeq(isis,ivar) = 1;              % Restri��o de Atendimento ao Merc
end
% Sobras
for isis = 1:nsis
   ivar = ivar + 1;
   f(ivar,1) = PenSobra;             % Fun��o objetivo
   lb(ivar,1) = 0;                   % Limite Superior
   ub(ivar,1) = inf;                 % Limite inferior
   Aeq(isis,ivar) = -1;              % Restri��o de Atendimento ao Merc
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
      Aeq(isis,ivar) = -1;             % Restri��o de Atendimento ao Merc
      Aeq(jsis,ivar) =  1;             % Restri��o de Atendimento ao Merc
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
      Aeq(isis,ivar) = -1;             % Restri��o de Atendimento ao Merc
      Aeq(jsis,ivar) =  1;             % Restri��o de Atendimento ao Merc
   end
end
nvar = ivar;               % N�mero de vari�veis

%---> Restri��es do problema

% Atendimento ao mercado
irest = 0;
for isis = 1:nsis
   irest = irest + 1;
   beq(irest,1) = Mercado(isis) - DispNS(isis);
end
% Equa��o de n�s fict�cios
for isis = 1:nfic
   irest = irest + 1;
   beq(irest,1) = 0;
end   
nrest = irest;             % N�mero de restri��es

%---> Restri��es de Agrupamento de Intercambio
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
% Solu��o do problema
%--------------------------------------------------------------------------

[x,fval,exitflag,output] = linprog(f,A,b,Aeq,beq,lb,ub,x0,opcoes);

if (exitflag ~= 1)
   disp('')
   disp(output)
   error('N�o foi encontrada uma solu��o �tima.')
end
   

%--------------------------------------------------------------------------
% Carrega a solu��o do problema
%--------------------------------------------------------------------------
ivar = 0;
% Gera��o Hidroel�trica
for isis = 1:nsis
   ivar = ivar + 1;
   GH(isis,1) = x(ivar);
end
% Gera��o Termoel�trica
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
