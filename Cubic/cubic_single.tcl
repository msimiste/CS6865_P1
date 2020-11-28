set ns [new Simulator]

# nam sim data
set nf [open out.nam w]
$ns namtrace-all $nf

# cwnd data
set wf1 [open flow_1.tr w]

# on finish
# flush all trace and open nam
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec xgraph flow_1.tr -geometry 800x400 &
    # exec nam out.nam &
    exit 0
}

# create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# setup a simple dumbbell network as follows:
#
# n0 - n1 ========== n2 - n3

$ns duplex-link $n0 $n1 2.0Gb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Gb 100ms DropTail
$ns duplex-link $n2 $n3 2.0Gb 10ms DropTail
$ns queue-limit $n1 $n2 10

# setup queue watcher and queue limit bet n2 and n3
$ns duplex-link-op $n1 $n2 queuePos 0.1

# setup nam positions
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right

# setup simulation colors
$ns color 1 Blue

# setup n0 to n3 connection
set tcp0 [new Agent/TCP/Linux]
$tcp0 set fid_ 1
$tcp0 set class_ 1
$tcp0 set window_ 8000
$tcp0 set packetSize_ 5552
$ns at 0 "$tcp0 select_ca cubic"
$ns attach-agent $n0 $tcp0

set sink0 [new Agent/TCPSink/Sack1]
$sink0 set class_ 1
$sink0 set ts_echo_rfc1323_ true
$ns attach-agent $n3 $sink0

# setup traffic
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

$ns connect $tcp0 $sink0

$ns at 0.2 "$ftp0 start"
$ns at 299.5 "$ftp0 stop"

# setup proc for cwnd plotting
proc plotWindow {tcpSource1 file1} {
   global ns

   set time 0.1
   set now [$ns now]
   set cwnd1 [$tcpSource1 set cwnd_]

   puts $file1 "$now $cwnd1"
   $ns at [expr $now+$time] "plotWindow $tcpSource1 $file1" 
}

# setup plotting
$ns at 0.1 "plotWindow $tcp0 $wf1"

# when to stop
$ns at 300.0 "finish"

# starto!
$ns run
