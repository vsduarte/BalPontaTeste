%
%   Rotina para cálculo da potência instalada
%

%nsis = max([ConfT.subsistema]);
PinstT = zeros(nper,nsis);
GTmin = zeros(nper,nsis);
GTmax = zeros(nper,nsis);

for iusi = 1:nusiTerm
   isis = ApontadorSistema(ConfT(iusi).subsistema);
   for iper = 1:nper
       PinstT(iper,isis) = PinstT(iper,isis) + ...
           ConfT(iusi).Potef(iper);
       GTmin(iper,isis) = GTmin(iper,isis) + ConfT(iusi).GtMin(iper);
       GTmax(iper,isis) = GTmax(iper,isis) + ...
           ConfT(iusi).Potef(iper) * ConfT(iusi).FcMax(iper) * ...
           (1.0 - ConfT(iusi).Teif(iper)) * ...
           (1.0 - ConfT(iusi).Teip(iper));   
   end
end