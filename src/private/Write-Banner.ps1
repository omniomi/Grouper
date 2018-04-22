Function Write-Banner {

    $barf = @'
  .,-:::::/ :::::::..       ...      ...    :::::::::::::. .,:::::: :::::::..
,;;-'````'  ;;;;``;;;;   .;;;;;;;.   ;;     ;;; `;;;```.;;;;;;;'''' ;;;;``;;;;
[[[   [[[[[[/[[[,/[[['  ,[[     \[[,[['     [[[  `]]nnn]]'  [[cccc   [[[,/[[['
"$$c.    "$$ $$$$$$c    $$$,     $$$$$      $$$   $$$""     $$""""   $$$$$$c
 `Y8bo,,,o88o888b "88bo,"888,_ _,88P88    .d888   888o      888oo,__ 888b "88bo,
   `'YMUP"YMMMMMM   "W"   "YMMMMMP"  "YmmMMMM""   YMMMb     """"YUMMMMMMM   "W"
                                                            github.com/mikeloss
                                                            @mikeloss
'@ -split "`n"

    $Pattern = ('White','Yellow','Red','Red','DarkRed','DarkRed','White','White')
    ""
    ""
    $i = 0
    foreach ($barfline in $barf) {
        Write-ColorText -Text $barfline -Color $Pattern[$i]
        $i += 1
    }
}