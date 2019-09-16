// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yabr.os/
// ----------------------------------------------------------

Перем ПараметрыОбработкиДанных;
Перем АктивныеОбработчики;
Перем РабочиеКаталоги;

Перем Лог;

#Область ПрограммныйИнтерфейс

// Процедура - устанавливает рабочий каталог
//
// Параметры:
//  Псевдоним    - Строка      -  псевдоним рабочего каталога для подстановки
//  Путь         - Строка      -  путь к рабочему каталогу
//
Процедура ДобавитьРабочийКаталог(Знач Псевдоним, Знач Путь) Экспорт
	
	Если НЕ ТипЗнч(РабочиеКаталоги) = Тип("Соответствие") Тогда
		РабочиеКаталоги = Новый Соответствие();
	КонецЕсли;
	
	РабочиеКаталоги.Вставить(Псевдоним, Путь);
	
КонецПроцедуры // ДобавитьРабочийКаталог()

// Функция - возвращает рабочий каталог по указанному псевдониму
//
// Параметры:
//  Псевдоним    - Строка      -  псевдоним рабочего каталога
//
// Возвращаемое значение:
//  Строка      - текущий рабочий каталог
//
Функция РабочийКаталог(Знач Псевдоним = "$workDir") Экспорт
	
	Возврат РабочиеКаталоги.Получить(Псевдоним);
	
КонецФункции // РабочийКаталог()

// Функция - возвращает параметры обработки данных
//
// Возвращаемое значение:
//  Структура                  - настройки обработки данных
//       *ПутьКОбработке       - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки   - Строка                 - имя процедуры обработки данных
//       *Параметры            - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>  - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки         - Строка                 - имя внешней обработки после подключения
//       *Обработчики          - Массив(Структура)      - массив обработчиков данных,
//                                                        полученных от обработки текущего уровня
//                                                        (состав полей элемента аналогичен текущему уровню) 
//
Функция ПараметрыОбработкиДанных() Экспорт
	
	Возврат ПараметрыОбработкиДанных;
	
КонецФункции // ПараметрыОбработкиДанных()

// Процедура - устанавливает параметры обработки данных
//
// Параметры:
//  НовыеПараметрыОбработкиДанных    - Структура, Строка      - новые параметры обработки данных
//                                     Файл, ДвоичныеДанные
//  Если тип параметра - Структура, то содержит следующие поля:
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура УстановитьПараметрыОбработкиДанных(Знач НовыеПараметрыОбработкиДанных) Экспорт
	
	ПроверитьДопустимостьТипа(НовыеПараметрыОбработкиДанных,
	                          "Строка, Файл, ДвоичныеДанные, Структура, Массив",
	                          СтрШаблон("Некорректно указаны параметры обработки данных ""%1"",",
	                                    СокрЛП(НовыеПараметрыОбработкиДанных)) +
							  ", тип ""%1"", ожидается тип %2!");
	
	Если ТипЗнч(НовыеПараметрыОбработкиДанных) = Тип("Структура")
	 ИЛИ ТипЗнч(НовыеПараметрыОбработкиДанных) = Тип("Массив") Тогда
		ПараметрыОбработкиДанных = НовыеПараметрыОбработкиДанных;
	Иначе
		ПараметрыОбработкиДанных = ПрочитатьПараметрыОбработкиДанных(НовыеПараметрыОбработкиДанных);
	КонецЕсли;
	
КонецПроцедуры // УстановитьПараметрыОбработкиДанных()

// Функция - читает и возвращает параметры обработки данных из файла JSON, указанного в поле "ПутьКФайлу"
//
// Параметры:
//  ПараметрыОбработки         - Строка, Файл,          - параметры обработки данных в формате JSON,
//                               ДвоичныеДанные           путь к файлу, файл или двоичные данные
//                                                        параметров обработки данных в формате JSON
// Возвращаемое значение:
//  Структура                  - настройки обработки данных
//       *ПутьКОбработке       - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки   - Строка                 - имя процедуры обработки данных
//       *Параметры            - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>  - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки         - Строка                 - имя внешней обработки после подключения
//       *Обработчики          - Массив(Структура)      - массив обработчиков данных,
//                                                        полученных от обработки текущего уровня
//                                                        (состав полей элемента аналогичен текущему уровню) 
//
Функция ПрочитатьПараметрыОбработкиДанных(Знач ПараметрыОбработки) Экспорт
	
	Лог.Информация("[%1]: Чтение параметров обработки данных: %2", ТипЗнч(ЭтотОбъект), ПараметрыОбработки);

	ПроверитьДопустимостьТипа(ПараметрыОбработки,
	                          "Строка, Файл, ДвоичныеДанные",
	                          СтрШаблон("Некорректно указаны настройки ""%1"",", СокрЛП(ПараметрыОбработки)) +
							  ", тип ""%1"", ожидается тип %2!");
							  
	ПараметрыСтрокой = "";

	Если ТипЗнч(ПараметрыОбработки) = Тип("Строка") Тогда
		Если Лев(СокрЛП(ПараметрыОбработки), 1) = "{" ИЛИ Лев(СокрЛП(ПараметрыОбработки), 1) = "[" Тогда
			ПараметрыСтрокой = ПараметрыОбработки;
		Иначе
			Текст = Новый ТекстовыйДокумент();
			Текст.Прочитать(ПараметрыОбработки, "UTF-8");
			ПараметрыСтрокой = Текст.ПолучитьТекст();
		КонецЕсли;
	ИначеЕсли ТипЗнч(ПараметрыОбработки) = Тип("ДвоичныеДанные") Тогда
		ПараметрыСтрокой = ПолучитьСтрокуИзДвоичныхДанных(ПараметрыОбработки);
	ИначеЕсли ТипЗнч(ПараметрыОбработки) = Тип("Файл") Тогда
		Текст = Новый ТекстовыйДокумент();
		Текст.Прочитать(ПараметрыОбработки.ПолноеИмя, "UTF-8");
		ПараметрыСтрокой = Текст.ПолучитьТекст();
	Иначе
		ВызватьИсключение "Некорректно указаны настройки!";
	КонецЕсли;

	Для Каждого ТекРабочийКаталог Из РабочиеКаталоги Цикл
		ПараметрыСтрокой = СтрЗаменить(ПараметрыСтрокой,
									   ТекРабочийКаталог.Ключ,
									   СтрЗаменить(ТекРабочийКаталог.Значение, "\", "\\"));
	КонецЦикла;

	ЧтениеПараметров = Новый ЧтениеJSON();
	ЧтениеПараметров.УстановитьСтроку(ПараметрыСтрокой);
	
	Возврат ПрочитатьJSON(ЧтениеПараметров, Ложь, , ФорматДатыJSON.ISO);
	
КонецФункции // ПрочитатьПараметрыОбработкиДанных()

// Процедура - выполняет обработку переданных данных с указанными параметрами
//
// Параметры:
//  Данные                           - Произвольный           - данные для обработки
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура ОбработатьДанные(Знач Данные = Неопределено, Знач ОписаниеОбработчика = Неопределено) Экспорт
	
	Если НЕ (ТипЗнч(ОписаниеОбработчика) = Тип("Структура") 
	 ИЛИ ТипЗнч(ОписаниеОбработчика) = Тип("Массив")) Тогда
		ОписаниеОбработчика = ПараметрыОбработкиДанных;
	КонецЕсли;
	
	Если ТипЗнч(ОписаниеОбработчика) = Тип("Массив") Тогда
		Для Каждого ТекОписаниеОбработчика Из ОписаниеОбработчика Цикл
			ОбработатьДанные(Данные, ТекОписаниеобработчика);
		КонецЦикла;
		Возврат;
	Иначе
		Лог.Отладка("[%1]: Обработка данных (%2): %3", ТипЗнч(ЭтотОбъект), ОписаниеОбработчика.ИмяОбработки, Данные);
	КонецЕсли;
	
	ИнициализироватьОбработчикДанных(ОписаниеОбработчика);

	Если НЕ Данные = Неопределено Тогда
		ОписаниеОбработчика.Обработка.УстановитьДанные(Данные);
	КонецЕсли;
		
	УстановитьПараметрыОбработчика(ОписаниеОбработчика);

	Если ОписаниеОбработчика.Свойство("ПроцедураОбработки") Тогда
		Выполнить("ОписаниеОбработчика.Обработка." + ОписаниеОбработчика.ПроцедураОбработки + "()");
	Иначе
		ОписаниеОбработчика.Обработка.ОбработатьДанные();
	КонецЕсли;
	
КонецПроцедуры // ОбработатьДанные()

// Процедура - обратного вызова (callback) выполняет вызов обработчиков для переданных данных
//
// Параметры:
//  Данные           - Строка     - данные для обработки
//  ИдОбработчика    - Строка     - идентификатор обработчика
//
Процедура ПродолжениеОбработкиДанных(Знач Данные, Знач ИдОбработчика) Экспорт
	
	ОписаниеОбработчика = АктивныеОбработчики.Получить(ИдОбработчика);
	
	Лог.Отладка("[%1]: Продолжение обработки результатов ""%2""", ТипЗнч(ЭтотОбъект), ОписаниеОбработчика.ИмяОбработки);

	Если НЕ ОписаниеОбработчика.Свойство("Обработчики") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ТипЗнч(ОписаниеОбработчика.Обработчики) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекОбработчик Из ОписаниеОбработчика.Обработчики Цикл
		Лог.Отладка("[%1]: Передача результатов для обработки в ""%2""", ТипЗнч(ЭтотОбъект), ТекОбработчик.ИмяОбработки);

		ОбработатьДанные(Данные, ТекОбработчик);
	КонецЦикла;
	
КонецПроцедуры // ПродолжениеОбработкиДанных()

// Процедура - обратного вызова (callback) выполняет вызов завершение обработки данных для всех обработчиков
//
// Параметры:
//  ИдОбработчика    - Строка     - идентификатор обработчика
//
Процедура ЗавершениеОбработкиДанных(Знач ИдОбработчика) Экспорт
	
	ОписаниеОбработчика = АктивныеОбработчики.Получить(ИдОбработчика);
	
	Лог.Отладка("[%1]: Завершение обработки результатов ""%2""", ТипЗнч(ЭтотОбъект), ОписаниеОбработчика.ИмяОбработки);

	Если НЕ ОписаниеОбработчика.Свойство("Обработчики") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ТипЗнч(ОписаниеОбработчика.Обработчики) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекОбработчик Из ОписаниеОбработчика.Обработчики Цикл
		Лог.Отладка("[%1]: Передача результатов для завершения обработки в ""%2""",
					ТипЗнч(ЭтотОбъект),
					ТекОбработчик.ИмяОбработки);

		ИнициализироватьОбработчикДанных(ТекОбработчик);

		УстановитьПараметрыОбработчика(ТекОбработчик);

		ТекОбработчик.Обработка.ЗавершениеОбработкиДанных();
	КонецЦикла;
	
КонецПроцедуры // ЗавершениеОбработкиДанных()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Функция - возвращает объект управления логированием
//
// Возвращаемое значение:
//  Объект      - объект управления логированием
//
Функция Лог() Экспорт
	
	Возврат Лог;

КонецФункции // Лог()

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("PATH",
					 "./yabrsettings.json",
					 "путь к файлу настроек обработки данных (по умолчанию: ./yabrsettings.json)")
	       .ТСтрока()
	       .Обязательный(Ложь)
	       .ВОкружении("YABR_SETTINGS");
	Команда.Опция("w work-dir", "", "Рабочий каталог")
	       .ТСтрока()
	       .ВОкружении("YABR_WORKDIR");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	Лог = ПараметрыПриложения.Лог();

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");
	ПараметрыОбработки        = Команда.ЗначениеАргумента("PATH");
	РабочийКаталог            = Команда.ЗначениеОпции("work-dir");

	ПараметрыПриложения.УстановитьРежимОтладкиПриНеобходимости(ВыводОтладочнойИнформации);
						
	Файл = Новый Файл(ПараметрыОбработки);
	ДобавитьРабочийКаталог("$settingsDir", Сред(Файл.Путь, 1, СтрДлина(Файл.Путь) - 1));
	
	Если ЗначениеЗаполнено(РабочийКаталог) Тогда
		ДобавитьРабочийКаталог("$workDir", РабочийКаталог);
	Иначе
		ДобавитьРабочийКаталог("$workDir", ТекущийКаталог());
	КонецЕсли;
	
	Для Каждого ТекРабочийКаталог Из РабочиеКаталоги Цикл
		ПараметрыОбработки = СтрЗаменить(ПараметрыОбработки,
									     ТекРабочийКаталог.Ключ,
									     ТекРабочийКаталог.Значение);
	КонецЦикла;

	УстановитьПараметрыОбработкиДанных(ПараметрыОбработки);

	ОбработатьДанные();

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Процедура - создает внешнюю обработку в соответствии с указанными параметрами
//
// Параметры:
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработка                  - ВнешняяОбработкаОбъект - объект внешней обработки
//                                                              (заполняется в результате выполнения процедуры)
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура ИнициализироватьОбработчикДанных(ОписаниеОбработчика)
	
	Если НЕ ОписаниеОбработчика.Свойство("Обработка") Тогда
	
		ИмяОбработки = Неопределено;
		ОписаниеОбработчика.Свойство("ИмяОбработки", ИмяОбработки);
	
		Если ОписаниеОбработчика.Свойство("ПутьКОбработке") Тогда
			ФайлОбработки = Новый Файл(Описаниеобработчика.ПутьКОбработке);
			
			Если НЕ ЗначениеЗаполнено(ИмяОбработки) Тогда
				ИмяОбработки = ФайлОбработки.ИмяБезРасширения;
				ОписаниеОбработчика.Вставить("ИмяОбработки", ИмяОбработки);
			КонецЕсли;

			Лог.Отладка("[%1]: Подключение обработчика ""%2"" (%3)",
						Тип(ЭтотОбъект),
						ИмяОбработки,
						Описаниеобработчика.ПутьКОбработке);

			ПодключитьСценарий(ОписаниеОбработчика.ПутьКОбработке, ИмяОбработки);
			                                           
		КонецЕсли;
		
		Лог.Отладка("[%1]: Инициализация обработчика ""%2""", ТипЗнч(ЭтотОбъект), ИмяОбработки);

		ОписаниеОбработчика.Вставить("Обработка", Вычислить(СтрШаблон("Новый %1(ЭтотОбъект)", ИмяОбработки)));

		Если НЕ ТипЗнч(АктивныеОбработчики) = Тип("Соответствие") Тогда
			АктивныеОбработчики = Новый Соответствие();
		КонецЕсли;
		Если ОписаниеОбработчика.Свойство("ИдОбработчика") Тогда
			ИдОбработчика = ОписаниеОбработчика.ИдОбработчика;
		Иначе
			ИдОбработчика = СокрЛП(Новый УникальныйИдентификатор());
		КонецЕсли;
		
		ОписаниеОбработчика.Обработка.УстановитьИдентификатор(ИдОбработчика);
		АктивныеОбработчики.Вставить(ИдОбработчика, ОписаниеОбработчика);
			
	КонецЕсли;
	
КонецПроцедуры // ИнициализироватьОбработчикДанных()

// Процедура - устанавливает параметры обработки - обработчика данных
//
// Параметры:
//  ОписаниеОбработчика              - Структура              - описание обработчика данных
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ПроцедураОбработки         - Строка                 - имя процедуры обработки данных
//       *Параметры                  - Строка                 - структура параметров процедуры обработки данных
//           *<Имя параметра>        - Произвольный           - знаечние параметра процедуры обработки данных
//       *ИмяОбработки               - Строка                 - имя внешней обработки после подключения
//       *Обработчики                - Массив(Структура)      - массив обработчиков данных,
//                                                              полученных от обработки текущего уровня
//                                                              (состав полей элемента аналогичен текущему уровню) 
//
Процедура УстановитьПараметрыОбработчика(Знач ОписаниеОбработчика)
	
	ПараметрыДляУстановки = Новый Структура();

	Если ОписаниеОбработчика.Свойство("Параметры") Тогда

		Для Каждого ТекПараметр Из ОписаниеОбработчика.Параметры Цикл

			Лог.Отладка("[%1]: Установка параметра отработчика ""%2 / %3"": ""%4""",
						ТипЗнч(ЭтотОбъект),
						ОписаниеОбработчика.ИмяОбработки,
						ТекПараметр.Ключ,
						ТекПараметр.Значение);

			ПараметрыДляУстановки.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
			Если НЕ ТипЗнч(ТекПараметр.Значение) = Тип("Структура") Тогда
				Продолжить;
			КонецЕсли;
			Если НЕ (ТекПараметр.Значение.Свойство("ИмяОбработки")
			ИЛИ ТекПараметр.Значение.Свойство("ИдОбработчика")) Тогда
				Продолжить;
			КонецЕсли;
			
			ПараметрыДляУстановки[ТекПараметр.Ключ] = ВычислитьЗначениеПараметра(ТекПараметр.Значение);

			Лог.Отладка("[%1]: Вычислено значение параметра отработчика ""%2 / %3"": ""%4""",
						ТипЗнч(ЭтотОбъект),
						ОписаниеОбработчика.ИмяОбработки,
						ТекПараметр.Ключ,
						ПараметрыДляУстановки[ТекПараметр.Ключ]);
		КонецЦикла;
	
	КонецЕсли;

	ОписаниеОбработчика.Обработка.УстановитьПараметрыОбработкиДанных(ПараметрыДляУстановки);
	
КонецПроцедуры // УстановитьПараметрыОбработчика()

// Функция - вычисляет и возвращает значение параметра обработки - обработчика данных
// в случае, когда значение параметра вычисляется в обработке
//
// Параметры:
//  ОписаниеПараметра                - Структура              - описание механизма получения значения параметра
//       *ПутьКОбработке             - Строка                 - путь к файлу внешней обработке
//       *ИмяОбработки               - Строка                 - имя подключенной внешней обработке
//       *Обработка                  - ВнешняяОбработкаОбъект - объект внешней обработки
//                                                              (заполняется в результате выполнения процедуры)
//       *ФункцияПолученияЗначения   - Строка                 - имя функции получения значения параметра
//       *Параметры                  - Массив                 - массив параметров функции получения значения
//
// Возвращаемое значение:
//  Произвольный              - значение параметра
//
Функция ВычислитьЗначениеПараметра(Знач ОписаниеПараметра)
	
	Если НЕ ОписаниеПараметра.Свойство("ФункцияПолученияЗначения") Тогда
		ОписаниеПараметра.Вставить("ФункцияПолученияЗначения", "РезультатОбработки");
	КонецЕсли;
		
	ЗначениеПараметра = Неопределено;
		
	Если ОписаниеПараметра.Свойство("ИдОбработчика") Тогда
		
		ТекОбработчик = АктивныеОбработчики.Получить(ОписаниеПараметра.ИдОбработчика);
		
	ИначеЕсли ОписаниеПараметра.Свойство("ИмяОбработки") Тогда
		
		Если НЕ ОписаниеПараметра.Свойство("Обработка") Тогда
			ОписаниеПараметра.Вставить("Обработка");
		КонецЕсли;
		
		Если ОписаниеПараметра.Обработка = Неопределено Тогда
			ОписаниеПараметра.Обработка = Вычислить(СтрШаблон("Новый %1()", ОписаниеПараметра.ИмяОбработки));
		КонецЕсли;
		
		УстановитьПараметрыОбработчика(ОписаниеПараметра);
		
		ТекОбработчик = ОписаниеПараметра;
	
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
	ЗначенияПараметров = Новый Массив();
	Если ОписаниеПараметра.Свойство("Параметры") И ТипЗнч(ОписаниеПараметра.Параметры) = Тип("Массив") Тогда
		Для Каждого ТекПараметр Из ОписаниеПараметра.Параметры Цикл
			Если ТипЗнч(ТекПараметр) = Тип("Структура") Тогда
				ЗначенияПараметров.Добавить(ВычислитьЗначениеПараметра(ТекПараметр));
			Иначе
				ЗначенияПараметров.Добавить(ТекПараметр);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	СписокПараметров = "";
	Для й = 0 По ЗначенияПараметров.ВГраница() Цикл
		СписокПараметров = СписокПараметров +
						   ?(ПустаяСтрока(СписокПараметров), "", ", ") +
						   СтрШаблон("ЗначенияПараметров[%1]", й);
	КонецЦикла;

	КодВычисленияЗначения = СтрШаблон("ТекОбработчик.Обработка.%1(%2)",
									  ОписаниеПараметра.ФункцияПолученияЗначения,
									  СписокПараметров);

	Попытка
		ЗначениеПараметра = Вычислить(КодВычисленияЗначения);
	Исключение
		ВызватьИсключение СтрШаблон("Ошибка вычисления значения ""%1"":%2%3",
									КодВычисленияЗначения,
									Символы.ПС,
									ПодробноеПредставлениеОшибки(ОписаниеОшибки()));
	КонецПопытки;
	
	Возврат ЗначениеПараметра;
	
КонецФункции // ВычислитьЗначениеПараметра()

// Функция - проверяет тип значения на соответствие допустимым типам
//
// Параметры:
//  Значение             - Произвольный                 - проверяемое значение
//  ДопустимыеТипы       - Строка, Массив(Строка, Тип)  - список допустимых типов
//  ШаблонТекстаОшибки   - Строка                       - шаблон строки сообщения об ошибке
//                                                        ("Некорректный тип значения ""%1"" ожидается тип %2")
// 
// Возвращаемое значение:
//	Булево       - Истина - проверка прошла успешно
//
Функция ПроверитьДопустимостьТипа(Знач Значение, Знач ДопустимыеТипы, Знач ШаблонТекстаОшибки = "") Экспорт
	
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипЗнч(ДопустимыеТипы) = Тип("Строка") Тогда
		МассивДопустимыхТипов = СтрРазделить(ДопустимыеТипы, ",");
	ИначеЕсли ТипЗнч(ДопустимыеТипы) = Тип("Массив") Тогда
		МассивДопустимыхТипов = ДопустимыеТипы;
	Иначе
		ВызватьИсключение СтрШаблон("Некорректно указан список допустимых типов, тип ""%1"" ожидается тип %2!",
		                            Тип(ДопустимыеТипы),
									"""Строка"" или ""Массив""");
	КонецЕсли;
	
	Типы = Новый Соответствие();
	
	СтрокаДопустимыхТипов = "";
	
	Для Каждого ТекТип Из МассивДопустимыхТипов Цикл
		ВремТип = ?(ТипЗнч(ТекТип) = Тип("Строка"), Тип(СокрЛП(ТекТип)), ТекТип);
		Типы.Вставить(ВремТип, СокрЛП(ТекТип));
		Если НЕ СтрокаДопустимыхТипов = "" Тогда
			СтрокаДопустимыхТипов = СтрокаДопустимыхТипов +
				?(МассивДопустимыхТипов.Найти(ТекТип) = МассивДопустимыхТипов.ВГраница(), " или ", ", ");
		КонецЕсли;
	КонецЦикла;
	
	Если ШаблонТекстаОшибки = "" Тогда
		ШаблонТекстаОшибки = "Некорректный тип значения ""%1"" ожидается тип %2!";
	КонецЕсли;
	
	Если Типы[ТипЗначения] = Неопределено Тогда
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, СокрЛП(ТипЗначения), СтрокаДопустимыхТипов);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьДопустимостьТипа()

// Функция - Проверить свойства
//
// Параметры:
//  ПроверяемаяСтруктура     - Структура               - проверяемая структура
//  ОбязательныеСвойства     - Строка, Массив(Строка)  - список обязательных свойств
//  ШаблонТекстаОшибки       - Строка                  - шаблон строки сообщения об ошибке
//                                                       ("Отсутствуют обязательные свойства: %1")
// 
// Возвращаемое значение:
//	Булево       - Истина - проверка прошла успешно
//
Функция ПроверитьСвойства(Знач ПроверяемаяСтруктура, Знач ОбязательныеСвойства, Знач ШаблонТекстаОшибки = "")
	
	ПроверитьДопустимостьТипа(ОбязательныеСвойства,
	                          "Строка, Массив",
	                          "Некорректно указан список обязательных свойств, тип ""%1"", ожидается тип %2!");
							  
	Если ТипЗнч(ОбязательныеСвойства) = Тип("Строка") Тогда
		МассивСвойств = СтрРазделить(ОбязательныеСвойства, ",");
	ИначеЕсли ТипЗнч(ОбязательныеСвойства) = Тип("Массив") Тогда
		МассивСвойств = ОбязательныеСвойства;
	Иначе
		ВызватьИсключение "Некорректно указан список обязательных свойств!";
	КонецЕсли;
	
	СтрокаСвойств = "";
	
	Для Каждого ТекСвойство Из МассивСвойств Цикл
		
		Если ПроверяемаяСтруктура.Свойство(СокрЛП(ТекСвойство)) Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаСвойств = СтрокаСвойств
		                      + ?(СтрокаСвойств = "", Символы.ПС, ", " + Символы.ПС)
		                      + """" + СокрЛП(ТекСвойство) + """";
	КонецЦикла;
						  
	Если ШаблонТекстаОшибки = "" Тогда
		ШаблонТекстаОшибки = "Отсутствуют обязательные свойства: %1";
	КонецЕсли;
	
	Если НЕ СтрокаСвойств = "" Тогда
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, СтрокаСвойств);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьСвойства()

// Функция - создает необходимые каталоги для указанного пути
//
// Параметры:
//	Путь       - Строка     - проверяемый путь
//	ЭтоФайл    - Булево     - Истина - в параметре "Путь" передан путь к файлу
//                            Ложь - передан каталог
//
// Возвращаемое значение:
//	Булево     - указанный путь доступен
//
Функция ОбеспечитьКаталог(Знач Путь, Знач ЭтоФайл = Ложь) Экспорт
	
	ВремФайл = Новый Файл(Путь);
	
	Если ЭтоФайл Тогда
		Путь = Сред(ВремФайл.Путь, 1, СтрДлина(ВремФайл.Путь) - 1);
		ВремФайл = Новый Файл(Путь);
	КонецЕсли;
	
	Если НЕ ВремФайл.Существует() Тогда
		Если ОбеспечитьКаталог(Сред(ВремФайл.Путь, 1, СтрДлина(ВремФайл.Путь) - 1)) Тогда
			СоздатьКаталог(Путь);
		Иначе
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ВремФайл.ЭтоКаталог() Тогда
		ВызватьИсключение СтрШаблон("По указанному пути ""%1"" не удалось создать каталог", Путь);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ОбеспечитьКаталог()

#КонецОбласти // СлужебныеПроцедурыИФункции
