#Тестовое задание 

[Файл задания.docx](https://github.com/Gladn/FinTech-TEST-/files/13582221/Zadanie_C.docx)

**Общие требования:**
Для реализации необходимо использовать C# (не позднее __.net Core 6__) и SQL (__MS SQL__, SQL Lite). 
Приложение должно быть готово для проверки:


•	БД содержит необходимые данные - может генерироваться самим приложением или предоставлена отдельно. 

•	Конфигурационные файлы правильно настроены - строки подключения, пути должны быть "универсальными".

**Задание:**

Есть 2 таблицы:
  __Product__

| Id   | Name                | Price     |
|------|---------------------|-----------|
| bigint | varchar(100)       | Decimal(20,2) |
| Уникальный идентификатор (Primary Key) | Наименование изделия | Цена покупки/сборки изделия |

  __Links__
| Column        | Type      | Description                                       |
|---------------|-----------|---------------------------------------------------|
| UpProduct     | bigint    | Ссылка на вышестоящее изделие                     |
| Product       | bigint    | Ссылка на текущее изделие                          |
| Count         | int       | Количество текущих изделий, входящих в вышестоящее |

Необходимо реализовать приложение, в котором есть возможность хранения, добавления, редактирования и удаления данных из этих таблиц.
Необходимо сформировать иерархический отчет в MS Excel, в котором отразить количество и стоимость изделий и общее количество входящих изделий. Количество отображаемых уровней должно задаваться перед формирование отчёта у пользователя.

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
**Выполнение:**
Для реализации использовалися .NET 6 и MS SQL. 

•	БД предоставлена отдельно .bak файлом, так же имеется sql файл на всякий.

•	Строка подключения стоит localhost.

Для начала нужно разобраться с примером и условиями. Таблица была испралена настолько насколько я понял. 
Вот файл excel с формулами.

--Таблица__

Немного не понятно выходит с ссылками, например Изделие 3 одновременно имеет 2 родителя и имеет дочерний Изделие 5. Если проводить расчеты в Изделие 7, то дочерний Изделие 3 обладает ссылкой на дочернее Изделие 5. 

Прилагается АРХИВ файл, с базой/ кодом и exe файлом. В программе используется Entity Framework.  

Немного о вкладках 

Вкладка таблицы Product

Вкладка таблицы Links 

Вкладка отчета
