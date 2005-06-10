From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 05:36:11 +0000
Subject: [patch] fix spurious paren in entry.h
Message-Id: <200506100536.j5A5aBcQ001942@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest assembler catches this typo.

	--david

[IA64] Drop spurious paren in entry.h (reported by Jim Wilson).

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

---
commit f03e1ed9926a8969c6e429ab5b5e4b48ce31cc73
tree 20d1c17ae2725eae931fe127c2fedbfbac65261b
parent 9d1c98ae8bc522bd54d4ac025b30a3c79acdc6c5
author <davidm@tiger.hpl.hp.com> Thu, 09 Jun 2005 22:34:21 -0700
committer <davidm@tiger.hpl.hp.com> Thu, 09 Jun 2005 22:34:21 -0700

 arch/ia64/kernel/entry.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/entry.h b/arch/ia64/kernel/entry.h
--- a/arch/ia64/kernel/entry.h
+++ b/arch/ia64/kernel/entry.h
@@ -60,7 +60,7 @@
 	.spillsp @priunat,SW(AR_UNAT)+16+(off);					\
 	.spillsp ar.rnat,SW(AR_RNAT)+16+(off);					\
 	.spillsp ar.bspstore,SW(AR_BSPSTORE)+16+(off);				\
-	.spillsp pr,SW(PR)+16+(off))
+	.spillsp pr,SW(PR)+16+(off)
 
 #define DO_SAVE_SWITCH_STACK			\
 	movl r28;				\
