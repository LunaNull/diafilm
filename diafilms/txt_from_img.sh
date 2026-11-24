#!/bin/bash
# ==============================================================================
# sudo pacman -S tesseract tesseract-data-rus
# sudo apt update && sudo apt install tesseract-ocr tesseract-ocr-rus -y
# ==============================================================================
# СКРИПТ: Распознавание текста с изображений (OCR) через Tesseract
# ==============================================================================

# 1. Запрашиваем имя папки с изображениями
echo -n "Имя папки с изображениями: "
read -r TARGET_DIR

# 2. Проверяем существование папки с изображениями
if [ ! -d "img/$TARGET_DIR" ]; then
    echo "Ошибка: Папка 'img/$TARGET_DIR' не найдена!"
    exit 1
fi

# 3. Создаем папку для сохранения текста
mkdir -p "txt/$TARGET_DIR"

# 4. Переходим внутрь папки с изображениями
cd "img/$TARGET_DIR" || exit 1

# Считаем общее количество картинок в папке для индикатора прогресса
total_files=$(ls -v *.jpg *.png *.webp *.jpeg 2>/dev/null | wc -l)

if [ "$total_files" -eq 0 ]; then
    echo "В папке нет поддерживаемых файлов изображений (.jpg, .png, .webp, .jpeg)."
    exit 0
fi

echo "Найдено файлов для обработки: $total_files. Начинаем распознавание..."

# Счетчик обработанных файлов
current_file=1

# 5. Запускаем цикл обработки файлов по порядку
ls -v *.jpg *.png *.webp *.jpeg 2>/dev/null | while IFS= read -r file; do
    # Проверяем, существует ли файл
    if [ ! -f "$file" ]; then
        continue
    fi

    # Выводим индикатор прогресса в терминал
    echo -ne "\r[$current_file/$total_files] Обрабатывается: $file... \033[K" >&2

    # Запускаем Tesseract и выводим текст
    tesseract "$file" stdout -l rus 2>/dev/null

    # Делаем ровно 2 переноса строки после распознанного текста
    echo -e "\n\n"

    # Увеличиваем счетчик для индикатора
    current_file=$((current_file + 1))

# 6. Перенаправляем весь текст из цикла в итоговый файл
done > "../../txt/${TARGET_DIR}/${TARGET_DIR}_$(date +%Y%m%d_%H%M%S).txt"

echo -e "\nГотово!"

