color := 0
color1 := 0
color2 := 99
result1 := 0
SetTimer, UpdateScript, 500
 

; берем координаты начала прогресбара
!1::
mousegetpos, X1, Y1
X_const1 := X1
ToolTip, X%X1% `nY%Y1%
Sleep, 1000
ToolTip
Return

; берем координаты конца прогресбара
!2::
mousegetpos, X2, Y2
X_const2 := X2
ToolTip, X%X2% `nY%Y2%
Sleep, 1000
ToolTip
Return

; берем цвет заполненой шкалы. Если нажать неслоклько раз, то выберет наиболее синий цвет.
!3::
mousegetpos, l_x, l_y
pixelgetcolor, l_color, l_x, l_y
color := SubStr(l_color, 3, 2)
if (color > color1)
{
  color1 := color
}
ToolTip, % color1     ; эталон синего
Sleep, 1000
ToolTip
Return

; берем цвет пустой шкалы прогресбара. Если нажать несколько раз в разных местах, то выберет наименее синий цвет.
!4::
mousegetpos, l_x, l_y
pixelgetcolor, l_color, l_x, l_y
color := SubStr(l_color, 3, 2)
if (color < color2)
{
  color2 := color
}
ToolTip, % color2       ; эталон черного
Sleep, 1000
ToolTip
Return

#w::
Xt := X2 - X1  ; длина прогресбара
Yt := (Y1+Y2)//2  ; среднее значение координаты Y
X_dt := X1 + Xt//2  ; координата половины прогресбара
hesteresis := 2
loop
{
if (((result1+hesteresis) > result) and ((result1-hesteresis) < result))
{
  send {F2}
  ToolTip F2
  sleep 5000 ; Тут требуется подобрать правильную задержку, так как у скила есть кд
}
else
{
  send {F3}
  ToolTip F3
  sleep 5000 ; Тут требуется подобрать правильную задержку, так как у скила есть кд
  result1 := result
}
Loop
{
MouseMove, X_dt, Yt
PixelGetColor, Color_Temp, X_dt, Yt  ; сверяем с синим цветом (сверяем какой из цветов ближе - Синий или Черный?) Полученый цвет берем и его вычетаем из эталона синего, а потом из эталона черного. Потом сравниваем их.
Color_Temp :=SubStr(Color_Temp, 3, 2)
Color_Temp := "0x" Color_Temp
C1 := "0x" color1
C2 := "0x" color2
tempBULE := Abs(C1 - Color_Temp)     ; эталон синего минус Имеющийся цвет 
tempBLACK := Abs(C2 - Color_Temp)    ; эталон темного минус Имеющийся цвет = если маленькое значение, значит темный цвет у нас

If (tempBULE < tempBLACK)
{
  X1 := X_dt
  X_dt := X_dt + (X2 - X_dt)//2
}
If (tempBULE > tempBLACK)
{
  X2 := X_dt
  X_dt := X_dt - (X_dt - X1)//2
}

if ((X_dt < X1) Or (X_dt > X2))
{
  Break
}

If ((X2-X1)<3)
{
  ; определяем сколько % шкалы отображается
  result := ((X_dt-X_const1)*100)//(X_const2-X_const1)
  ToolTip, Закончили %result%`%
  X1 := X_const1
  X2 := X_const2
  break
}
}
}
Return


;функция автоматического обновления скрипта при изменении
UpdateScript()
{
    if ((attrb := DllCall("GetFileAttributes", "str", A_ScriptFullPath)) = 0x20) {
        DllCall("SetFileAttributes", "str", A_ScriptFullPath, "uint", attrb &= ~0x20)
        ToolTip  Скрипт был обновлен.
        sleep 1000
        reload
    }
}
