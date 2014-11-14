From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 15:18:17 +0000
Subject: [PATCH 01/11] x86, mpx: rename cfg_reg_u and status_reg
Message-Id: <20141114151817.031762AC@viggo.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141114151816.F56A3072@viggo.jf.intel.com>
In-Reply-To: <20141114151816.F56A3072@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


According to Intel SDM extension, MPX configuration and status registers
should be BNDCFGU and BNDSTATUS. This patch renames cfg_reg_u and
status_reg to bndcfgu and bndstatus.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/processor.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/processor.h~mpx-v11-rename-cfg-reg-u-and-status-reg arch/x86/include/asm/processor.h
--- a/arch/x86/include/asm/processor.h~mpx-v11-rename-cfg-reg-u-and-status-reg	2014-11-14 07:06:20.773541505 -0800
+++ b/arch/x86/include/asm/processor.h	2014-11-14 07:06:20.777541686 -0800
@@ -380,8 +380,8 @@ struct bndreg {
 } __packed;
 
 struct bndcsr {
-	u64 cfg_reg_u;
-	u64 status_reg;
+	u64 bndcfgu;
+	u64 bndstatus;
 } __packed;
 
 struct xsave_hdr_struct {
_
