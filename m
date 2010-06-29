From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jun 2010 22:13:53 +0000
Subject: [IA64] Fix spinaphore down_spin()
Message-Id: <4c2a702125889227ce@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Typo in down_spin() meant it only read the low 32 bits of the
"serve" value, instead of the full 64 bits. This results in the
system hanging when the values in ticket/serve get larger than
32-bits. A big enough system running the right test can hit this
in just a couple of days.

Reported via IRC by Bjorn Helgaas

Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 5dfd916..7b3cdc6 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -121,7 +121,7 @@ static inline void down_spin(struct spinaphore *ss)
 	ia64_invala();
 
 	for (;;) {
-		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(serve) : "r"(&ss->serve) : "memory");
+		asm volatile ("ld8.c.nc %0=[%1]" : "=r"(serve) : "r"(&ss->serve) : "memory");
 		if (time_before(t, serve))
 			return;
 		cpu_relax();
