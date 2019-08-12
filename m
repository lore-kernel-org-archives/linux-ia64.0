From: Christoph Hellwig <hch@lst.de>
Date: Mon, 12 Aug 2019 06:55:21 +0000
Subject: [PATCH 1/4] ia64: annotate a switch fallthrough in ia64_do_signal
Message-Id: <20190812065524.19959-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812065524.19959-1-hch@lst.de>
In-Reply-To: <20190812065524.19959-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Also reindent the switch statement to use the normal kernel style
while at it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/signal.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index e5044aed9452..d07ed65c9c6e 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -363,19 +363,19 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 
 		if (unlikely(restart)) {
 			switch (errno) {
-			      case ERESTART_RESTARTBLOCK:
-			      case ERESTARTNOHAND:
+			case ERESTART_RESTARTBLOCK:
+			case ERESTARTNOHAND:
 				scr->pt.r8 = EINTR;
 				/* note: scr->pt.r10 is already -1 */
 				break;
-
-			      case ERESTARTSYS:
+			case ERESTARTSYS:
 				if ((ksig.ka.sa.sa_flags & SA_RESTART) = 0) {
 					scr->pt.r8 = EINTR;
 					/* note: scr->pt.r10 is already -1 */
 					break;
 				}
-			      case ERESTARTNOINTR:
+				/*FALLTHRU*/
+			case ERESTARTNOINTR:
 				ia64_decrement_ip(&scr->pt);
 				restart = 0; /* don't restart twice if handle_signal() fails... */
 			}
-- 
2.20.1
