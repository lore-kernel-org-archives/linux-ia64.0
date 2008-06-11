From: "stephane eranian" <eranian@googlemail.com>
Date: Wed, 11 Jun 2008 19:20:11 +0000
Subject: [PATCH] perfmon: fix async exit bug
Message-Id: <7c86c4470806111220g3d6a5c04yc0cc11d430c63a0b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Tony,

Recently, some users have identified a problem with the current
Linux/ia64 perfmon implementation.

There was a bug with the way perfmon cleans up the asynchronous
notification queue used when
you enable O_ASYNC of the file descriptor. the bug was due to the fact
that we were cleaning up
the queue too early, in the flush callback of the file instead of the
close callback.  This was causing
problems with fork() and the child potentially stoppping signal
notification in the parent session.

The following patch fixes the problem. Please apply.

Changelog:

       Move the cleanup of the async queue to the close callback from
the flush callback. This avoids losing
       asynchronous overflow notifications when the file descriptor is
shared by multiple processes and one
       terminates.

 Signed-off-by: Stephane Eranian <eranian@gmail.com>
--

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 71d0513..7cee6e2 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1864,11 +1864,6 @@ pfm_flush(struct file *filp, fl_owner_t id)
 	 * invoked after, it will find an empty queue and no
 	 * signal will be sent. In both case, we are safe
 	 */
-	if (filp->f_flags & FASYNC) {
-		DPRINT(("cleaning up async_queue=%p\n", ctx->ctx_async_queue));
-		pfm_do_fasync (-1, filp, ctx, 0);
-	}
-
 	PROTECT_CTX(ctx, flags);

 	state     = ctx->ctx_state;
@@ -1999,6 +1994,11 @@ pfm_close(struct inode *inode, struct file *filp)
 		return -EBADF;
 	}

+	if (filp->f_flags & FASYNC) {
+		DPRINT(("cleaning up async_queue=%p\n", ctx->ctx_async_queue));
+		pfm_do_fasync (-1, filp, ctx, 0);
+	}
+
 	PROTECT_CTX(ctx, flags);

 	state     = ctx->ctx_state;
