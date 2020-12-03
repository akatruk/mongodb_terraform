mongodb 3 node cluster deploy
=========
Этот кластер устанавливает только софт mongodb на готовые ВМ
Для кластера нужно ровно 3 ВМ (на одной, двух, четырех и более работать не будет)


Софт необходимый для работы
=========
python, ansible, terraform


Инструкция по запуску
=========
1. Заполняем переменные в фаиле `terraform.tfvars` (для кластер монго должно быть ровно 3 сервера)
2. Убеждаемся, что ВМ доступны, и сетевой трафик между серверами по порту 27017/TCP разрешен
3. Запустить terraform apply -auto-approve

Получаем файлик credentials.passwd




***
Что можно добавить еще:

Автотесты (Предварительная проверка: проверка сети между ВМ, доступность ВМ для ансибл)
Автотесты (Пост инсталляционная проверка: автотесты реплики)


=========
Тестировалось все на:
ansible 2.9.13
terraform 0.13.5
python version 2.7.16