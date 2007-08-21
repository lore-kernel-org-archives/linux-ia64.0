From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 21 Aug 2007 03:57:01 +0000
Subject: Cleanup HPSIM code (was: Re: Enable early console for Ski simulator)
Message-Id: <87sl6dk0aa.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


After my last patch we have a new header file for HP simulator use.
Here's code to use it for stuff that used to have `extern' statements
inline in the code.  Functionality should not change with this patch.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

---
 arch/ia64/hp/sim/hpsim_console.c |    1 -
 arch/ia64/hp/sim/simeth.c        |   12 +++---------
 arch/ia64/hp/sim/simscsi.c       |    3 +--
 include/asm-ia64/hpsim.h         |    6 ++++++
 4 files changed, 10 insertions(+), 12 deletions(-)

Index: linux-2.6-git/arch/ia64/hp/sim/hpsim_console.c
=================================--- linux-2.6-git.orig/arch/ia64/hp/sim/hpsim_console.c	2007-08-21 13:04:52.000000000 +1000
+++ linux-2.6-git/arch/ia64/hp/sim/hpsim_console.c	2007-08-21 13:20:27.000000000 +1000
@@ -52,21 +52,20 @@ simcons_write (struct console *cons, con
 	while (count-- > 0) {
 		ch = *buf++;
 		ia64_ssc(ch, 0, 0, 0, SSC_PUTCHAR);
 		if (ch = '\n')
 		  ia64_ssc('\r', 0, 0, 0, SSC_PUTCHAR);
 	}
 }
 
 static struct tty_driver *simcons_console_device (struct console *c, int *index)
 {
-	extern struct tty_driver *hp_simserial_driver;
 	*index = c->index;
 	return hp_simserial_driver;
 }
 
 int simcons_register(void)
 {
 	if (!ia64_platform_is("hpsim"))
 		return 1;
 
 	if (hpsim_cons.flags & CON_ENABLED)
Index: linux-2.6-git/arch/ia64/hp/sim/simeth.c
=================================--- linux-2.6-git.orig/arch/ia64/hp/sim/simeth.c	2007-08-21 13:04:47.000000000 +1000
+++ linux-2.6-git/arch/ia64/hp/sim/simeth.c	2007-08-21 13:20:27.000000000 +1000
@@ -15,39 +15,36 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/inetdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <linux/notifier.h>
 #include <linux/bitops.h>
 #include <asm/system.h>
 #include <asm/irq.h>
+#include <asm/hpsim.h>
+
+#include "hpsim_ssc.h"
 
 #define SIMETH_RECV_MAX	10
 
 /*
  * Maximum possible received frame for Ethernet.
  * We preallocate an sk_buff of that size to avoid costly
  * memcpy for temporary buffer into sk_buff. We do basically
  * what's done in other drivers, like eepro with a ring.
  * The difference is, of course, that we don't have real DMA !!!
  */
 #define SIMETH_FRAME_SIZE	ETH_FRAME_LEN
 
 
-#define SSC_NETDEV_PROBE		100
-#define SSC_NETDEV_SEND			101
-#define SSC_NETDEV_RECV			102
-#define SSC_NETDEV_ATTACH		103
-#define SSC_NETDEV_DETACH		104
-
 #define NETWORK_INTR			8
 
 struct simeth_local {
 	struct net_device_stats stats;
 	int 			simfd;	 /* descriptor in the simulator */
 };
 
 static int simeth_probe1(void);
 static int simeth_open(struct net_device *dev);
 static int simeth_close(struct net_device *dev);
@@ -117,23 +114,20 @@ simeth_probe (void)
 
 	printk(KERN_INFO "simeth: v%s\n", simeth_version);
 
 	r = simeth_probe1();
 
 	if (r = 0) register_netdevice_notifier(&simeth_dev_notifier);
 
 	return r;
 }
 
-extern long ia64_ssc (long, long, long, long, int);
-extern void ia64_ssc_connect_irq (long intr, long irq);
-
 static inline int
 netdev_probe(char *name, unsigned char *ether)
 {
 	return ia64_ssc(__pa(name), __pa(ether), 0,0, SSC_NETDEV_PROBE);
 }
 
 
 static inline int
 netdev_connect(int irq)
 {
Index: linux-2.6-git/arch/ia64/hp/sim/simscsi.c
=================================--- linux-2.6-git.orig/arch/ia64/hp/sim/simscsi.c	2007-08-21 13:04:47.000000000 +1000
+++ linux-2.6-git/arch/ia64/hp/sim/simscsi.c	2007-08-21 13:20:27.000000000 +1000
@@ -7,20 +7,21 @@
  *
  * 02/01/15 David Mosberger	Updated for v2.5.1
  * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by linux v2.3.33
  */
 #include <linux/blkdev.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
 #include <asm/irq.h>
+#include "hpsim_ssc.h"
 
 #include <scsi/scsi.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>
 #include <scsi/scsi_host.h>
 
 #define DEBUG_SIMSCSI	0
 
 #define SIMSCSI_REQ_QUEUE_LEN	64
 #define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
@@ -52,22 +53,20 @@ static DECLARE_TASKLET(simscsi_tasklet, 
 struct disk_req {
 	unsigned long addr;
 	unsigned len;
 };
 
 struct disk_stat {
 	int fd;
 	unsigned count;
 };
 
-extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
-
 static int desc[16] = {
 	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
 };
 
 static struct queue_entry {
 	struct scsi_cmnd *sc;
 } queue[SIMSCSI_REQ_QUEUE_LEN];
 
 static int rd, wr;
 static atomic_t num_reqs = ATOMIC_INIT(0);
Index: linux-2.6-git/include/asm-ia64/hpsim.h
=================================--- linux-2.6-git.orig/include/asm-ia64/hpsim.h	2007-08-21 13:04:52.000000000 +1000
+++ linux-2.6-git/include/asm-ia64/hpsim.h	2007-08-21 13:20:27.000000000 +1000
@@ -1,10 +1,16 @@
 #ifndef _ASMIA64_HPSIM_H
 #define _ASMIA64_HPSIM_H
 
 #ifndef CONFIG_HP_SIMSERIAL_CONSOLE
 static inline int simcons_register(void) { return 1; }
 #else
 int simcons_register(void);
 #endif
 
+struct tty_driver;
+extern struct tty_driver *hp_simserial_driver;
+
+void ia64_ssc_connect_irq(long intr, long irq);
+void ia64_ctl_trace(long on);
+
 #endif


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
