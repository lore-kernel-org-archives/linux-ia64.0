From: Jes Sorensen <jes@sgi.com>
Date: Tue, 17 Jan 2006 17:52:21 +0000
Subject: [patch] sn2 mutex conversion
Message-Id: <yq0irsirbca.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

A number of sem2mutex and sem2completion changes for the SN2 code.

Cheers,
Jes

Migrate sn2 code to use mutex and completion events rather than
semaphores.

Signed-off-by: Jes Sorensen <jes@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>

----

 arch/ia64/sn/kernel/mca.c         |    7 ++++---
 arch/ia64/sn/kernel/xp_main.c     |   17 +++++++++--------
 arch/ia64/sn/kernel/xpc_channel.c |   34 ++++++++++++++--------------------
 arch/ia64/sn/kernel/xpc_main.c    |   17 +++++++++--------
 include/asm-ia64/sn/xp.h          |    3 ++-
 include/asm-ia64/sn/xpc.h         |    9 +++++----
 6 files changed, 43 insertions(+), 44 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/mca.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/mca.c	2006-01-12 06:37:43.233753965 -0600
+++ linux-2.6/arch/ia64/sn/kernel/mca.c	2006-01-12 06:39:28.011540087 -0600
@@ -10,6 +10,7 @@
 #include <linux/kernel.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
+#include <linux/mutex.h>
 #include <asm/mca.h>
 #include <asm/sal.h>
 #include <asm/sn/sn_sal.h>
@@ -27,7 +28,7 @@
 /* Printing oemdata from mca uses data that is not passed through SAL, it is
  * global.  Only one user at a time.
  */
-static DECLARE_MUTEX(sn_oemdata_mutex);
+static DEFINE_MUTEX(sn_oemdata_mutex);
 static u8 **sn_oemdata;
 static u64 *sn_oemdata_size, sn_oemdata_bufsize;
 
@@ -89,7 +90,7 @@
 sn_platform_plat_specific_err_print(const u8 * sect_header, u8 ** oemdata,
 				    u64 * oemdata_size)
 {
-	down(&sn_oemdata_mutex);
+	mutex_lock(&sn_oemdata_mutex);
 	sn_oemdata = oemdata;
 	sn_oemdata_size = oemdata_size;
 	sn_oemdata_bufsize = 0;
@@ -107,7 +108,7 @@
 		*sn_oemdata_size = 0;
 		ia64_sn_plat_specific_err_print(print_hook, (char *)sect_header);
 	}
-	up(&sn_oemdata_mutex);
+	mutex_unlock(&sn_oemdata_mutex);
 	return 0;
 }
 
Index: linux-2.6/arch/ia64/sn/kernel/xp_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xp_main.c	2006-01-12 06:37:43.233753965 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xp_main.c	2006-01-12 07:14:54.649164514 -0600
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/mutex.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/xp.h>
@@ -136,13 +137,13 @@
 
 	registration = &xpc_registrations[ch_number];
 
-	if (down_interruptible(&registration->sema) != 0) {
+	if (mutex_lock_interruptible(&registration->mutex) != 0) {
 		return xpcInterrupted;
 	}
 
 	/* if XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func != NULL) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return xpcAlreadyRegistered;
 	}
 
@@ -154,7 +155,7 @@
 	registration->key = key;
 	registration->func = func;
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 	xpc_interface.connect(ch_number);
 
@@ -190,11 +191,11 @@
 	 * figured XPC's users will just turn around and call xpc_disconnect()
 	 * again anyways, so we might as well wait, if need be.
 	 */
-	down(&registration->sema);
+	mutex_lock(&registration->mutex);
 
 	/* if !XPC_CHANNEL_REGISTERED(ch_number) */
 	if (registration->func = NULL) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return;
 	}
 
@@ -208,7 +209,7 @@
 
 	xpc_interface.disconnect(ch_number);
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 	return;
 }
@@ -250,9 +251,9 @@
 		xp_nofault_PIOR_target = SH1_IPI_ACCESS;
 	}
 
-	/* initialize the connection registration semaphores */
+	/* initialize the connection registration mutex */
 	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
-		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
+		mutex_init(&xpc_registrations[ch_number].mutex);
 	}
 
 	return 0;
Index: linux-2.6/include/asm-ia64/sn/xpc.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xpc.h	2006-01-12 06:37:43.267930293 -0600
+++ linux-2.6/include/asm-ia64/sn/xpc.h	2006-01-12 06:39:28.101375007 -0600
@@ -19,6 +19,8 @@
 #include <linux/interrupt.h>
 #include <linux/sysctl.h>
 #include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/completion.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/sn/bte.h>
@@ -335,8 +337,7 @@
  * and consumed by the intended recipient.
  */
 struct xpc_notify {
-	struct semaphore sema;		/* notify semaphore */
-	volatile u8 type;			/* type of notification */
+	volatile u8 type;		/* type of notification */
 
 	/* the following two fields are only used if type = XPC_N_CALL */
 	xpc_notify_func func;		/* user's notify function */
@@ -465,8 +466,8 @@
 	xpc_channel_func func;		/* user's channel function */
 	void *key;			/* pointer to user's key */
 
-	struct semaphore msg_to_pull_sema; /* next msg to pull serialization */
-	struct semaphore wdisconnect_sema; /* wait for channel disconnect */
+	struct mutex msg_to_pull_mutex;	/* next msg to pull serialization */
+	struct completion wdisconnect_wait; /* wait for channel disconnect */
 
 	struct xpc_openclose_args *local_openclose_args; /* args passed on */
 					/* opening or closing of channel */
Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-01-12 06:37:43.234730432 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-01-13 08:46:35.369695255 -0600
@@ -22,6 +22,8 @@
 #include <linux/cache.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/mutex.h>
+#include <linux/completion.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/xpc.h>
@@ -56,8 +58,8 @@
 		atomic_set(&ch->n_to_notify, 0);
 
 		spin_lock_init(&ch->lock);
-		sema_init(&ch->msg_to_pull_sema, 1);	/* mutex */
-		sema_init(&ch->wdisconnect_sema, 0);	/* event wait */
+		mutex_init(&ch->msg_to_pull_mutex);
+		init_completion(&ch->wdisconnect_wait);
 
 		atomic_set(&ch->n_on_msg_allocate_wq, 0);
 		init_waitqueue_head(&ch->msg_allocate_wq);
@@ -534,7 +536,6 @@
 xpc_allocate_msgqueues(struct xpc_channel *ch)
 {
 	unsigned long irq_flags;
-	int i;
 	enum xpc_retval ret;
 
 
@@ -552,11 +553,6 @@
 		return ret;
 	}
 
-	for (i = 0; i < ch->local_nentries; i++) {
-		/* use a semaphore as an event wait queue */
-		sema_init(&ch->notify_queue[i].sema, 0);
-	}
-
 	spin_lock_irqsave(&ch->lock, irq_flags);
 	ch->flags |= XPC_C_SETUP;
 	spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -799,10 +795,8 @@
 	}
 
 	if (ch->flags & XPC_C_WDISCONNECT) {
-		spin_unlock_irqrestore(&ch->lock, *irq_flags);
-		up(&ch->wdisconnect_sema);
-		spin_lock_irqsave(&ch->lock, *irq_flags);
-
+		/* we won't lose the CPU since we're holding ch->lock */
+		complete(&ch->wdisconnect_wait);
 	} else if (ch->delayed_IPI_flags) {
 		if (part->act_state != XPC_P_DEACTIVATING) {
 			/* time to take action on any delayed IPI flags */
@@ -1092,12 +1086,12 @@
 	struct xpc_registration *registration = &xpc_registrations[ch->number];
 
 
-	if (down_trylock(&registration->sema) != 0) {
+	if (mutex_trylock(&registration->mutex) = 0) {
 		return xpcRetry;
 	}
 
 	if (!XPC_CHANNEL_REGISTERED(ch->number)) {
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return xpcUnregistered;
 	}
 
@@ -1108,7 +1102,7 @@
 
 	if (ch->flags & XPC_C_DISCONNECTING) {
 		spin_unlock_irqrestore(&ch->lock, irq_flags);
-		up(&registration->sema);
+		mutex_unlock(&registration->mutex);
 		return ch->reason;
 	}
 
@@ -1140,7 +1134,7 @@
 			 * channel lock be locked and will unlock and relock
 			 * the channel lock as needed.
 			 */
-			up(&registration->sema);
+			mutex_unlock(&registration->mutex);
 			XPC_DISCONNECT_CHANNEL(ch, xpcUnequalMsgSizes,
 								&irq_flags);
 			spin_unlock_irqrestore(&ch->lock, irq_flags);
@@ -1155,7 +1149,7 @@
 		atomic_inc(&xpc_partitions[ch->partid].nchannels_active);
 	}
 
-	up(&registration->sema);
+	mutex_unlock(&registration->mutex);
 
 
 	/* initiate the connection */
@@ -2089,7 +2083,7 @@
 	enum xpc_retval ret;
 
 
-	if (down_interruptible(&ch->msg_to_pull_sema) != 0) {
+	if (mutex_lock_interruptible(&ch->msg_to_pull_mutex) != 0) {
 		/* we were interrupted by a signal */
 		return NULL;
 	}
@@ -2125,7 +2119,7 @@
 
 			XPC_DEACTIVATE_PARTITION(part, ret);
 
-			up(&ch->msg_to_pull_sema);
+			mutex_unlock(&ch->msg_to_pull_mutex);
 			return NULL;
 		}
 
@@ -2134,7 +2128,7 @@
 		ch->next_msg_to_pull += nmsgs;
 	}
 
-	up(&ch->msg_to_pull_sema);
+	mutex_unlock(&ch->msg_to_pull_mutex);
 
 	/* return the message we were looking for */
 	msg_offset = (get % ch->remote_nentries) * ch->msg_size;
Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-12 06:37:43.234730432 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-13 08:46:10.194429319 -0600
@@ -55,6 +55,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
+#include <linux/completion.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/kdebug.h>
@@ -177,10 +178,10 @@
 static unsigned long xpc_hb_check_timeout;
 
 /* notification that the xpc_hb_checker thread has exited */
-static DECLARE_MUTEX_LOCKED(xpc_hb_checker_exited);
+static DECLARE_COMPLETION(xpc_hb_checker_exited);
 
 /* notification that the xpc_discovery thread has exited */
-static DECLARE_MUTEX_LOCKED(xpc_discovery_exited);
+static DECLARE_COMPLETION(xpc_discovery_exited);
 
 
 static struct timer_list xpc_hb_timer;
@@ -321,7 +322,7 @@
 
 
 	/* mark this thread as having exited */
-	up(&xpc_hb_checker_exited);
+	complete(&xpc_hb_checker_exited);
 	return 0;
 }
 
@@ -341,7 +342,7 @@
 	dev_dbg(xpc_part, "discovery thread is exiting\n");
 
 	/* mark this thread as having exited */
-	up(&xpc_discovery_exited);
+	complete(&xpc_discovery_exited);
 	return 0;
 }
 
@@ -893,7 +894,7 @@
 			continue;
 		}
 
-		(void) down(&ch->wdisconnect_sema);
+		wait_for_completion(&ch->wdisconnect_wait);
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		DBUG_ON(!(ch->flags & XPC_C_DISCONNECTED));
@@ -946,10 +947,10 @@
 	free_irq(SGI_XPC_ACTIVATE, NULL);
 
 	/* wait for the discovery thread to exit */
-	down(&xpc_discovery_exited);
+	wait_for_completion(&xpc_discovery_exited);
 
 	/* wait for the heartbeat checker thread to exit */
-	down(&xpc_hb_checker_exited);
+	wait_for_completion(&xpc_hb_checker_exited);
 
 
 	/* sleep for a 1/3 of a second or so */
@@ -1367,7 +1368,7 @@
 		dev_err(xpc_part, "failed while forking discovery thread\n");
 
 		/* mark this new thread as a non-starter */
-		up(&xpc_discovery_exited);
+		complete(&xpc_discovery_exited);
 
 		xpc_do_exit(xpcUnloading);
 		return -EBUSY;
Index: linux-2.6/include/asm-ia64/sn/xp.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xp.h	2006-01-12 06:37:43.267930293 -0600
+++ linux-2.6/include/asm-ia64/sn/xp.h	2006-01-12 06:39:28.114069071 -0600
@@ -18,6 +18,7 @@
 
 #include <linux/cache.h>
 #include <linux/hardirq.h>
+#include <linux/mutex.h>
 #include <asm/sn/types.h>
 #include <asm/sn/bte.h>
 
@@ -359,7 +360,7 @@
  * the channel.
  */
 struct xpc_registration {
-	struct semaphore sema;
+	struct mutex mutex;
 	xpc_channel_func func;		/* function to call */
 	void *key;			/* pointer to user's key */
 	u16 nentries;			/* #of msg entries in local msg queue */
