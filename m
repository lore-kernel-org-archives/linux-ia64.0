From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:59 +0000
Subject: [PATCH 0158/1529] Fix typo
Message-Id: <20160521115659.7891-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/perfmon.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 2436ad5..325e0b6 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -1721,9 +1721,9 @@ pfm_fasync(int fd, struct file *filp, int on)
 	}
 	/*
 	 * we cannot mask interrupts during this call because this may
-	 * may go to sleep if memory is not readily avalaible.
+	 * may go to sleep if memory is not readily available.
 	 *
-	 * We are protected from the conetxt disappearing by the get_fd()/put_fd()
+	 * We are protected from the context disappearing by the get_fd()/put_fd()
 	 * done in caller. Serialization of this function is ensured by caller.
 	 */
 	ret = pfm_do_fasync(fd, filp, ctx, on);
@@ -5032,7 +5032,7 @@ pfm_handle_work(void)
 
 	/*
 	 * restore interrupt mask to what it was on entry.
-	 * Could be enabled/diasbled.
+	 * Could be enabled/disabled.
 	 */
 	UNPROTECT_CTX(ctx, flags);
 
-- 
2.8.2.534.g1f66975

