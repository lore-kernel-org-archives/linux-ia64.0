From: john stultz <johnstul@us.ibm.com>
Date: Fri, 15 Feb 2002 21:02:03 +0000
Subject: [Linux-ia64] New NMCS Lock Implementation (C1)
Message-Id: <marc-linux-ia64-105590701905117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Attached is the NMCS Lock implementation patch for 2.4.17 as well as a
global spinlock replacement patch (more for testing then performance).
NMCS locks are basically queue based mcslocks (also included in this
patch), but manage to keep the queue nodes on the stack of the lock
function (making it a good drop in replacement for a spinlock). 

Why NMCS locks instead of spinlocks? They avoid lock starvation caused
by NUMA latencies, and reduce cache line contention as each cpu spins on
its own node. Also under contention, they are more efficient at passing
the lock to the next cpu. (On the down side, locks can be passed to
interrupted spinners. Ya give, ya take)

This NMCS lock implementation was designed for the K42 project by Marc
Auslander, David Edelsohn, Orran Y Krieger, Bryan S Rosenburg, and
Robert W Wisniewski. (see http://www.research.ibm.com/K42/ for more
info). It has a faster no-contention path then the previous method of
nesting a bit flag inside an mcs lock, but is a bit more complicated in
the slow path. 

In addition, this patch works on ia64 as well as i386.

As global replacement is a bit heavy handed, I'd be interested to find
any cases where people are seeing lock starvation, or high lock
contention for potential single lock replacement. Running w/ the global
replacement will not be a win in most cases.

Performance numbers: Warning, as hackbench *really* beats up on
runqueue_lock, this could be considered somewhat contrived.
Additionally, w/ O(1) scheduler, lock contention is much lower, so you
will not see this sort of a gain. Also these numbers may be inflated as
its running on a 4 way + HT box (4 real cpus, 4 twins), so its not
really 8way. I'd be very interested to see the results on a real 8 way
if anyone is feeling like playing w/ this.

vanilla 8way:
./hackbench 10
Time: 3.927
Time: 4.058
Time: 4.178
./hackbench 25
Time: 33.245
Time: 38.766
Time: 26.112
./hackbench 50
Time: 214.925
Time: 172.834
Time: 166.593
./hackbench 75
Time: 573.864
Time: 518.758
Time: 472.811


nmcs 8way:
./hackbench 10
Time: 4.258
Time: 4.070
Time: 3.176
./hackbench 25
Time: 20.128
Time: 20.967
Time: 22.288
./hackbench 50
Time: 83.732
Time: 84.034
Time: 80.365
./hackbench 75
Time: 165.501
Time: 166.123
Time: 176.539


I'll be out until tuesday, but feel free to stuff my box w/ mail. Just
don't expect any replies until then.

Thanks
-john

PS: thanks to Ravikiran Thirumalai, Momchil Velikov, Andrew Morton and
the K42 folks for bug reports and feedback. 


