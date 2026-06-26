from pathlib import Path 
p=Path(r'C:/Users/blessedyours/Desktop/Hills of Los Santos/gamemodes/modules/gangs/pickups.pwn') 
lines=p.read_text(encoding='utf-8', errors='backslashreplace').splitlines() 
for i in range(236,268): 
    print(f'{i+1:04d}: {lines[i]!r}') 
