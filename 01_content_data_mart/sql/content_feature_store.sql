-- Витрина контента для рекомендательной системы
-- Версия для портфолио (структура сохранена, названия обезличены)

WITH content_tags AS (
    SELECT
        feed_id,
        array_agg(tag_id)       AS tag_ids,
        array_agg(is_auto_tag)  AS is_auto_tag,
        array_agg(tag_title)    AS tag_titles,
        array_agg(tag_url_path) AS tag_url_paths
    FROM (
        SELECT
            'article-' || CAST(a.article_id AS varchar) AS feed_id,
            a.tag_id,
            FALSE                    AS is_auto_tag,
            t.title                  AS tag_title,
            t.url_part               AS tag_url_path
        FROM raw.article_tags a
        LEFT JOIN dct.tags t ON a.tag_id = t.tag_id

        UNION ALL

        SELECT
            'recipe-' || CAST(r.recipe_id AS varchar) AS feed_id,
            r.tag_id,
            r.is_auto               AS is_auto_tag,
            t.title                 AS tag_title,
            t.url_part              AS tag_url_path
        FROM raw.recipe_tags r
        LEFT JOIN dct.tags t ON r.tag_id = t.tag_id
    ) s
    GROUP BY feed_id
),
favorites AS (
    SELECT feed_id, COUNT(*) AS add_to_fav_count
    FROM ods.content_favorites
    GROUP BY feed_id
),
comments AS (
    SELECT feed_id, array_agg(comment) AS comments
    FROM ods.content_comments
    GROUP BY feed_id
),
recipe_steps AS (
    SELECT
        feed_id,
        array_agg(step_description) AS recipe_steps,
        array_agg(step_order)       AS recipe_steps_order
    FROM ods.recipe_steps
    GROUP BY feed_id
)
SELECT
    m.feed_id,
    m.material_id,
    m.material_type,
    m.author_id,
    m.status,
    m.is_adult,
    m.is_ugc,
    m.title,
    m.url,
    m.created_at,
    m.published_at,
    b.breadcrumb_path,
    c.comments,
    ct.tag_ids,
    ct.is_auto_tag,
    ct.tag_titles,
    ct.tag_url_paths,
    r.rating_count,
    r.rating_sum,
    f.add_to_fav_count,
    a.content_json          AS article_content,
    rcp.total_cooking_time,
    rcp.difficulty_level,
    rs.recipe_steps,
    rs.recipe_steps_order
FROM dm.content_materials m
LEFT JOIN content_tags ct    ON m.feed_id = ct.feed_id
LEFT JOIN comments c         ON m.feed_id = c.feed_id
LEFT JOIN favorites f        ON m.feed_id = f.feed_id
LEFT JOIN ods.content_rating r ON m.feed_id = r.feed_id
LEFT JOIN ods.articles a     ON m.feed_id = a.feed_id
LEFT JOIN ods.recipes rcp    ON m.feed_id = rcp.feed_id
LEFT JOIN recipe_steps rs    ON m.feed_id = rs.feed_id
LEFT JOIN dct.breadcrumbs b  ON m.breadcrumb_id = b.id
WHERE m.material_type IN ('article', 'recipe');