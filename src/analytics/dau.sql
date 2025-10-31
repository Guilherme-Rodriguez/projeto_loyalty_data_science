select substr(DtCriacao, 0, 11) As DtDia,
        count(DISTINCT IdCliente) as DAU

from transacoes
GROUP BY 1
ORDER BY DtDia