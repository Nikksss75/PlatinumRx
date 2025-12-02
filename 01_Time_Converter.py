def convert_min(min):
hours = min // 60
mins = min % 60
    
 if hours == 1:
    hr_str = "hr"
 else:
    hr_str = "hrs"
    
 if mins == 1:
    min_str = "minute"
 else:
    min_str = "minutes"
    
  if hours == 0:
    return f"{mins} {min_str}"
  elif mins == 0:
    return f"{hours} {hr_str}"
  else:
    return f"{hours} {hr_str} {mins} {min_str}"

print(convert_min(130))
print(convert_min(110))  
