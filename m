From: Chen Gang <gang.chen@asianux.com>
Date: Mon, 27 May 2013 06:30:29 +0000
Subject: [PATCH] arch: ia64: kernel: flow control, need use 'return' instead of 'break'
Message-Id: <51A2FD85.6080808@asianux.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>


In this case, the original author did not provide the related reason
string for die_if_kernel(), so the 'buf' is not initialized.

The original author wants to generic a 'SIGSEGV' and 'return', not want
to 'break' to fall to die.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 arch/ia64/kernel/traps.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index f7f9f9c..d3636e6 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -630,7 +630,7 @@ ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 		printk(KERN_ERR "  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx\n",
 		       iip, ifa, isr);
 		force_sig(SIGSEGV, current);
-		break;
+		return;
 
 	      case 46:
 		printk(KERN_ERR "Unexpected IA-32 intercept trap (Trap 46)\n");
-- 
1.7.7.6
