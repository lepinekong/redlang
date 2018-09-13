Red [
    Title: "do-events.red"
]

.do-events: function [
    
	{Launch the event loop, blocks until all windows are closed} 
	/no-wait "Process an event in the queue and returns at once" 
	return: "Returned value from last event" [logic! word!]
	/local result 
	win
][
    try [
        either no-wait [
            do-events/no-wait
        ][
            do-events
        ]
    ]
]