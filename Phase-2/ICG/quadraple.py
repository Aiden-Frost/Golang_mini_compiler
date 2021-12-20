fr = open("icg.txt")
data = fr.readlines()
print("Operator \t Arg1 \t Arg2 \t Result")
for i in data:
    d = i.split()
    if len(d) == 5 and d[0] != "IF":
        print(d[3] + "\t\t" + d[2] + "\t" + d[4] + "\t" + d[0])
    elif len(d) == 5 and d[0] == "IF":
        print("IFFALSE" + "\t\t" + d[2] + "\t" + "NULL" + "\t" + d[4])
    elif len(d) == 3:
        print(d[1] + "\t\t" + d[2] + "\t" + "NULL" + "\t" + d[0])
    elif len(d) == 2:
        print("GOTO" + "\t\t" + "NULL" + "\t" + "NULL" + "\t" + d[1])
    elif len(d) == 1:
        print("LABEL" + "\t\t" + "NULL" + "\t" + "NULL" + "\t" + d[0].rstrip(":"))

fr.close()
