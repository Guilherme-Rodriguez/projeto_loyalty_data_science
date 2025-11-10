with tb_freq_valor as (

    SELECT idCliente,
        count(DISTINCT substr(DtCriacao, 0, 11)) AS qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
        sum(abs(QtdePontos)) as qtdePontosAbs 

    FROM transacoes

    WHERE DtCriacao < '2025-09-01'
    AND DtCriacao >= date('2025-09-01', '-28 day')

    GROUP BY idCliente
    ORDER BY DtCriacao DESC

),

tb_cluster AS (

    select *,
    IdCliente,
        case 
            when qtdeFrequencia <= 10 AND qtdePontosPos > 1500 THEN '12-HYPERS'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 then '22-EFICIENTES'
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISOS'
            WHEN qtdeFrequencia > 10 and qtdePontosPos >= 750 THEN '21-ESFORCADOS'
            WHEN qtdeFrequencia < 5 THEN '00-LURKER'
            WHEN qtdeFrequencia <= 10 then '01-PREGUICOSO'
            WHEN qtdeFrequencia > 10 then '20-POTENCIAL'

        END as cluster
    from tb_freq_valor

)

SELECT *

FROM tb_cluster
;