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



Немного не понятно выходит с ссылками, например Изделие 3 одновременно имеет 2 родителя и имеет дочерний Изделие 5. Если проводить расчеты в Изделие 7, то дочерний Изделие 3 обладает ссылкой на дочернее в любом из случаев. (Похоже на отношение многие ко многим внутри иерархии) А именно можно проосто зациклить рекурсию.
 [Ссылка на stackoverflow](https://stackoverflow.com/questions/23223333/data-structure-for-many-to-many-hierarchies-in-sql-server)




Прилагается архив файл, с базой / кодом и исполнимым файлом.    


**Вкладки приложения:**

Вкладка#1 таблицы Product (добавление / редактирование / удаление):
![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/29a34445-411c-49ab-93db-23e2d5f3706e)


Вкладка#2 таблицы Links (обноление / добавление / редактирование / удаление): 
![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/ef16b64b-8ddd-45aa-a6d8-5d85d4f35d92)
(Думаю тут стоило сделать вывод названий изделий в datagrid для удобности и сделать автообновление новой информации из Вкладки 1)


Процедура отчета в MS SQL (Работает с уникальными Product, расчеты верны):


![Screenshot_9](https://github.com/Gladn/FinTech-TEST-/assets/92585647/9e049fb5-8248-46aa-92c9-8701f3191afd)

![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/2b69ff1d-4a8b-44b6-9903-0c2888c97744)


Вкладка#3 Отчет:
![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/b0e4f106-655b-4fc8-8784-c99dc1618f21)


Отчет в Excel:
![изображение](https://github.com/Gladn/FinTech-TEST-/assets/92585647/7886dfd2-d2d0-43e3-ad98-eb3cde76d7fe)




