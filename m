From: Jes Sorensen <jes@sgi.com>
Date: Mon, 06 Feb 2006 12:57:06 +0000
Subject: [patch] SN2 XPC reduce inlining and use kzalloc
Message-Id: <yq0psm0myql.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This patch takes advantage of kzalloc() in the XPC code as well as
reduces the inlining of cache line aligning kmalloc code. Guess long
term having an 'always-cache-line-align' flag for kmalloc would be
neat.

Cheers,
Jes


Take advantage of kzalloc() as well as reduce the size of code generated
for the error returns in xpc_setup_infrastructure().

Signed-off-by: Jes Sorensen <jes@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>

----

 arch/ia64/sn/kernel/xpc_channel.c   |  102 ++++++++++++++++++++---------------- 
 arch/ia64/sn/kernel/xpc_main.c      |    1
 arch/ia64/sn/kernel/xpc_partition.c |   28 +++++++++
 include/asm-ia64/sn/xpc.h           |   22 -------
 4 files changed, 85 insertions(+), 68 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-01-24 13:53:34.926707157 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-01-24 13:58:23.824260705 -0600
@@ -21,7 +21,6 @@
 #include <linux/sched.h>
 #include <linux/cache.h>
 #include <linux/interrupt.h>
-#include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/completion.h>
 #include <asm/sn/bte.h>
@@ -30,6 +29,31 @@
 
 
 /*
+ * Guarantee that the kzalloc'd memory is cacheline aligned.
+ */
+static void *
+xpc_kzalloc_cacheline_aligned(size_t size, gfp_t flags, void **base)
+{
+	/* see if kzalloc will give us cachline aligned memory by default */
+	*base = kzalloc(size, flags);
+	if (*base = NULL) {
+		return NULL;
+	}
+	if ((u64) *base = L1_CACHE_ALIGN((u64) *base)) {
+		return *base;
+	}
+	kfree(*base);
+
+	/* nope, we'll have to do it ourselves */
+	*base = kzalloc(size + L1_CACHE_BYTES, flags);
+	if (*base = NULL) {
+		return NULL;
+	}
+	return (void *) L1_CACHE_ALIGN((u64) *base);
+}
+
+
+/*
  * Set up the initial values for the XPartition Communication channels.
  */
 static void
@@ -93,20 +117,19 @@
 	 * Allocate all of the channel structures as a contiguous chunk of
 	 * memory.
 	 */
-	part->channels = kmalloc(sizeof(struct xpc_channel) * XPC_NCHANNELS,
+	part->channels = kzalloc(sizeof(struct xpc_channel) * XPC_NCHANNELS,
 								GFP_KERNEL);
 	if (part->channels = NULL) {
 		dev_err(xpc_chan, "can't get memory for channels\n");
 		return xpcNoMemory;
 	}
-	memset(part->channels, 0, sizeof(struct xpc_channel) * XPC_NCHANNELS);
 
 	part->nchannels = XPC_NCHANNELS;
 
 
 	/* allocate all the required GET/PUT values */
 
-	part->local_GPs = xpc_kmalloc_cacheline_aligned(XPC_GP_SIZE,
+	part->local_GPs = xpc_kzalloc_cacheline_aligned(XPC_GP_SIZE,
 					GFP_KERNEL, &part->local_GPs_base);
 	if (part->local_GPs = NULL) {
 		kfree(part->channels);
@@ -115,55 +138,51 @@
 			"values\n");
 		return xpcNoMemory;
 	}
-	memset(part->local_GPs, 0, XPC_GP_SIZE);
 
-	part->remote_GPs = xpc_kmalloc_cacheline_aligned(XPC_GP_SIZE,
+	part->remote_GPs = xpc_kzalloc_cacheline_aligned(XPC_GP_SIZE,
 					GFP_KERNEL, &part->remote_GPs_base);
 	if (part->remote_GPs = NULL) {
-		kfree(part->channels);
-		part->channels = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
 		dev_err(xpc_chan, "can't get memory for remote get/put "
 			"values\n");
+		kfree(part->local_GPs_base);
+		part->local_GPs = NULL;
+		kfree(part->channels);
+		part->channels = NULL;
 		return xpcNoMemory;
 	}
-	memset(part->remote_GPs, 0, XPC_GP_SIZE);
 
 
 	/* allocate all the required open and close args */
 
-	part->local_openclose_args = xpc_kmalloc_cacheline_aligned(
+	part->local_openclose_args = xpc_kzalloc_cacheline_aligned(
 					XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
 					&part->local_openclose_args_base);
 	if (part->local_openclose_args = NULL) {
-		kfree(part->channels);
-		part->channels = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
+		dev_err(xpc_chan, "can't get memory for local connect args\n");
 		kfree(part->remote_GPs_base);
 		part->remote_GPs = NULL;
-		dev_err(xpc_chan, "can't get memory for local connect args\n");
+		kfree(part->local_GPs_base);
+		part->local_GPs = NULL;
+		kfree(part->channels);
+		part->channels = NULL;
 		return xpcNoMemory;
 	}
-	memset(part->local_openclose_args, 0, XPC_OPENCLOSE_ARGS_SIZE);
 
-	part->remote_openclose_args = xpc_kmalloc_cacheline_aligned(
+	part->remote_openclose_args = xpc_kzalloc_cacheline_aligned(
 					XPC_OPENCLOSE_ARGS_SIZE, GFP_KERNEL,
 					&part->remote_openclose_args_base);
 	if (part->remote_openclose_args = NULL) {
-		kfree(part->channels);
-		part->channels = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->remote_GPs_base);
-		part->remote_GPs = NULL;
+		dev_err(xpc_chan, "can't get memory for remote connect args\n");
 		kfree(part->local_openclose_args_base);
 		part->local_openclose_args = NULL;
-		dev_err(xpc_chan, "can't get memory for remote connect args\n");
+		kfree(part->remote_GPs_base);
+		part->remote_GPs = NULL;
+		kfree(part->local_GPs_base);
+		part->local_GPs = NULL;
+		kfree(part->channels);
+		part->channels = NULL;
 		return xpcNoMemory;
 	}
-	memset(part->remote_openclose_args, 0, XPC_OPENCLOSE_ARGS_SIZE);
 
 
 	xpc_initialize_channels(part, partid);
@@ -186,18 +205,18 @@
 	ret = request_irq(SGI_XPC_NOTIFY, xpc_notify_IRQ_handler, SA_SHIRQ,
 				part->IPI_owner, (void *) (u64) partid);
 	if (ret != 0) {
-		kfree(part->channels);
-		part->channels = NULL;
-		kfree(part->local_GPs_base);
-		part->local_GPs = NULL;
-		kfree(part->remote_GPs_base);
-		part->remote_GPs = NULL;
-		kfree(part->local_openclose_args_base);
-		part->local_openclose_args = NULL;
-		kfree(part->remote_openclose_args_base);
-		part->remote_openclose_args = NULL;
 		dev_err(xpc_chan, "can't register NOTIFY IRQ handler, "
 			"errno=%d\n", -ret);
+		kfree(part->remote_openclose_args_base);
+		part->remote_openclose_args = NULL;
+		kfree(part->local_openclose_args_base);
+		part->local_openclose_args = NULL;
+		kfree(part->remote_GPs_base);
+		part->remote_GPs = NULL;
+		kfree(part->local_GPs_base);
+		part->local_GPs = NULL;
+		kfree(part->channels);
+		part->channels = NULL;
 		return xpcLackOfResources;
 	}
 
@@ -446,22 +465,20 @@
 	for (nentries = ch->local_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
-		ch->local_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
+		ch->local_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 						GFP_KERNEL,
 						&ch->local_msgqueue_base);
 		if (ch->local_msgqueue = NULL) {
 			continue;
 		}
-		memset(ch->local_msgqueue, 0, nbytes);
 
 		nbytes = nentries * sizeof(struct xpc_notify);
-		ch->notify_queue = kmalloc(nbytes, GFP_KERNEL);
+		ch->notify_queue = kzalloc(nbytes, GFP_KERNEL);
 		if (ch->notify_queue = NULL) {
 			kfree(ch->local_msgqueue_base);
 			ch->local_msgqueue = NULL;
 			continue;
 		}
-		memset(ch->notify_queue, 0, nbytes);
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		if (nentries < ch->local_nentries) {
@@ -501,13 +518,12 @@
 	for (nentries = ch->remote_nentries; nentries > 0; nentries--) {
 
 		nbytes = nentries * ch->msg_size;
-		ch->remote_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
+		ch->remote_msgqueue = xpc_kzalloc_cacheline_aligned(nbytes,
 						GFP_KERNEL,
 						&ch->remote_msgqueue_base);
 		if (ch->remote_msgqueue = NULL) {
 			continue;
 		}
-		memset(ch->remote_msgqueue, 0, nbytes);
 
 		spin_lock_irqsave(&ch->lock, irq_flags);
 		if (nentries < ch->remote_nentries) {
Index: linux-2.6/include/asm-ia64/sn/xpc.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xpc.h	2006-01-24 13:53:34.927683624 -0600
+++ linux-2.6/include/asm-ia64/sn/xpc.h	2006-01-24 13:58:05.028246029 -0600
@@ -1222,28 +1222,6 @@
 
 
 
-static inline void *
-xpc_kmalloc_cacheline_aligned(size_t size, gfp_t flags, void **base)
-{
-	/* see if kmalloc will give us cachline aligned memory by default */
-	*base = kmalloc(size, flags);
-	if (*base = NULL) {
-		return NULL;
-	}
-	if ((u64) *base = L1_CACHE_ALIGN((u64) *base)) {
-		return *base;
-	}
-	kfree(*base);
-
-	/* nope, we'll have to do it ourselves */
-	*base = kmalloc(size + L1_CACHE_BYTES, flags);
-	if (*base = NULL) {
-		return NULL;
-	}
-	return (void *) L1_CACHE_ALIGN((u64) *base);
-}
-
-
 /*
  * Check to see if there is any channel activity to/from the specified
  * partition.
Index: linux-2.6/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_partition.c	2006-01-24 13:53:34.926707157 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_partition.c	2006-01-24 13:58:13.059687705 -0600
@@ -81,6 +81,31 @@
 
 
 /*
+ * Guarantee that the kmalloc'd memory is cacheline aligned.
+ */
+static void *
+xpc_kmalloc_cacheline_aligned(size_t size, gfp_t flags, void **base)
+{
+	/* see if kmalloc will give us cachline aligned memory by default */
+	*base = kmalloc(size, flags);
+	if (*base = NULL) {
+		return NULL;
+	}
+	if ((u64) *base = L1_CACHE_ALIGN((u64) *base)) {
+		return *base;
+	}
+	kfree(*base);
+
+	/* nope, we'll have to do it ourselves */
+	*base = kmalloc(size + L1_CACHE_BYTES, flags);
+	if (*base = NULL) {
+		return NULL;
+	}
+	return (void *) L1_CACHE_ALIGN((u64) *base);
+}
+
+
+/*
  * Given a nasid, get the physical address of the  partition's reserved page
  * for that nasid. This function returns 0 on any error.
  */
@@ -1038,13 +1063,12 @@
 	remote_vars = (struct xpc_vars *) remote_rp;
 
 
-	discovered_nasids = kmalloc(sizeof(u64) * xp_nasid_mask_words,
+	discovered_nasids = kzalloc(sizeof(u64) * xp_nasid_mask_words,
 							GFP_KERNEL);
 	if (discovered_nasids = NULL) {
 		kfree(remote_rp_base);
 		return;
 	}
-	memset(discovered_nasids, 0, sizeof(u64) * xp_nasid_mask_words);
 
 	rp = (struct xpc_rsvd_page *) xpc_rsvd_page;
 
Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-01-24 13:53:34.927683624 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-01-24 13:53:38.239860065 -0600
@@ -52,7 +52,6 @@
 #include <linux/syscalls.h>
 #include <linux/cache.h>
 #include <linux/interrupt.h>
-#include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/reboot.h>
 #include <linux/completion.h>
