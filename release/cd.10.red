Red [
    Title: "cd.red"
    Version: [0.0.1 {searching subfolder automatically}]
    Builds: [
        0.0.0.5.1.14 {request-dir if no arg}
        0.0.0.5.1.12 {alpha release - support for partial subfolder, example cd redlang/github}
        0.0.0.5.1.7 {support for partial subfolder, example cd redlang/github}
        0.0.0.5.6 {fixed tree duplicates}
        0.0.0.5.3 {revert to 1}
        0.0.0.4.13 {refactoring and unless only [.dir/only]}
        0.0.0.4 {/only for preventing dir list}
        0.0.0.2.8 {searching up if not found TBC}
    ]
]

if not value? '.redlang [
    do https://redlang.red
]
.redlang [search-dir dir-tree dir block-to-string
    ;do-trace
]

if not value? '.syscd [
    .syscd: :cd
    .cd: func [
        "Change directory (shell shortcut function)." 
        [catch] 
        'path [file! word! path! unset! string! paren! url!] "Accepts %file, :variables and just words (as dirs)"
        /only {do not list folders}
        /search
        /up
        /_build 
        /no-autoexec {don't autoexecute %.red and %autoload.red}
        /silent
        /_debug
        /local _counter _first_path
    ][

        search: true

        >builds: [
            0.0.0.5.1.14 {request-dir if no arg}
            0.0.0.5.1.12 {alpha release - support for partial subfolder, example cd redlang/github}
            0.0.0.5.1.7 {support for partial subfolder, example cd redlang/github}
            0.0.0.5.6 {fixed tree duplicates}
            0.0.0.5.3 {revert to 1}
            0.0.0.4.13 {refactoring and unless only [.dir/only]}
            0.0.0.4 {/only for preventing dir list}
            0.0.0.2.8 {searching up if not found TBC}
        ]

        if _build [
            unless silent [
                ?? >builds
            ]
            return >builds
        ]

        switch type?/word get/any 'path [
            unset! [
                >path: request-dir/dir (what-dir)
                if none? >path [
                    return none
                ]
            ]
            file! word! path! unset! string! paren! url! [
                >path: :path
            ]
        ]      

        ;>path: :path

        _counter: []
        _first_path: []
        either empty? _counter [
            append _counter 1
            append _first_path >path
        ][
            _counter/1: _counter/1 + 1
        ]        

        if up [

            thepath: form >path

            if found: search-dir/up (thepath) [
                if _debug [
                    do-trace 67 [
                        ?? thepath
                    ] %cd.5.red
                    
                ]
                .cd (found)
                unless only [.dir/only] ; 0.0.0.4.01.2 0.0.0.4.1.11
                
                return what-dir
            ]
            exit
        ]

        dir-not-found: function [
            path searchString
            /_debug
        ][
            
            either found: search-dir/folder (searchString) (path) [
                if _debug [
                    do-trace 91 [
                        ?? searchString
                        ?? path
                        ?? found
                    ] %cd.5.red
                ] 
                either exists? (found) [
                    change-dir (found)
                    unless only [.dir/only] ; 0.0.0.4.01.2
                ][
                    .cd (found)
                ]                        
            ][
                if _debug [
                    do-trace 104 [
                        ?? searchString
                        ?? path
                        ?? found
                    ] %cd.5.red 
                ]
 
                if find searchString "/" [
                    searchString: pick (splitted-path: split searchString "/") 1         

                    if _debug [
                        do-trace 118 [
                            ?? path
                            ?? searchString
                        ] %cd.7.red
                        ;dir-not-found/_debug %./ (searchString)                       
                    ]
                    found: search-dir/folder (searchString) %./
                    if found [
                        change-dir to-file (found)
                        remove splitted-path
                        searchString: block-to-string splitted-path "/"
                        .cd (searchString)
                        return what-dir
                    ]
                ]
            ]
        ]
    
        if paren? get/any 'path [set/any 'path do path] 
        switch/default type?/word get/any 'path [
            unset! [
                unless only [.dir/only]
                path: request-dir
                .cd (path)
                unless only [.dir/only] ; 0.0.0.4.01.2       
            ] 

            string! file! url! [ 
                searchString: form path
                path: to-file searchString
                
                if _debug [
                    do-trace 123 [
                        ?? path
                    ] %cd.5.red
                ]

                if error? try [
                    change-dir to-file path
                    print [{cd} to-file path]
                    unless only [.dir/only] ; 0.0.0.4.01.2                   
                ][
                    
                    either _debug [
                        do-trace 135 [
                            ?? searchString
                        ] %cd.7.red
                        dir-not-found/_debug %. (searchString)
                    ][
                        dir-not-found %. (searchString)
                    ]
                    
                ]
                
            ] 
            word! path! [

                if error? try [
                    if value? to-word >path [ 
                        the-path: (get in system/words >path)
                        if not logic? the-path [
                            if _debug [
                                do-trace 155 [
                                    ?? the-path
                                ] %cd.5.red
                                
                            ]                            
                            .cd (the-path)
                            unless only [.dir/only] ; 0.0.0.4.01.2 
                            exit
                        ]
                    ]
                ][
                    the-path: to-red-file form >path

                    either exists? (the-path) [
                        if _debug [
                            do-trace 170 [
                                ?? the-path
                            ] %cd.5.red
                            
                        ]                           
                        change-dir (the-path)
                        unless only [.dir/only] ; 0.0.0.4.01.2 
                    ][
                        if _debug [
                            do-trace 179 [
                                ?? the-path
                            ] %cd.5.red
                            
                        ]  
                        either _debug [
                            .cd/_debug (the-path)
                        ][
                            .cd (the-path)
                        ]                         
                        
                    ]                  

                    exit
                ]


                if error? try [
                    change-dir to-file path
                    print [{cd} to-file path]
                    unless only [.dir/only] ; 0.0.0.4.01.2                    
                ][
                    searchString: form path                      
                    dir-not-found %. searchString
                ]                    
                
                ; unless no-autoexec [
                ;     if exists? %autoload.red [
                ;         do %autoload.red
                ;     ]
                ;     if exists? %.red [
                ;         do %.red
                ;     ] 
                ; ]
            ]
        ] [
            throw error 'script 'expect-arg reduce ['cd 'path type? get/any 'path]
        ]
        what-dir  
    ]   
    ;system/words/cd: :.cd 
    system/words/..: function [][
        .cd ".."
        return what-dir
    ]
    system/words/...: function [][
        .cd ".."
        .cd ".."
        return what-dir
    ]   
    system/words/....: function [][
        .cd ".."
        .cd ".."
        .cd ".."        
        return what-dir
    ]      
  
    if not value? '.c [
        system/words/.c: function [][
            .cd %/c/
            return what-dir
        ]           
    ]
    if not value? 'c [c: :.c]
    if not value? '.d [
        system/words/.d: function [][
            .cd %/d/
            return what-dir
        ]           
    ] 
    if not value? 'd [d: :.d]

]

cd: :.cd
