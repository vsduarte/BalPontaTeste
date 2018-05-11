%
%   Rotina para cálculo da potência instalada
%

PinstH = zeros(nper,nsis);
GHmax = zeros(nper,nsis);
PerdaManut = zeros(nper,nsis);
for iusi = 1:nusi
   isis = ApontadorSistema(ConfHd(iusi).subsistema);
   for iper = mesi:nper
      for icnj = 1:ConfHd(iusi).NumConj
         PinstH(iper,isis) = PinstH(iper,isis) + ...
            ConfHd(iusi).NumMaq(icnj,iper) * ...
            DadoCadastroUsina(iusi).Potef(icnj);
         GHmax(iper,isis) = GHmax(iper,isis) + ...
            ConfHd(iusi).NumMaq(icnj,iper) * ...
            DadoCadastroUsina(iusi).Potef(icnj) * ...
            (100 - DadoCadastroUsina(iusi).TEIF) / 100 * ...
            (100 - DadoCadastroUsina(iusi).IP) / 100 ;
      end
   end
end

%--> Incorpora as perdas por deplecionamento em GHMAX
if(TipoPerdas == 1)
    GHmax_tmp = GHmax;
    for iper = mesi:nper
       for isis = 1:nsis      
           PerdaManut(iper,isis) = PinstH(iper,isis) - GHmax_tmp(iper,isis);
           for isim = 1:nsim
              GHmax(iper,isis,isim) = GHmax_tmp(iper,isis) - ...
                   PerdaDeplecinamento(iper,isis,isim);
           end
        end
    end
end

%--> Calcula GHmax considerando perdas por deplecionamento em paralelo
if(TipoPerdas == 2)
   GHmax = zeros(nper,nsis,nsim);
   PerdaDeplecinamento = zeros(nper,nsis,nsim);
   for iusi = 1:nusi
      isis = ApontadorSistema(ConfHd(iusi).subsistema);
      for iper = 1:nper
         for isim = 1:nsim
            GHmax(iper,isis,isim) = GHmax(iper,isis,isim) + ...
               CalcPdisp(DadoCadastroUsina(iusi),...
               EAR(iper,isis,isim)/100,...
               ConfHd(iusi).NumMaq(:,iper),...
               ConfHd(iusi).CFuga(iper));
         end
      end
   end
   for iper = 1:nper
      for isis = 1:nsis
         for isim = 1:nsim
            PerdaDeplecinamento(iper,isis,isim) = PinstH(iper,isis) - ...
               GHmax(iper,isis,isim);
         end
      end
   end
end

%--> Calcula GHmax considerando a potencia disponivel lida do SUISHI
if (TipoPerdas==3)
   GHmax = pdisp_sist_rev;
end