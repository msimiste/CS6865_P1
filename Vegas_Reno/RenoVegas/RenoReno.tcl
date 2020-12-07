#Create a simulator object
set ns [new Simulator]
$ns color 1 Red
$ns color 2 Blue



#Open the nam trace file
set nf [open out.nam w]
set f0 [open 1_Reno.tr w]
set f1 [open 2_Reno.tr w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf f0 f1
        $ns flush-trace
	#Close the trace file
        close $nf
	close $f0
	close $f1
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}

proc record {} {
        global sink0 sink1 f0 f1
	#Get an instance of the simulator
	set ns [Simulator instance]
	#Set the time after which the procedure should be called again
        set time 1.0
	#How many bytes have been received by the traffic sinks?
        set bw0 [$sink0 set bytes_]
	set bw1	[$sink1 set bytes_]
		
	#Get the current time
        set now [$ns now]
	#Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
	puts $f1 "$now [expr $bw1/$time*8/1000000]"

	#Reset the bytes_ values on the traffic sinks
        $sink0 set bytes_ 0
	$sink1 set bytes_ 0
	#Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

#Create two nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]


#Create a duplex link between the nodes
$ns duplex-link $n0 $n2 10Mb 2ms DropTail
$ns duplex-link $n1 $n2 10Mb 2ms DropTail
$ns duplex-link $n2 $n3 15Mb 2ms DropTail
$ns duplex-link $n3 $n4 10Mb 2ms DropTail
$ns duplex-link $n3 $n5 10Mb 2ms DropTail


$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n2 $n1 orient left-down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#Create a TCP agent and attach it to node n0
set tcp0 [new Agent/TCP/Reno]
$tcp0 set packetSize_ 1500
$tcp0 set window_ 128
$ns attach-agent $n0 $tcp0
$tcp0 set class_ 2

#Create a TCP agent and attach it to node n1
set tcp1  [new Agent/TCP/Reno]
$tcp1 set packetSize_ 1500
$tcp1 set window_ 128
$ns attach-agent $n1 $tcp1
$tcp1 set class_ 1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1


set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1


$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1


#Schedule events for the CBR agent
$ns at 0.0 "record"
$ns at 1.0  "$ftp0 start"
$ns at 15.0  "$ftp0 stop"
$ns at 2.0  "$ftp1 start"
$ns at 15.0 "$ftp1 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 20.0 "finish"


#Run the simulation
$ns run
