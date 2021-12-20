fr = open("opt.txt")
data = fr.readlines()
var = []
for i in data:
    if i.split()[0] == "Unused":
        var.append(i.split()[-1])

for i in data:
    if i.split()[0] not in var and i.split()[0] != "Unused":
        print(i)