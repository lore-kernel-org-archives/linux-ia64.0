From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 24 Aug 2005 03:06:54 +0000
Subject: Nasty VMLPT problem...
Message-Id: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Folks,
   I've solved the problem I was having with the simulator and not
booting Debian.

The problem is that the number of bits for the virtual linear array
short-format VHPT (Virtually mapped linear page table, VMLPT for
short) is being calculated incorrectly. 

There are two problems:
      1. The PAL call that should tell the kernel the size of the
      virtual address space isn't implemented for the simulator, so
      the kernel uses the default 50.

      2.  In arch/ia64/mm/init.c there's code to calcualte the size
      of the VMLPT based on the number of implemented virtual address
      bits and the page size.  It checks to see if the VMLPT base
      address overlaps the top of the mapped region, but this check
      doesn't allow for the address space hole, and in fact will
      never trigger.

Here's an alternative panic, that I think is more accurate.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -382,13 +382,15 @@ ia64_mmu_init (void *my_cpu_data)
 
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
+	if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) || (mapped_space_bits > impl_va_bits - 1))
+		panic("Cannot build a big enough virtual-linear page table"
+		      " to cover mapped address space.\n"
+		      " Try using a smaller page size.\n");
+
 
 	/* place the VMLPT at the end of each page-table mapped region: */
 	pta = POW2(61) - POW2(vmlpt_bits);
 
-	if (POW2(mapped_space_bits) >= pta)
-		panic("mm/init: overlap between virtually mapped linear page table and "
-		      "mapped kernel space!");
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
 	 * 8 selects between the short and long format, bits 2-7 the

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
