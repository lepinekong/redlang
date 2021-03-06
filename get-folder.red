Red [
    Title: "get-folder.red"
]

if not value? '.redlang [
    do https://redlang.red
]
.redlang [block-to-string alias]

.get-folder: function [
    {Examples:
        get-folder %/C/ProgramData/Red/gui-console-2018-6-18-47628.exe
        get-folder system/options/boot/
    }
    '>file-path
    /build
][
    >build: 0.0.0.1.15
    if build [
        print >build
        exit
    ]

    either (path? >file-path) [
        
        either (value? :>file-path) [    
            .file-path: get :>file-path
        ][
            .file-path: :>file-path
        ]
    ][
        .file-path: :>file-path
    ]

    .file-path: to-red-file form .file-path
    

    ;folder>: pick split-path .file-path 1 ; 0.0.0.1.18 fix bug redlang.red\build\debug\download.red\0.0.0.1\02\cache\get-folder.1.red
    either dir? .file-path [
        folder>: .file-path
    ][
        folder>: pick split-path .file-path 1
    ]

    return folder>
]

alias .get-folder [get-folder]

.get-parent-folder: function [folder-or-file][
    folder: folder-or-file
    unless dir? folder-or-file [
        folder: get-folder folder-or-file
        ?? folder
    ]
    decomposed-folders: split folder "/"
    ?? decomposed-folders
    remove back tail decomposed-folders
    parent-folder: to-red-file rejoin [(block-to-string decomposed-folders "/") "/"]
    return parent-folder
]
alias .get-parent-folder [get-parent-folder]

.get-script-folder: function [][
    folder: pick split-path system/options/script 1
    return folder
]

alias .get-script-folder [get-script-folder]

