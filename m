From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Nov 2004 19:33:04 +0000
Subject: [PATCH 2.6.10-rc2-mm1] Fix ia64 pml4 build problem
Message-Id: <200411171233.04881.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_wd6mBq3WGa+tyyD"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_wd6mBq3WGa+tyyD
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Fix ia64 pml4 build problem (looks like a fat-finger error to me).

--Boundary-00=_wd6mBq3WGa+tyyD
Content-Type: text/x-diff;
  charset="us-ascii";
  name="pml4-ia64-build-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pml4-ia64-build-fix.patch"

Fix ia64 pml4 build problem (looks like a fat-finger error to me).

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

--- a/include/asm-ia64/pgtable.h.orig	2004-11-17 10:09:38.537890000 -0700
+++ b/include/asm-ia64/pgtable.h	2004-11-17 10:09:57.500780555 -0700
@@ -317,7 +317,7 @@
 /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
    resides in the kernel-mapped segment, hence we use pgd_offset_k()
    here.  */
-#define pml4_offset_gate(mm, addr)	pml4_offset_k(pml4_offset_k(addr),addr)
+#define pml4_offset_gate(mm, addr)	pml4_offset_k(addr)
 
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir,addr) \

--Boundary-00=_wd6mBq3WGa+tyyD--
