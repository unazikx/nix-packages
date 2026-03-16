![poster preview](https://cdn2.steamgriddb.com/grid/b16fab97daa7df5ccd0d892c340b0541.png)

well, i used this guide https://www.youtube.com/watch?v=m76O2cRIEnM

links:

- https://github.com/Weather-OS/GDK-Proton/releases/latest
  (if u use nixos use my package ../packages/wine/proton-gdk.nix)
- https://github.com/Weather-OS/GDK-Proton#for-minecraft
- https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher

steps:

1. u need windows and bought minecraft or downloaded from https://store.rg-adguard.net
2. goto 'C:/XboxGames/Minecraft for Windows' and copy every file (exclude Minecraft.Windows.exe) to other dir_mine
3. Minecraft.Windows.exe encrypted by windows or store so use this in powershell ... and cp to dir_mine
   https://github.com/Weather-OS/WineGDK/issues/5#issuecomment-3658759021
4. cp dir_main to linux
5. add Proton-GDK to heroic or any other launcher and run Minecraft.Windows.exe via launcher with proton
