with tb_daily as (


    select DISTINCT
        date(substr(DtCriacao, 0, 11)) As DtDia,
        IdCliente

    from transacoes
    order by DtDia

),

tb_distinct_day as (

    select
            DISTINCT(DtDia) as dtRef

    from tb_daily

)

select t1.dtRef,
        count( DISTINCT IdCliente) as MAU,
        count( DISTINCT t2.dtDia) as qtdeDias 
 
from tb_distinct_day as t1

left join tb_daily as t2
on t2.DtDia <= t1.dtRef
and julianday(t1.dtRef) - julianday(t2.DtDia) < 28

group by t1.dtRef
order by t1.dtRef asc 

limit 1000
