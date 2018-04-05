set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(netif) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 50 ;
set val(nn) 5 ;
set val(rp) AODV ;
set val(x) 1000 ;
set val(y) 800 ; 
set val(stop) 20 ;

set ns [new Simulator]
set tracefd [open simple-dsdv.tr w]
set windowVsTime2 [open win.tr w] 
set namtrace [open simwrls1.nam w]    

$ns trace-all $tracefd
$ns use-newtrace 
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)
		$ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON
			 
	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]	
	}
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0

$node_(3) set X_ 980.0
$node_(3) set Y_ 500.0

$node_(4) set X_ 500.0
$node_(4) set Y_ 100.0

$ns at 1.0 "$node_(0) setdest 100.0 50.0 30.0"
$ns at 1.5 "$node_(1) setdest 400.0 50.0 50.0"
$ns at 2.0 "$node_(0) setdest 150.0 350.0 50.0"
$ns at 2.5 "$node_(4) setdest 200.0 300.0 50.0" 
$ns at 3.0 "$node_(3) setdest 350.0 250.0 100.0" 
$ns at 3.5 "$node_(4) setdest 250.0 100.0 50.0"  

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
$tcp set fid_ 1
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $node_(4) $tcp1
$ns attach-agent $node_(2) $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns attach-agent $node_(3) $tcp2
$ns attach-agent $node_(2) $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 3
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp
$cbr attach-agent $tcp1
$cbr attach-agent $tcp2
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

$ns at 0.1 "$cbr start"
$ns at 0.5 "$ftp start"
$ns at 0.8 "$ftp1 start"
$ns at 1.0 "$ftp2 start"

for {set i 0} {$i < $val(nn)} { incr i } {
$ns initial_node_pos $node_($i) 50
}

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 20.1 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam simwrls1.nam &
}

$ns run


