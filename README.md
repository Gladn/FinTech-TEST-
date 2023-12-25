# Тестовое задание 
(О выполнении ниже)

[Файл задания.docx](https://github.com/Gladn/FinTech-TEST-/files/13631384/Zadanie_C.docx)

**Общие требования:**
Для реализации необходимо использовать C# (не позднее __.net Core 6__) и SQL (__MS SQL__, SQL Lite). 
Приложение должно быть готово для проверки:


•	БД содержит необходимые данные - может генерироваться самим приложением или предоставлена отдельно. 

•	Конфигурационные файлы правильно настроены - строки подключения, пути должны быть "универсальными".

**Задание:**

Есть 2 таблицы:
  __Product__

| Column  | Type          | Description                             |
|---------|---------------|-----------------------------------------|
| ID      | bigint        | Уникальный идентификатор (Primary Key)  |
| Name    | varchar(100)  | Наименование изделия                     |
| Price   | Decimal(20,2) | Цена покупки/сборки изделия             |

  __Links__
| Column        | Type      | Description                                       |
|---------------|-----------|---------------------------------------------------|
| UpProduct     | bigint    | Ссылка на вышестоящее изделие                     |
| Product       | bigint    | Ссылка на текущее изделие                          |
| Count         | int       | Количество текущих изделий, входящих в вышестоящее |

Необходимо реализовать приложение, в котором есть возможность хранения, добавления, редактирования и удаления данных из этих таблиц.
Необходимо сформировать иерархический отчет в MS Excel, в котором отразить количество и стоимость изделий и общее количество входящих изделий. 

**Условия:**

Количество изделия на первом уровне иерархии принимаем равным 1. 

Стоимость изделия - количество по изделию, умноженное на цену по изделию, плюс стоимость всех изделий нижестоящих уровней.

Общее количество входящих изделий - сумма входящих изделий плюс произведение их количества на общее количество входящих изделий.

**Пример отчета:**

| Изделие   | Кол-во | Стоимость | Цена | Кол-во входящих |
|-----------|--------|-----------|------|------------------|
| Изделие 1 | 1      | 3000      | 800  | 23               |
| &nbsp;&nbsp;&nbsp;Изделие 2 | 10     | 1000      | 1000 | 0                |
| &nbsp;&nbsp;&nbsp;Изделие 3 | 2      | 1000      | 400  | 4                |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Изделие 5 | 2      | 600       | 300  | 0                |
| &nbsp;&nbsp;&nbsp;Изделие 4 | 1      | 600       | 400  | 6                |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Изделие 2 | 1      | 100       | 100  | 0                |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Изделие 6 | 5      | 100       | 20   | 0                |
| Изделие 7 | 1      | 7000      | 1000 | 40               |
| &nbsp;&nbsp;&nbsp;Изделие 8 | 20     | 2000      | 100  | 0                |
| &nbsp;&nbsp;&nbsp;Изделие 3 | 10     | 4000      | 400  | 20               |

---------
# Выполнение: 
Для реализации использовались .NET 6 / WPF / MVVM и MS SQL. Из доп пакетов ORM - Entity Framework Core, XmlReader - EPPlus. 

•	БД предоставлена отдельно .bak файлом, так же имеется mdf файл в архиве и sql файл.

•	Строка подключения стоит localhost (думаю это универсальный вариант).

Для начала нужно разобраться с примером и условиями. Таблица была исправлена настолько насколько я понял. 
Вот примерный файл excel [Книга1.xlsx](https://github.com/Gladn/FinTech-TEST-/files/13631592/1.xlsx).

![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/4dfeb94a-7b66-4ee4-b102-725ef032eb83)



Немного не понятно выходит с ссылками, например Изделие 3 одновременно имеет 2 родителя и имеет дочерний Изделие 5. Если проводить расчеты в Изделие 7, то дочерний Изделие 3 обладает ссылкой на дочернее в любом из случаев. (Похоже на отношение многие ко многим внутри иерархии и решение скорее сего в создании еще одной таблице, которая обновлялась бы за счет триггеров) А именно можно проосто зациклить рекурсию.
 [Ссылка на stackoverflow](https://stackoverflow.com/questions/23223333/data-structure-for-many-to-many-hierarchies-in-sql-server)




Прилагается архив файл, с базой / кодом и исполнимым файлом.    


**Вкладки приложения:**

Вкладка#1 таблицы Product


• Добавление / редактирование / удаление изделий










![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/29a34445-411c-49ab-93db-23e2d5f3706e)


Вкладка#2 таблицы Links: 

• Получение новых изделий

• Добавление / редактирование / удаление ссылок изделий







![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/c3c77075-c6b8-4d6e-92d3-90dec8b25245)








Процедура отчета в MS SQL (Были решены с дубликатами на одном уровне, проблема с ссылками на разных уровнях, ибо необходимо отслеживание родителя на всех уровнях):


![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/627c1142-afea-41e2-9768-b1a17990f9d0)



Вкладка#3 Отчет:

• Обноление новых ссылок

• Вывод отчета в excel


![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/8c72e06d-3eaf-41a5-af36-3e683791d200)



Отчет в Excel:

![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/99e360c1-63a2-4ecf-a2c6-e73a4f51f164)





