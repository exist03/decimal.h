CFLAGS=-Wall -Werror -Wextra -std=c11
CC=gcc

ifeq ($(shell uname), Linux)
	LINUX_LIBS=-lsubunit -lrt -lpthread -lm
endif

all: clean s21_decimal.a

s21_decimal.a: s21_decimal.o
	ar r s21_decimal.a *.o
	ranlib s21_decimal.a

s21_decimal.o:	s21_decimal.c	s21_any.c	s21_arif.c	s21_equal.c	s21_transform.c	s21_decimal.h
	$(CC)	$(CFLAGS)	-c    s21_*.c

test: test_decimal.c s21_decimal.a
	$(CC) test_decimal.c s21_decimal.a -o test.out -lcheck $(LINUX_LIBS)
	./test.out

gcov_report: test_decimal.c s21_decimal.c s21_any.c s21_arif.c s21_decimal.c s21_equal.c s21_transform.c
	clear
	$(CC) *.c -o coverage.o -lcheck $(LINUX_LIBS) -fprofile-arcs -ftest-coverage  
	./coverage.o
	lcov -c -d . -o coverage.info
	genhtml coverage.info -o coverage
	open coverage/index.html
	
clean:
	rm -rf *.o *.out *.a
	rm -rf *.gcda *.gcno
	rm -rf coverage coverage.info 
	rm -rf CPPLINT.cfg cpplint.py

leaks: test
	$(CC) -g test_decimal.c s21_decimal.a -o test.out -lcheck $(LINUX_LIBS)
	valgrind --quiet --leak-check=full --show-leak-kinds=all --track-origins=yes --show-reachable=no --log-file=valgrind-out.txt ./test.out

leaks2: test
	CK_FORK=no leaks --atExit -- ./test.out

clang:
	cp ./../materials/linters/.clang-format .
	clang-format -n *.c
	clang-format -i *.c