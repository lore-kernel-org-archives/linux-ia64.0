From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 18 Jul 2003 00:08:56 +0000
Subject: NaT consumption faults in current 2.5 BK kernel (FIXED)
Message-Id: <marc-linux-ia64-105848702204930@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105840128613012@msgid-missing>
In-Reply-To: <marc-linux-ia64-105840128613012@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

Peter> OK, thanks to the latest mod from David, I have the system
Peter> running on the simulator.  Hurrah.

Peter> I can see a NaT consumption fault every time I cat
Peter> /proc/net/dev

OK, the problem is in the simulated ethernet driver.  Trivial Patch appended:

=== arch/ia64/hp/sim/simeth.c 1.8 vs edited ==--- 1.8/arch/ia64/hp/sim/simeth.c	Wed Jun  4 20:38:47 2003
+++ edited/arch/ia64/hp/sim/simeth.c	Fri Jul 18 09:36:19 2003
@@ -223,7 +223,7 @@
 	dev->set_multicast_list = set_multicast_list; /* no yet used */
 
 	err = register_netdev(dev);
-	if (dev) {
+	if (err) {
 		kfree(dev);
 		return err;
 	}
