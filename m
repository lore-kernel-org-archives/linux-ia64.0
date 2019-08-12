From: Christoph Hellwig <hch@lst.de>
Date: Mon, 12 Aug 2019 06:55:22 +0000
Subject: [PATCH 2/4] ia64: annotate switch fallthroughs in ia64_handle_unaligned
Message-Id: <20190812065524.19959-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190812065524.19959-1-hch@lst.de>
In-Reply-To: <20190812065524.19959-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Replace the "no break" comments with something that the compiler
recognizes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/unaligned.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index eb7d5df59fa3..2d4e65ba5c3e 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -1431,7 +1431,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 		if (u.insn.x)
 			/* oops, really a semaphore op (cmpxchg, etc) */
 			goto failure;
-		/* no break */
+		/*FALLTHRU*/
 	      case LDS_IMM_OP:
 	      case LDSA_IMM_OP:
 	      case LDFS_OP:
@@ -1459,7 +1459,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 		if (u.insn.x)
 			/* oops, really a semaphore op (cmpxchg, etc) */
 			goto failure;
-		/* no break */
+		/*FALLTHRU*/
 	      case LD_IMM_OP:
 	      case LDA_IMM_OP:
 	      case LDBIAS_IMM_OP:
@@ -1475,7 +1475,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 		if (u.insn.x)
 			/* oops, really a semaphore op (cmpxchg, etc) */
 			goto failure;
-		/* no break */
+		/*FALLTHRU*/
 	      case ST_IMM_OP:
 	      case STREL_IMM_OP:
 		ret = emulate_store_int(ifa, u.insn, regs);
-- 
2.20.1
