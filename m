From: Simon Horman <horms@verge.net.au>
Date: Wed, 19 Sep 2007 05:02:20 +0000
Subject: [IA64] Kexec: Remove vector from ia64_machine_kexec()
Message-Id: <20070919050626.8A0024F811@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Eric Biederman <ebiederm@xmission.com>, Nan hai Zou <nanhai.zou@intel.com>, Tony Luck <tony.luck@intel.com>, Alex Williamson <alex.williamson@hp.com>

The use of vector in ia64_machine_kexec() seems spurios,
and removing it simplifies the code slightly.

As suggested by Alex Williamson <alex.williamson@hp.com>

Cc: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2007-09-19 13:43:42.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2007-09-19 13:44:11.000000000 +0900
@@ -79,7 +79,6 @@ static void ia64_machine_kexec(struct un
 	relocate_new_kernel_t rnk;
 	void *pal_addr = efi_get_pal_addr();
 	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
-	unsigned long vector;
 	int ii;
 
 	BUG_ON(!image);
@@ -107,11 +106,8 @@ static void ia64_machine_kexec(struct un
 	/* unmask TPR and clear any pending interrupts */
 	ia64_setreg(_IA64_REG_CR_TPR, 0);
 	ia64_srlz_d();
-	vector = ia64_get_ivr();
-	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+	while (ia64_get_ivr() != IA64_SPURIOUS_INT_VECTOR)
 		ia64_eoi();
-		vector = ia64_get_ivr();
-	}
 	platform_kernel_launch_event();
 	rnk = (relocate_new_kernel_t)&code_addr;
 	(*rnk)(image->head, image->start, ia64_boot_param,
