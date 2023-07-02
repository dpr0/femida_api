# frozen_string_literal: true

class CreateTurbozaimUserData < ActiveRecord::Migration[7.0]
  def change
    create_table :turbozaim_user_data do |t|
      t.string :turbozaim_user_id
      t.string :source # ИСТОЧНИК
      t.string :name # ИМЯ
      t.string :birthdate # ДАТА РОЖДЕНИЯ
      t.string :phone # ТЕЛЕФОН, Телефон сотовый, Контактный телефон
      t.string :phone2 # Связь с телефоном, Телефон2
      t.string :passport # ПАСПОРТ
      t.string :birthplace # Место рождения
      t.string :passport_organ # Выдан, Паспорт кем выдан, Паспорт выдан, Кем выдан паспорт
      t.string :passport_date # Дата выдачи, Дата выдачи паспорта
      t.string :registration_region # Регион регистрации
      t.string :registration_address # Адрес регистрации, Адрес регистрации полный, Город регистрации
      t.string :fact_region # Регион проживания
      t.string :fact_address # Адрес проживания, Адрес фактический полный
      t.string :workplace # Место работы, Место работы дохода
      t.string :workplace_phone # Телефон работы, Телефон организации, Телефон работы 1, Телефон руководителя, Телефон работы Руководитель
      t.string :workplace_address # Адрес работы
      t.string :workplace_position # Должность
      t.string :actual_date # Дата актуальности
      t.string :address # Адрес
      t.string :inn # ИНН
      t.string :old_last_name # Фамилия старые данные
      t.string :old_first_name # Имя старые данные
      t.string :old_middle_name # Отчество старые данные
      t.string :old_birthdate # Дата рождения старые данные
      t.string :old_address # Адрес старые данные
      t.string :email # E-mail, e-mail
      t.string :organization # Организация
      t.string :ogrn # ОГРН
      t.string :date_from # Дата начала действия сведений
      t.string :sum # Сумма дохода, Общая сумма дохода, Сумма годового дохода, Доход ежемесячный, Доход по месту работы
      t.string :ifns # ИФНС места жительства
      t.string :organization_inn # ИНН организации
      t.string :vin # VIN
      t.string :model # Модель, марка
      t.string :insurance # Страховщик
      t.string :polis # номер полиса
      t.string :target # Цель использования
      t.string :limitation # Ограничения
      t.string :kbm # КБМ
      t.string :premium_sum # Страховая премия
      t.string :nationality # Национальность
      t.string :delo_num # Номер УД, Номер ИП
      t.string :delo_date # Дата УД, Дата возбуждения ИП
      t.string :delo_article # Статья УК РФ, Основание ИП, Исп. пр-во
      t.string :delo_date2 # Дата совершения
      t.string :info # Информация
      t.string :citizenship # Гражданство
      t.string :date # Дата
      t.string :delo_initiator # Инициатор ОСП
      t.string :credit_sum # Сумма долга в рублях
      t.string :overdue_days # Количество дней просрочки
      t.string :snils # СНИЛС
      t.string :phone3 # Телефон поручителя
      t.string :credit_type # Тип кредита
      t.string :field0
      t.string :field1
      t.string :field2
      t.string :field3
      t.string :field4
      t.string :field5
      t.string :field6
      t.string :field7
      t.string :field8
      t.string :field9
      t.timestamps null: false
    end
  end
end
