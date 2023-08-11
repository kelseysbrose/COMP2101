'env:path += ";$home/OneDrive/Documents/GitHub/Comp2101/PowerShell"' >> $profile

new-item -path alias:np -value notepad
get-alias
get alias np
np

function welcome {
" Welcome to my computer, How are you today?"
}

