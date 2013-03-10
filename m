From: Stephan Schreiber <info@fs-driver.org>
Date: Sun, 10 Mar 2013 18:12:30 +0000
Subject: [RFC/PATCH] ia64, wrong asm register contraints in the kvm implementation
Message-Id: <20130310191230.Horde.Sp6uaruWis5RPM0Ob2rz_mA@webmail.df.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130310191035.Horde.hLGbcLuWis5RPMybvnhj86A@webmail.df.eu>
In-Reply-To: <20130310191035.Horde.hLGbcLuWis5RPMybvnhj86A@webmail.df.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kvm-ia64@vger.kernel.org
Cc: alan@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, 70639@bugs.debian.org

The Linux Kernel contains some inline assembly source code which has  
wrong asm register constraints in arch/ia64/kvm/vtlb.c.

I observed this on Kernel 3.2.35 but it is also true on the most  
recent Kernel 3.9-rc1.

File arch/ia64/kvm/vtlb.c:

u64 guest_vhpt_lookup(u64 iha, u64 *pte)
{
	u64 ret;
	struct thash_data *data;

	data = __vtr_lookup(current_vcpu, iha, D_TLB);
	if (data != NULL)
		thash_vhpt_insert(current_vcpu, data->page_flags,
			data->itir, iha, D_TLB);

	asm volatile (
			"rsm psr.ic|psr.i;;"
			"srlz.d;;"
			"ld8.s r9=[%1];;"
			"tnat.nz p6,p7=r9;;"
			"(p6) mov %0=1;"
			"(p6) mov r9=r0;"
			"(p7) extr.u r9=r9,0,53;;"
			"(p7) mov %0=r0;"
			"(p7) st8 [%2]=r9;;"
			"ssm psr.ic;;"
			"srlz.d;;"
			"ssm psr.i;;"
			"srlz.d;;"
			: "=r"(ret) : "r"(iha), "r"(pte):"memory");

	return ret;
}

The list of output registers is
			: "=r"(ret) : "r"(iha), "r"(pte):"memory");
The constraint "=r" means that the GCC has to maintain that these vars  
are in registers and contain valid info when the program flow leaves  
the assembly block (output registers).
But "=r" also means that GCC can put them in registers that are used  
as input registers. Input registers are iha, pte on the example.
If the predicate p7 is true, the 8th assembly instruction
			"(p7) mov %0=r0;"
is the first one which writes to a register which is maintained by the  
register constraints; it sets %0. %0 means the first register operand;  
it is ret here.
This instruction might overwrite the %2 register (pte) which is needed  
by the next instruction:
			"(p7) st8 [%2]=r9;;"
Whether it really happens depends on how GCC decides what registers it  
uses and how it optimizes the code.


The attached patch  fixes the register operand constraints in  
arch/ia64/kvm/vtlb.c.
The register constraints should be
			: "=&r"(ret) : "r"(iha), "r"(pte):"memory");
The & means that GCC must not use any of the input registers to place  
this output register in.


This is Debian bug#702639  
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bugp2639).

The patch is applicable on Kernel 3.9-rc1, 3.2.35 and many other versions.





--- a/arch/ia64/kvm/vtlb.c.orig	2013-03-03 16:37:27.000000000 +0100
+++ b/arch/ia64/kvm/vtlb.c	2013-03-03 16:42:33.000000000 +0100
@@ -246,27 +246,27 @@ u64 guest_vhpt_lookup(u64 iha, u64 *pte)
  	asm volatile ("rsm psr.ic|psr.i;;"
  			"srlz.d;;"
  			"ld8.s r9=[%1];;"
  			"tnat.nz p6,p7=r9;;"
  			"(p6) mov %0=1;"
  			"(p6) mov r9=r0;"
  			"(p7) extr.u r9=r9,0,53;;"
  			"(p7) mov %0=r0;"
  			"(p7) st8 [%2]=r9;;"
  			"ssm psr.ic;;"
  			"srlz.d;;"
  			"ssm psr.i;;"
  			"srlz.d;;"
-			: "=r"(ret) : "r"(iha), "r"(pte):"memory");
+			: "=&r"(ret) : "r"(iha), "r"(pte) : "memory");

  	return ret;
  }

  /*
   *  purge software guest tlb
   */

  static void vtlb_purge(struct kvm_vcpu *v, u64 va, u64 ps)
  {
  	struct thash_data *cur;
  	u64 start, curadr, size, psbits, tag, rr_ps, num;
  	union ia64_rr vrr;

Cc: stable@vger.kernel.org
Signed-off-by: Stephan Schreiber <info@fs-driver.org>

