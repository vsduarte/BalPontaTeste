%---> Imprime o balanço de ponta determinístico de um determinado mês
function DispBalancoProbabilistico(iper,isim)

clc;

% Carrega variáveis do workspace base
nsis = evalin('base','nsis');
nfic = evalin('base','nfic');
Sistema = evalin('base','Sistema');
reserva = evalin('base','reserva');
Mercado = evalin('base','Mercado');
GTmin = evalin('base','GTmin');
GTmax = evalin('base','GTmax');
GHmax = evalin('base','GHmax');
GH = evalin('base','GH');
GT = evalin('base','GT');
Interc = evalin('base','Interc');
Sobra = evalin('base','Sobra');
Deficit = evalin('base','Deficit');
OfertaAdicional = evalin('base','OfertaAdicional');
Intercambio = evalin('base','Intercambio');
ApontadorIntercambio = evalin('base','ApontadorIntercambio');
Agrint = evalin('base','Agrint');
numAgrint = evalin('base','numAgrint');

%---> Cabeçaho
fprintf('Balanço de Ponta\tPeríodo: %i\n',iper)
fprintf('================')
for isis = 1:nsis
   fprintf('========')
end
fprintf('\n')
fprintf(' Variável\t')
for isis = 1:nsis
   nome = cell2mat({Sistema(isis).nome});
   fprintf('|%-6s\t',nome(1:min(size(nome,2),6)))
end
fprintf('\n')
fprintf('----------------')
for isis = 1:nsis
fprintf('+-------')
end
fprintf('\n')
%---> Demanda
fprintf(' Demanda\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',Sistema(isis).Mercado(iper))
end
fprintf('\n')
%---> Reserva
fprintf(' Reserva (%3.1f%%)\t',reserva)
for isis = 1:nsis
   fprintf('|%6.0f\t',Mercado(isis,iper)-Sistema(isis).Mercado(iper))
end
fprintf('\n')
%---> Demanda máxima
fprintf(' Demanda máxima\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',Mercado(isis,iper))
end
fprintf('\n')
%---> SEPARADOR
fprintf('----------------')
for isis = 1:nsis
   fprintf('+-------')
end
fprintf('\n')
%---> Inflexibilidade
fprintf(' Inflex. Term.\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',GTmin(iper,isis))
end
fprintf('\n')
%---> Não Simuladas
fprintf(' Não Simuláveis\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',Sistema(isis).NaoSimul(iper))
end
fprintf('\n')
%---> Geração Hidro
fprintf(' Desp. Hidro\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',GH(isis,iper,isim))
end
fprintf('\n')
%---> Geração Termico
fprintf(' Desp. Térm.\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',GT(isis,iper,isim)-GTmin(iper,isis))
end
fprintf('\n')
%---> Impotação
fprintf(' Importação\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',sum(Interc(:,isis,iper,isim)))
end
fprintf('\n')
%---> Exportação
fprintf(' Exportação\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',sum(Interc(isis,:,iper,isim)))
end
fprintf('\n')
%---> SEPARADOR
fprintf('----------------')
for isis = 1:nsis
   fprintf('+-------')
end
fprintf('\n')
%---> Sobra
fprintf(' FOLGA\t\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',Sobra(isis,iper,isim))
end
fprintf('\n')
%---> Déficit
fprintf(' DÉFICIT\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',Deficit(isis,iper,isim))
end
fprintf('\n')
%---> SEPARADOR
fprintf('----------------')
for isis = 1:nsis
   fprintf('+-------')
end
fprintf('\n')
%---> Disponibilidade Hidro
fprintf(' Dispo. Hidro\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',GHmax(iper,isis))
end
fprintf('\n')
%---> Despacho Hidro
fprintf(' Hidro Desp.\t')
for isis = 1:nsis
   fprintf('|%5.1f%%\t',GH(isis,iper,isim)/GHmax(iper,isis)*100)
end
fprintf('\n')
%---> Disponibilidade Termica
fprintf(' Dispo. Termo\t')
for isis = 1:nsis
   fprintf('|%6.0f\t',GTmax(iper,isis))
end
fprintf('\n')
%---> Despacho Termo
fprintf(' Termica Desp.\t')
for isis = 1:nsis
   fprintf('|%5.1f%%\t',GT(isis,iper,isim)/GTmax(iper,isis)*100)
end
fprintf('\n')
%---> SEPARADOR
fprintf('================')
for isis = 1:nsis
   fprintf('========')
end
fprintf('\n')


%===== Intercambios =======================================================

%---> Cabecalho
fprintf('         \t')
for isis = 1:nsis
   nome = cell2mat({Sistema(isis).nome});
   fprintf('|%-6s\t',nome(1:min(size(nome,2),6)))
end
fprintf('\n')
fprintf('----------------')
for isis = 1:nsis
fprintf('+-------')
end
fprintf('\n')

%---> Impotação
fprintf(' Importação\t')
for isis = 1:nsis
   fprintf('|%5.0f \t',sum(Interc(:,isis,iper,isim)))
end
fprintf('\n')
for jsis = 1:nsis+nfic
   nome = cell2mat({Sistema(jsis).nome});
   fprintf('    %-6s\t',nome(1:min(size(nome,2),12)))
   for isis = 1:nsis
      fprintf('|%5.0f',sum(Interc(jsis,isis,iper,isim)))
      iApontador = ApontadorIntercambio(jsis,isis);
      if (iApontador ~= 0)
         DifInterc = Intercambio(iApontador).capacidade(iper) - ...
            sum(Interc(jsis,isis,iper,isim));
         if(abs(DifInterc)<1e-3)
            fprintf('*')
         else
            fprintf(' ')
         end
      else
         fprintf(' ')
      end
      fprintf('\t')
   end
   fprintf('\n')
end
fprintf('\n')
%---> Exportação
fprintf(' Exportação\t')
for isis = 1:nsis
   fprintf('|%5.0f \t',sum(Interc(isis,:,iper,isim)))
end
fprintf('\n')
for jsis = 1:nsis+nfic
   nome = cell2mat({Sistema(jsis).nome});
   fprintf('    %-6s\t',nome(1:min(size(nome,2),12)))
   for isis = 1:nsis
      fprintf('|%5.0f',sum(Interc(isis,jsis,iper,isim)))
      iApontador = ApontadorIntercambio(isis,jsis);
      if (iApontador ~= 0)
         DifInterc = Intercambio(iApontador).capacidade(iper) - ...
            sum(Interc(isis,jsis,iper,isim));
         if(abs(DifInterc)<1e-3)
            fprintf('*')
         else
            fprintf(' ')
         end
      else
         fprintf(' ')
      end
      fprintf('\t')
   end
   fprintf('\n')
end
%---> Rodapé
fprintf('================')
for isis = 1:nsis
   fprintf('========')
end
fprintf('\n')

end
