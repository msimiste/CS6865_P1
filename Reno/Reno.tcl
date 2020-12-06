#Create a simulator object
set ns [new Simulator]
$ns color 1 Red
$ns color 2 Blue
$ns color 3 Green
$ns color 4 Yellow

#Open the nam trace file
set nf [open out.nam w]
set f0 [open 1_TCP.tr w]
set f1 [open 2_TCP.tr w]
set f2 [open 3_TCP.tr w]
set f3 [open 4_TCP.tr w]
set f4 [open 1_TCP_TGT.tr w]
set f5 [open 2_TCP_TGT.tr w]
set f6 [open 3_TCP_TGT.tr w]
set f7 [open 4_TCP_TGT.tr w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf f0 f1 f2 f3 f4 f5 f6 f7
        $ns flush-trace
	#Close the trace file
        close $nf
	close $f0
	close $f1
	close $f2
	close $f3
	close $f4
	close $f5
	close $f6
	close $f7
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}

proc record {} {
        global ns sink0 sink1 sink2 sink3 tcp0 tcp1 tcp2 tcp3 f0 f1 f2 f3 f4 f5 f6 f7
	#Get an instance of the simulator
	#set ns [Simulator instance]
	#Set the time after which the procedure should be called again
        set time 0.1
	#How many bytes have been received by the traffic sinks?
        set bw0 [$sink0 set bytes_]
	set bw1	[$sink1 set bytes_]
	set bw2 [$sink2 set bytes_]
	set bw3 [$sink3 set bytes_]


        set cwnd0 [$tcp0 set cwnd_]
	set cwnd1 [$tcp1 set cwnd_]
        set cwnd2 [$tcp2 set cwnd_]
        set cwnd3 [$tcp3 set cwnd_]
	
	#Get the current time
        set now [$ns now]
	#Calculate the bandwidth (in MBit/s) and write it to the 	ifiles
        puts $f0 "$now $cwnd0"
	puts $f1 "$now $cwnd1"
	puts $f2 "$now $cwnd2"
	puts $f3 "$now $cwnd3"

        puts $f4 "$now [expr $bw0/$time*8/1000000]"
        puts $f5 "$now [expr $bw1/$time*8/1000000]"
        puts $f6 "$now [expr $bw2/$time*8/1000000]"
        puts $f7 "$now [expr $bw3/$time*8/1000000]"

        $sink0 set bytes_ 0
	$sink1 set bytes_ 0
	$sink2 set bytes_ 0
	$sink3 set bytes_ 0
	
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
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n3 $n5 10Mb 10ms DropTail
$ns duplex-link $n6 $n2 10Mb 10ms DropTail
$ns duplex-link $n3 $n7 10Mb 10ms DropTail
$ns duplex-link $n8 $n2 10Mb 10ms DropTail
$ns duplex-link $n3 $n9 10Mb 10ms DropTail


$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n2 $n1 orient left-down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
$ns duplex-link-op $n6 $n2 orient right
$ns duplex-link-op $n3 $n7 orient right
$ns duplex-link-op $n8 $n2 orient down
$ns duplex-link-op $n3 $n9 orient down

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

#Create a TCP agent and attach it to node n0
set tcp2 [new Agent/TCP/Reno]
$tcp2 set packetSize_ 1500
$tcp2 set window_ 128
$ns attach-agent $n6 $tcp2
$tcp2 set class_ 3

#Create a TCP agent and attach it to node n0
set tcp3 [new Agent/TCP/Reno]
$tcp3 set packetSize_ 1500
$tcp3 set window_ 128
$ns attach-agent $n8 $tcp3
$tcp3 set class_ 4

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3

set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0

set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1

set sink2 [new Agent/TCPSink]
$ns attach-agent $n7 $sink2

set sink3 [new Agent/TCPSink]
$ns attach-agent $n9 $sink3

$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2
$ns connect $tcp3 $sink3


#Schedule events for the CBR agent
$ns at 0.0 "record"
$ns at 1.0  "$ftp0 start"
$ns at 20.0  "$ftp0 stop"
$ns at 1.5  "$ftp1 start"
$ns at 20.0 "$ftp1 stop"
$ns at 1.75 "$ftp2 start"
$ns at 20.0 "$ftp2 stop"
$ns at 2.0 "$ftp3 start"
$ns at 20.0 "$ftp3 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 22.0 "finish"


#Run the simulation
$ns run
