-- Определить, терял ли читатель книги (Для проверки конкретного читалеля вместо GROUP BY необходимо написать условие WHERE).
SELECT r.reader_fio,
CASE
    WHEN COUNT(lb.copies_of_books_id) = 0 THEN 'NO LOST BOOKS'
    ELSE 'LOST'
END AS "LOST BOOKS"
FROM readers r
LEFT JOIN lost_books lb USING(number_of_reader_ticket)
GROUP BY r.reader_fio;

-- При потере книг количество доступных книг фонда меняется. Напишите sql запрос на обновление соответствующей информации.
UPDATE books b
SET count_copies_of_book = count_copies_of_book - cblb.count_lost_books
FROM (SELECT book_cipher, COUNT(copies_of_books_id) count_lost_books
      FROM lost_books lb
      JOIN copies_of_books cb USING(copies_of_books_id)
      GROUP BY book_cipher) cblb
WHERE b.book_cipher = cblb.book_cipher;

-- Определить сумму потерянных книг по каждому кварталу в течение года.
SELECT SUM(book_prise) "TOTAL",
	     EXTRACT(QUARTER FROM cblb.lending_date) "QUARTER",
	     EXTRACT(YEAR FROM cblb.lending_date) "YEAR"
FROM (SELECT book_cipher, lb.lending_date
      FROM copies_of_books cb
      JOIN lending_of_books lb USING(copies_of_books_id)
      WHERE lb.return_date IS NULL) cblb
JOIN books b USING(book_cipher)
GROUP BY "QUARTER", "YEAR"
ORDER BY "YEAR", "QUARTER";
