//Основы работы с документо-ориентированной СУБД MongoDB.

// 3.1 Отобразить коллекции базы данных
// show collections;

// 3.2 Вставка записей
// • Вставка одной записи insertOne
db.warehouses.deleteMany({ name: "Центральный склад" });
db.warehouses.insertOne({
    name: "Центральный склад",
    address: "ул. Центральная, 1",
    capacity: 5000,
    manager: "Иванов Иван Иванович"
});

// • Вставка нескольких записей insertMany
db.products.insertMany([
    {
        name: "Смартфон Samsung Galaxy S21",
        category: "Электроника",
        price: 52990,
        manufacturer: "Samsung",
    },
    {
        name: "Ноутбук HUAWEI MateBook D 15",
        category: "Электроника",
        price: 47999,
        manufacturer: "HUAWEI",
    },
    {
        name: "Наушники JBL Tune 520BT",
        category: "Аксессуары",
        price: 3899,
        manufacturer: "JBL",
    }
]);

db.suppliers.insertMany([
    {
        company_name: "ЭлектронИмпорт",
        contact_person: "Смирнов Алексей Петрович",
        phone: "+7 (495) 123-45-67",
        email: "info@electronimport.ru",
        supplied_categories: ["Электроника", "Компьютеры", "Бытовая техника"]
    },
    {
        company_name: "ТехноПоставка",
        contact_person: "Кузнецова Ольга Владимировна",
        phone: "+7 (812) 987-65-43",
        email: "sales@tehnopostavka.com",
        supplied_categories: ["Электроника", "Аксессуары"]
    },
    {
        company_name: "ОфисГаджет",
        contact_person: "Петров Игорь Сергеевич",
        phone: "+7 (343) 456-78-90",
        email: "order@officegadget.ru",
        supplied_categories: ["Аксессуары", "Канцелярия"]
    },
])


// 3.3 Удаление записей
// • Удаление одной записи по условию deleteOne
db.products.deleteOne({
    category: "Аксессуары"
});

// • Удаление нескольких записей по условию deleteMany
db.products.deleteMany({ 
    category: "Электроника" 
});


// 3.4 Поиск записей
// • Поиск по ID
db.products.findOne({
    _id: ObjectId("680a9e651cc5056d3db5f8a3")
});

// • Поиск записи по атрибуту первого уровня
db.products.find({
    manufacturer: "Samsung"
});

// • Поиск записи по вложенному атрибуту
db.warehouses.find({ 
    "address.country": "Россия" 
})

// • Поиск записи по нескольким атрибутам (логический оператор AND)
db.products.find({
    category: "Электроника",
    price: {$gt: 50000}
});

// • Поиск записи по одному из условий (логический оператор OR)
db.products.find({
    $or:
    [
        {category: "Электроника"},
        {price: {$lt: 10000}}
    ]
}
);

// • Поиск с использованием оператора сравнения
db.products.find({ 
    price: { $gte: 30000 } 
});

// • Поиск с использованием двух операторов сравнения
db.products.find({ 
    price: { $gt: 10000, $lt: 50000 } 
});

// • Поиск по значению в массиве
db.suppliers.find({
    supplied_categories: { $in : ["Электроника", "Аксессуары"]}
})

// • Поиск по количеству элементов в массиве
db.suppliers.find({
    supplied_categories: {$size: 2}
});

// • Поиск записей без атрибута
db.products.find({
    manufacturer: {$exists: false}
});

// 3.5 Обновление записей
// • Изменить значение атрибута у записи
db.products.updateOne(
    {_id: ObjectId("680a9e651cc5056d3db5f8a4")} , 
    {$set: {price: 59999}}
);

// • Удалить атрибут у записи
db.products.updateOne(
    {name: "Наушники JBL Tune 520BT"},
    {$unset: {manufacturer: ""}}
);

// • Добавить атрибут записи
db.warehouses.updateOne(
    {name: "Центральный склад"},
    {
        $set : {
            address : {
                streat : "ул.Центральная, 1",
                country: "Россия"
            }
        }
    }
);