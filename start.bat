@echo off
ren main.txt main.pyw
pyinstaller --onefile --icon=icon.ico main.pyw
