WITH tb_transacao AS (
    SELECT *,
           substr(DtCriacao, 1, 10) AS dtDia,
            cast(substr(DtCriacao, 12, 2) as int) AS dtHora
    FROM transacoes
    WHERE DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (
    SELECT 
        IdCliente,

        COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,

        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7  day') THEN dtDia END) AS qtdeAtivacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,

        COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,

        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7  day') THEN IdTransacao END) AS qtdeTransacaoD7,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
        COUNT(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,

        SUM(qtdePontos) AS saldoVida,

        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7  day') THEN qtdePontos ELSE 0 END)  AS saldoD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7  day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-7  day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD7,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD14,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD28,
        SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD56,

        count(CASE WHEN dtHora between 10 and 14 then IdTransacao END) as qtdeTransacaoManha,
        count(CASE WHEN dtHora between 15 and 21 then IdTransacao END) as qtdeTransacaoTarde,
        count(CASE WHEN dtHora > 21 OR dtHora < 10 then IdTransacao END) as qtdeTransacaoNoite,

        1.* count(CASE WHEN dtHora between 10 and 14 then IdTransacao END)/ count(IdTransacao) as pctTransacaoManha,
        1.* count(CASE WHEN dtHora between 15 and 21 then IdTransacao END)/ count(IdTransacao) as pctTransacaoTarde,
        1.* count(CASE WHEN dtHora > 21 OR dtHora < 10 then IdTransacao END)/ count(IdTransacao) as pctTransacaoNoite
    FROM tb_transacao
    GROUP BY IdCliente
),

tb_agg_calc AS (
    SELECT 
        *,
        COALESCE(1.0 * qtdeTransacaoVida / qtdeAtivacaoVida, 0) AS QtdeTransacaoDiaVida,
        COALESCE(1.0 * qtdeTransacaoD7  / qtdeAtivacaoD7,  0) AS QtdeTransacaoDiaD7,
        COALESCE(1.0 * qtdeTransacaoD14 / qtdeAtivacaoD14, 0) AS QtdeTransacaoDiaD14,
        COALESCE(1.0 * qtdeTransacaoD28 / qtdeAtivacaoD28, 0) AS QtdeTransacaoDiaD28,
        COALESCE(1.0 * qtdeTransacaoD56 / qtdeAtivacaoD56, 0) AS QtdeTransacaoDiaD56,

        COALESCE(1.0 * qtdeAtivacaoD28 / 28, 0) AS pctAtivacaoMAU

    FROM tb_agg_transacao
),

tb_horas_dia AS (

    SELECT IdCliente,
            dtDia,
            24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao)))  as duracao

    FROM tb_transacao
    GROUP BY IdCliente, dtDia

),

tb_horas_cliente as (
    SELECT IdCliente,
            sum(duracao) as qtdeHorasVida,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-7  day') THEN duracao ELSE 0 END)  AS qtdeHorasD7,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
            
    FROM tb_horas_dia
    group by IdCliente

),

tb_lag_dia as (

    SELECT idCliente, 
            dtDia,
            LAG(dtDia) over (PARTITION by idCliente order by dtDia) as lagDia
            
    FROM tb_horas_dia

),

tb_intervalo_dias as (

    SELECT *,
            avg(julianday(dtDia) - julianday(lagDia)) AS avgIntervaloDias,
            avg(case when dtDia >= date('2025-10-01', '-28 day') then julianday(dtDia) - julianday(lagDia) else null end) AS avgIntervaloDiasD28

    FROM tb_lag_dia
    group by idCliente
),

tb_join as (
    select t1.*,
            t2.qtdeHorasVida,
            t2.qtdeHorasD7,
            t2.qtdeHorasD14,
            t2.qtdeHorasD28,
            t2.qtdeHorasD56,
            t3.avgIntervaloDias,
            t3.avgIntervaloDiasD28
    from tb_agg_calc as t1

    left join tb_horas_cliente as t2
        on t1.IdCliente = t2.IdCliente 
    left join tb_intervalo_dias as t3
        on t1.IdCliente = t3.IdCliente

)

select * from tb_join;