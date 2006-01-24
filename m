From: Jes Sorensen <jes@sgi.com>
Date: Tue, 24 Jan 2006 09:23:16 +0000
Subject: [patch] XPC remove unnecessary GFP_DMA flag
Message-Id: <yq03bje6ku3.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This patch gets rid of the GFP_DMA flag in the SN2 XPC code, as there
is no real need to set it.

Cheers,
Jes

Remove the GFP_DMA flag from XPC kmalloc() calls.

Signed-off-by: Jes Sorensen <jes@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>

----

 arch/ia64/sn/kernel/xpc_channel.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)


Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-01-12 06:39:28.106257339 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-01-12 06:33:11.669629026 -0600
@@ -447,7 +447,7 @@
 
 		nbytes = nentries * ch->msg_size;
 		ch->local_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
-						(GFP_KERNEL | GFP_DMA),
+						GFP_KERNEL,
 						&ch->local_msgqueue_base);
 		if (ch->local_msgqueue = NULL) {
 			continue;
@@ -455,7 +455,7 @@
 		memset(ch->local_msgqueue, 0, nbytes);
 
 		nbytes = nentries * sizeof(struct xpc_notify);
-		ch->notify_queue = kmalloc(nbytes, (GFP_KERNEL | GFP_DMA));
+		ch->notify_queue = kmalloc(nbytes, GFP_KERNEL);
 		if (ch->notify_queue = NULL) {
 			kfree(ch->local_msgqueue_base);
 			ch->local_msgqueue = NULL;
@@ -502,7 +502,7 @@
 
 		nbytes = nentries * ch->msg_size;
 		ch->remote_msgqueue = xpc_kmalloc_cacheline_aligned(nbytes,
-						(GFP_KERNEL | GFP_DMA),
+						GFP_KERNEL,
 						&ch->remote_msgqueue_base);
 		if (ch->remote_msgqueue = NULL) {
 			continue;
