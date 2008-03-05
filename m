From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:37 +0000
Subject: [PATCH 22/50] ia64/pv_ops: paravirtualize minstate.h.
Message-Id: <12047411463391-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This isn't necessary because xen defines its own DO_SAVE_MIN.
But this makes the difference of them smaller.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/minstate.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
index fc99141..10a412c 100644
--- a/arch/ia64/kernel/minstate.h
+++ b/arch/ia64/kernel/minstate.h
@@ -34,9 +34,9 @@
 	mov r27=ar.rsc;			/* M */							\
 	mov r20=r1;			/* A */							\
 	mov r25=ar.unat;		/* M */							\
-	mov r29=cr.ipsr;		/* M */							\
+	MOV_FROM_IPSR(r29);		/* M */							\
 	mov r26=ar.pfs;			/* I */							\
-	mov r28=cr.iip;			/* M */							\
+	MOV_FROM_IIP(r28);		/* M */							\
 	mov r21=ar.fpsr;		/* M */							\
 	__COVER;			/* B;; (or nothing) */					\
 	;;											\
-- 
1.5.3

