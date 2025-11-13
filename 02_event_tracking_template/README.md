# Кейс 2. Шаблонизация событийной аналитики по регулярным спецпроектам

## Описание
Единый шаблон для событийной разметки лендингов X5 Media.  
Позволяет стандартизировать сбор событий в Яндекс.Метрике и их загрузку в DWH.

## Цель
Создать универсальную структуру событий, которую можно быстро адаптировать под любой спецпроект.  
Обеспечить сквозную совместимость данных между GTM, Метрикой и DWH.

## Пример типового события

### 1. Событие в Data Layer (GTM)
```javascript
// dataLayer (GTM)
dataLayer.push({
    event: 'food',
    event_name: 'click_button',
    event_content: 'play_button',
    event_context: 'game_screen',
    event_random: 92735192,
    timestamp_millis: 1730981123123,
    page_info: '{"page_type": "SpecialProject"}'
});
```
### 2. Событие в Яндекс.Метрике
```javascript
// Yandex.Metrika
ym(12345678, 'reachGoal', 'click_button', {
    event_content: 'play_button',
    event_context: 'game_screen',
    event_random: 92735192,
    timestamp_millis: 1730981123123,
    page_info: '{"page_type": "SpecialProject"}'
});
```


## Архитектура потока данных
Frontend → Y.Metrika/dataLayer → RAW → ODS → DM → REP

## Схема таблиц
| Таблица | Назначение |
|----------|-------------|
| raw_yandex_events | Логи Яндекс.Метрики |
| ods_yandex_events | Очистка и нормализация событий |
| dm_yandex_events | Агрегированные показатели |
| rep_special_projects_events | Итоговые отчёты по всем лендингам |

## Результат
- Сократилось время подготовки ТЗ, время создания дэшбордов
- Унификация структуры событий  
- Создана витрина `rep_special_projects_events`  
- Повышена точность аналитики и сопоставимость данных

## Роль и зона ответственности
- Разработка шаблона ТЗ и модели данных  
- Согласование формата событий с фронтендом  
- SQL-трансформации для REP слоя
- Контроль качества данных на всём пути front → DWH → BI