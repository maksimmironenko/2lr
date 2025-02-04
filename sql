import mysql.connector

class MyEntity_rep_DB:
    def __init__(self, db_config): #  словарь с конфигурацией подключения к базе данных
        self.db_config = db_config #сохранение настроек подключения
        self.connection = mysql.connector.connect(**db_config) #подключение к бд
        self.cursor = self.connection.cursor(dictionary=True)  # Для удобства работы с результатами в виде словаря

    def get_by_id(self, entity_id):
        # Получить объект по ID
        query = "SELECT * FROM my_entities WHERE id = %s" #выбери  данные из таблицы где айди = указанному значению
        self.cursor.execute(query, (entity_id,)) #отправляет запрос в бд и возвращает результат в виде словоря 
        result = self.cursor.fetchone()
        return result

    def get_k_n_short_list(self, page_number, kolvo):
        # Получить список объектов с определённой страницы
        start = (page_number - 1) * kolvo
        query = "SELECT * FROM my_entities LIMIT %s, %s" #выбираем все столбцы из таблицы 1) нач индкс 2)кол-во строк
        self.cursor.execute(query, (start, kolvo)) # выполняет запрос с лимитом на кол_во элементов 
        result = self.cursor.fetchall()
        return result

    def add_object(self, new_object):
        # Добавить объект в список (сгенерировать новый ID)
        query = "INSERT INTO my_entities (name, value) VALUES (%s, %s)" # добавляет новый обьект в таблицу
        self.cursor.execute(query, (new_object['name'], new_object['value'])) # запрос на добавление данных в таблицу
        self.connection.commit()  # Сохраняем изменения
        # Получаем ID только что добавленной записи
        return self.cursor.lastrowid

    def replace_by_id(self, entity_id, new_object):
        # Заменить объект по ID
        query = "UPDATE my_entities SET name = %s, value = %s WHERE id = %s" # обновляет значение полей у которых совпадает айди с переданным значением 
        self.cursor.execute(query, (new_object['name'], new_object['value'], entity_id)) # обновление данных по заданному айди
        self.connection.commit()
        return self.cursor.rowcount > 0  # Возвращает True, если строка была обновлена

    def delete_by_id(self, entity_id):
        # Удалить объект по ID
        query = "DELETE FROM my_entities WHERE id = %s"
        self.cursor.execute(query, (entity_id,))
        self.connection.commit()
        return self.cursor.rowcount > 0  # Возвращает True, если строка была удалена

    def get_count(self):
        # Получить количество объектов
        query = "SELECT COUNT(*) FROM my_entities"
        self.cursor.execute(query)# запрос на получение общего кол_вообьектов
        result = self.cursor.fetchone()
        return result['COUNT(*)']

    def close(self):
        # Закрываем соединение с базой данных
        self.cursor.close()
        self.connection.close()


if __name__ == "__main__":
    db_config = {
        'user': 'root',
        'password': '111111',
        'host': 'localhost',
        'database': 'your_database'
    }

    database_manager = MyEntity_rep_DB(db_config)

    # Пример добавления объекта
    new_object = {'name': 'Объект 1', 'value': 100}
    new_id = database_manager.add_object(new_object)
    print(f"Добавлен объект с ID: {new_id}")

    # Пример получения объекта по ID
    obj = database_manager.get_by_id(new_id)
    print("Полученный объект:", obj)

    # Пример получения списка объектов
    objects = database_manager.get_k_n_short_list(2, 20)  # Вторая страница, 20 объектов
    print("Список объектов:", objects)

    # Пример замены объекта
    new_object = {'name': 'Обновлённый объект', 'value': 150}
    database_manager.replace_by_id(new_id, new_object)

    # Пример удаления объекта
    database_manager.delete_by_id(new_id)

    # Пример получения количества объектов
    count = database_manager.get_count()
    print("Количество объектов:", count)

    # Закрытие соединения
    database_manager.close()
