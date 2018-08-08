Red [
    Title: "copy-file.red"
    Builds: [
        0.0.0.1 {Initial build with file versioning or /force and checksum}
    ]
    Iterations: [
        0.0.0.1.12 {if previous-file <> >target [}
        0.0.0.1.10 {Add checksum}     
        0.0.0.1.2 {Protecting existing files}
        0.0.0.1.1 {Initial build}
    ]    
]

compare-checksum: function [>file1 >file2][
    file1-content: read >file1
    checksum-file1: checksum file1-content 'SHA256
    file2-content: read >file2
    checksum-file2: checksum file2-content 'SHA256 
    return (checksum-file1 = checksum-file2)  
]

copy-file: function [>source >target /force /no-checksum][

    either force [
        write >target read >source
    ][
        either exists? >target [

            print [>target "already exists."]

            get-next-file: function [/local counter][
                counter: []
                if empty? counter [
                    append counter 0
                ]
                counter/1: counter/1 + 1
                i: counter/1
                next-file: rejoin [short-filename-wo-extension "."  i  extension]                
            ]

            do https://redlang.red/file-path
            short-filename: .get-short-filename >target
            short-filename-wo-extension: get-short-filename-without-extension >target
            extension: .get-file-extension >target
            target-folder: pick (split-path >target) 1

            next-file: >target
            while [exists? next-file][
                previous-file: next-file
                next-file: rejoin [target-folder get-next-file] 
            ]

            do https://redlang.red/list-files
            list-files: get-list-files target-folder
            ?? list-files

            if previous-file <> >target [
                unless no-checksum [

                    either false = compare-checksum >source previous-file [    
                        write next-file read >source
                        print [next-file "created."]
                        return true
                    ][
                        print [previous-file "is up to date."]
                        return false
                    ]
                ]
            ]

            ; no-checksum
            write next-file read >source
            print [next-file "created."]
            return true
        ][
            write >target read >source
            print [>target "created."]
        ]
    ]

]

copy-files: function[>list][

    list: >list
    forall list [
        files: list/1
        source: files/1
        target: files/2
        copy-file source target   
    ]
]
