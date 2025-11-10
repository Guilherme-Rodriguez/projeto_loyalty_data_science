WITH tb_usuario_cursos AS (
    SELECT 
        idUsuario,
        descSlugCurso,
        COUNT(descSlugCursoEpisodio) AS qtdeEps
    FROM cursos_episodios_completos
    where dtCriacao < '2025-09-01'
    GROUP BY idUsuario, descSlugCurso
),

tb_cursos_total_eps AS (
    SELECT 
        descSlugCurso,
        COUNT(descEpisodio) AS qtdeTotalEps
    FROM cursos_episodios
    GROUP BY descSlugCurso
),

tb_pct_cursos AS (
    SELECT 
        t1.idUsuario,
        t1.descSlugCurso,
        1.0 * t1.qtdeEps / t2.qtdeTotalEps AS pctCursoCompleto
    FROM tb_usuario_cursos t1
    LEFT JOIN tb_cursos_total_eps t2
        ON t1.descSlugCurso = t2.descSlugCurso
),

tb_pct_cursos_pivot AS (
    SELECT 
        idUsuario,

        -- TOTAL DE CURSOS COMPLETOS E INCOMPLETOS
        SUM(CASE WHEN pctCursoCompleto = 1 THEN 1 ELSE 0 END) AS qtdCursosCompletos,
        SUM(CASE WHEN pctCursoCompleto > 0 AND pctCursoCompleto < 1 THEN 1 ELSE 0 END) AS qtdCursosIncompletos,

        -- PIVOT MANUAL
        SUM(CASE WHEN descSlugCurso = 'python-2025' THEN pctCursoCompleto ELSE 0 END) AS python2025,
        SUM(CASE WHEN descSlugCurso = 'github-2025' THEN pctCursoCompleto ELSE 0 END) AS github2025,
        SUM(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctCursoCompleto ELSE 0 END) AS estatistica2025,
        SUM(CASE WHEN descSlugCurso = 'sql-2025' THEN pctCursoCompleto ELSE 0 END) AS sql2025,
        SUM(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctCursoCompleto ELSE 0 END) AS pandas2025,
        SUM(CASE WHEN descSlugCurso = 'sql-2020' THEN pctCursoCompleto ELSE 0 END) AS sql2020,
        SUM(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctCursoCompleto ELSE 0 END) AS pandas2024,
        SUM(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctCursoCompleto ELSE 0 END) AS estatistica2024,
        SUM(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctCursoCompleto ELSE 0 END) AS mlflow2025,
        SUM(CASE WHEN descSlugCurso = 'github-2024' THEN pctCursoCompleto ELSE 0 END) AS github2024,
        SUM(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctCursoCompleto ELSE 0 END) AS ds_databricks2024,
        SUM(CASE WHEN descSlugCurso = 'ml-2024' THEN pctCursoCompleto ELSE 0 END) AS ml2024,
        SUM(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctCursoCompleto ELSE 0 END) AS lago_mago2024,
        SUM(CASE WHEN descSlugCurso = 'loyalty-predict-2025' THEN pctCursoCompleto ELSE 0 END) AS loyaltypredict2025,
        SUM(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctCursoCompleto ELSE 0 END) AS machine_learning2025,
        SUM(CASE WHEN descSlugCurso = 'python-2024' THEN pctCursoCompleto ELSE 0 END) AS python2024,
        SUM(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctCursoCompleto ELSE 0 END) AS trampar_lakehouse2024,
        SUM(CASE WHEN descSlugCurso = 'carreira' THEN pctCursoCompleto ELSE 0 END) AS carreira,
        SUM(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctCursoCompleto ELSE 0 END) AS coleta_dados2024,
        SUM(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctCursoCompleto ELSE 0 END) AS streamlit2025,
        SUM(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctCursoCompleto ELSE 0 END) AS ds_pontos2024,
        SUM(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctCursoCompleto ELSE 0 END) AS ia_canal2025,
        SUM(CASE WHEN descSlugCurso = 'tse-analytics-2024' THEN pctCursoCompleto ELSE 0 END) AS tse_analytics2024

    FROM tb_pct_cursos
    GROUP BY idUsuario
),

tb_atividade AS (
    SELECT
        idUsuario,
        idRecompensa AS descAtividade,
        max(dtRecompensa) AS dtCriacao
    FROM recompensas_usuarios
    group by idUsuario

    UNION ALL

    SELECT
        idUsuario,
        descNomeHabilidade AS descAtividade,
        max(dtCriacao) AS dtCriacao
    FROM habilidades_usuarios
    GROUP BY idUsuario

    UNION ALL

    SELECT
        idUsuario,
        descSlugCurso AS descAtividade,
        dtCriacao
    FROM cursos_episodios_completos
),


tb_ultima_atividade as (
SELECT idUsuario,
        MIN(julianday('2025-10-01') - julianday(dtCriacao)) AS qtdDiasUltiAtividade
FROM tb_atividade
group by idUsuario
)

select t1.*,
        t2.qtdDiasUltiAtividade

from tb_pct_cursos_pivot as t1

left join tb_ultima_atividade as t2
    on t1.idUsuario = t2.idUsuario



