From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Oct 2003 20:28:45 +0000
Subject: [PATCH 2.6] cannot convert region 5 address to physical by clearing bits 63:61
Message-Id: <marc-linux-ia64-106607712621564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Another no-brainer bug fix snipped out of the quagmire of
the MCA/TLB patch.  This one is for 2.6 only, we must use
the new LOAD_PHYSICAL() macro to get the physical address of
the code label that we want to jump to, the INST_VA_TO_PA()
macro just clears the region bits, which only works for region
7 addresses.

-Tony


--- old/include/asm-ia64/mca_asm.h	2003-10-13 13:08:34.474305508 -0700
+++ new/include/asm-ia64/mca_asm.h	2003-10-13 13:09:57.289734181 -0700
@@ -110,10 +110,9 @@
 	;;										\
 	dep	temp1 = -1, temp1, PSR_MC, 1;						\
 	;;										\
-	movl	temp2 = start_addr;							\
 	mov	cr.ipsr = temp1;							\
 	;;										\
-	INST_VA_TO_PA(temp2);								\
+	LOAD_PHYSICAL(p0, temp2, start_addr);						\
 	;;										\
 	mov	cr.iip = temp2;								\
 	mov	cr.ifs = r0;								\
