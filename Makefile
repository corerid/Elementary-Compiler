OBJS = cal.l cal.y
CC = gcc

comp: $(OBJS)
	flex cal.l
	bison -d cal.y
	$(CC) lex.yy.c cal.tab.c -lfl -o cal

