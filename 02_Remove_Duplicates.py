text = input("Enter a string: ")

unique = ""
for ch in text:
    if ch not in unique:
        unique += ch

print("Unique string:", unique)
