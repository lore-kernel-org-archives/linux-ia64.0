From: Qiaowei Ren <qiaowei.ren@intel.com>
Date: Sun, 12 Oct 2014 04:41:45 +0000
Subject: [PATCH v9 02/12] x86, mpx: rename cfg_reg_u and status_reg
Message-Id: <1413088915-13428-3-git-send-email-qiaowei.ren@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

According to Intel SDM extension, MPX configuration and status registers
should be BNDCFGU and BNDSTATUS. This patch renames cfg_reg_u and
status_reg to bndcfgu and bndstatus.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/processor.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index eb71ec7..020142f 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -379,8 +379,8 @@ struct bndregs_struct {
 } __packed;
 
 struct bndcsr_struct {
-	u64 cfg_reg_u;
-	u64 status_reg;
+	u64 bndcfgu;
+	u64 bndstatus;
 } __packed;
 
 struct xsave_hdr_struct {
-- 
1.7.1

