From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 00:13:41 +0000
Subject: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <20080329001341.7F93826FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Friday, 28 March 2008 17:12:30 -0700 <20080329001230.D013726FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

Set TIF_SIGPENDING in set_restore_sigmask.  This lets arch code take
TIF_RESTORE_SIGMASK out of the set of bits that will be noticed on
return to user mode.  On some machines those bits are scarce, and we
can free this unneeded one up for other uses.

It is probably the case that TIF_SIGPENDING is always set anyway
everywhere set_restore_sigmask() is used.  But this is some cheap
paranoia in case there is an arcane case where it might not be.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 include/linux/thread_info.h |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index d82c073..4a89477 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -85,11 +85,17 @@ static inline int test_ti_thread_flag(struct thread_info *ti, int flag)
  * set_restore_sigmask() - make sure saved_sigmask processing gets done
  *
  * This sets TIF_RESTORE_SIGMASK and ensures that the arch signal code
- * will run before returning to user mode, to process the flag.
+ * will run before returning to user mode, to process the flag.  For
+ * all callers, TIF_SIGPENDING is already set or it's no harm to set
+ * it.  TIF_RESTORE_SIGMASK need not be in the set of bits that the
+ * arch code will notice on return to user mode, in case those bits
+ * are scarce.  We set TIF_SIGPENDING here to ensure that the arch
+ * signal code always gets run when TIF_RESTORE_SIGMASK is set.
  */
 static inline void set_restore_sigmask(void)
 {
 	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_thread_flag(TIF_SIGPENDING);
 }
 #endif	/* TIF_RESTORE_SIGMASK */
 
