From: Simon Horman <horms@verge.net.au>
Date: Mon, 29 Oct 2007 08:10:29 +0000
Subject: [PATCH] vmcore_find_descriptor_size should be in __init
Message-Id: <20071029081027.GA30256@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Eric Biederman <ebiederm@xmission.com>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>

vmcore_find_descriptor_size() is only called by
reserve_elfcorehdr(), which is in __init, so it seems to me that
vmcore_find_descriptor_size() should be there too.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-03-06 16:43:11.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-03-06 16:43:25.000000000 +0900
@@ -1180,7 +1180,7 @@
 
 #ifdef CONFIG_PROC_VMCORE
 /* locate the size find a the descriptor at a certain address */
-unsigned long
+unsigned long __init
 vmcore_find_descriptor_size (unsigned long address)
 {
 	void *efi_map_start, *efi_map_end, *p;

