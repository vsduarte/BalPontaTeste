function PDisp = CalcPdisp(DadoUsina, Vol_pu, NumMaq, ~)
% calcPdisp     Calcula a Pot�ncia dispon�vel de uma usina hidroel�trica.
%   calcPdisp(DadoUsina,Vol_pu,NumMaq) retorna a pot�ncia dispon�vel
%   da usina hidroel�trica cujos dados est�o contidos na estrutura DadoUsina
%   considerando o volume Vol_pu, dado em p.u. do volume �til da usina, 
%   para uma configura��o que cont�m NumMaq m�quinas em cada conjunto. NumMaq �
%   um veror que cont�m NumConj posi��es.
%
%   calcPdisp(DadoUsina,Vol_pu,NumMaq,CFuga) retorna a pot�ncia
%   dispon�vel da usina hidroel�trica numUsi, considerando a cota do canal
%   de fuga informada em CFuga, em metros. Caso CFuga n�o seja informado,
%   ser� adotada a cota que est� na estrutura DadoUsina.

if (nargin > 4)
    CFuga = varargin{1};
else
    CFuga = DadoUsina.CanalFuga;
end

%---> Calcula altura de queda
Vol_hm = Vol_pu * (DadoUsina.VolMax - DadoUsina.VolMin) + DadoUsina.VolMin;
Cota_Sup = 0;
for i = 1:5
    Cota_Sup = Cota_Sup + DadoUsina.PCV(i) * Vol_hm ^ (i-1);
end
if (DadoUsina.TipoPerdas == 1)
    h = (Cota_Sup - CFuga)*(1 - DadoUsina.Perdas/100);
else
    h = Cota_Sup - CFuga - DadoUsina.Perdas;
end

%---> Calcula PDisp
if (DadoUsina.TipoTurb == 1)
    k = 1.5;
else
    k = 1.2;
end
PDisp = 0;
for i = 1:DadoUsina.NumCnjMaq
	PDisp = PDisp + DadoUsina.Potef(i) * NumMaq(i) * ...
        min(1,h/DadoUsina.HEf(i))^k;
end
%PDisp = PDisp * (100 - DadoUsina.TEIF)/100 * (100-DadoUsina.IP)/100;

end