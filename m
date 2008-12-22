From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 22 Dec 2008 05:50:08 +0000
Subject: [PATCH 01/15] ia64: remove warnings.
Message-Id: <1229925022-31365-2-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1229063944-27462-2-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1229063944-27462-2-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

this patch removes the following warnings.

>   CC      arch/ia64/kernel/patch.o
> /linux-2.6/arch/ia64/kernel/patch.c: In function 'ia64_patch_vtop':
> /linux-2.6/arch/ia64/kernel/patch.c:112: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
> /linux-2.6/arch/ia64/kernel/patch.c: In function 'ia64_patch_rse':
> /linux-2.6/arch/ia64/kernel/patch.c:135: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
> /linux-2.6/arch/ia64/kernel/patch.c: In function 'ia64_patch_mckinley_e9':
> /linux-2.6/arch/ia64/kernel/patch.c:166: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
> /linux-2.6/arch/ia64/kernel/patch.c:166: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
> /linux-2.6/arch/ia64/kernel/patch.c: In function 'patch_fsyscall_table':
> /linux-2.6/arch/ia64/kernel/patch.c:202: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
> /linux-2.6/arch/ia64/kernel/patch.c: In function 'patch_brl_fsys_bubble_down':
> /linux-2.6/arch/ia64/kernel/patch.c:220: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/patch.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index b83b2c5..5660069 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -108,7 +108,7 @@ ia64_patch_vtop (unsigned long start, unsigned long end)
 
 		/* replace virtual address with corresponding physical address: */
 		ia64_patch_imm64(ip, ia64_tpa(get_imm64(ip)));
-		ia64_fc((void *) ip);
+		ia64_fc(ip);
 		++offp;
 	}
 	ia64_sync_i();
@@ -131,7 +131,7 @@ ia64_patch_rse (unsigned long start, unsigned long end)
 
 		b = (u64 *)(ip & -16);
 		b[1] &= ~0xf800000L;
-		ia64_fc((void *) ip);
+		ia64_fc(ip);
 		++offp;
 	}
 	ia64_sync_i();
@@ -162,7 +162,7 @@ ia64_patch_mckinley_e9 (unsigned long start, unsigned long end)
 		wp[1] = 0x0084006880000200UL;
 		wp[2] = 0x0000000100000000UL; /* nop.m 0; nop.i 0; nop.i 0 */
 		wp[3] = 0x0004000000000200UL;
-		ia64_fc(wp); ia64_fc(wp + 2);
+		ia64_fc((unsigned long)wp); ia64_fc((unsigned long)(wp + 2));
 		++offp;
 	}
 	ia64_sync_i();
@@ -179,7 +179,7 @@ patch_fsyscall_table (unsigned long start, unsigned long end)
 	while (offp < (s32 *) end) {
 		ip = (u64) ia64_imva((char *) offp + *offp);
 		ia64_patch_imm64(ip, (u64) fsyscall_table);
-		ia64_fc((void *) ip);
+		ia64_fc(ip);
 		++offp;
 	}
 	ia64_sync_i();
@@ -197,7 +197,7 @@ patch_brl_fsys_bubble_down (unsigned long start, unsigned long end)
 		ip = (u64) offp + *offp;
 		ia64_patch_imm60((u64) ia64_imva((void *) ip),
 				 (u64) (fsys_bubble_down - (ip & -16)) / 16);
-		ia64_fc((void *) ip);
+		ia64_fc(ip);
 		++offp;
 	}
 	ia64_sync_i();
-- 
1.6.0.2

