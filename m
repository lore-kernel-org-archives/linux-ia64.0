From: Bob Picco <Robert.Picco@hp.com>
Date: Wed, 12 Jan 2005 01:39:29 +0000
Subject: [PATCH] small optimization in ia64_leave_kernel
Message-Id: <20050112025259.GI6314@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony:

When returning to the kernel and not switching rbs, avoid fetching 
local_cpu_data.  More could possibly be optimized here but limited registers 
are available and the number of bundles might increase.  I didn't pursue any 
further than predicating two instructions which eliminates a memory fetch.


thanks,

bob

Signed-off-by: Bob Picco <robert.picco@hp.com>

diff -ruNp -X /home/picco/losl/dontdiff linux-2.6.10-orig/arch/ia64/kernel/entry.S linux-2.6.10/arch/ia64/kernel/entry.S
--- linux-2.6.10-orig/arch/ia64/kernel/entry.S	2005-01-04 19:06:14.000000000 -0500
+++ linux-2.6.10/arch/ia64/kernel/entry.S	2005-01-08 15:47:45.000000000 -0500
@@ -925,9 +925,9 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	shr.u r18=r19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=ar.bsp		// get existing backing store pointer
-	addl r17=THIS_CPU(ia64_phys_stacked_size_p8),r0
+(pUStk) addl r17=THIS_CPU(ia64_phys_stacked_size_p8),r0
 	;;
-	ld4 r17=[r17]		// r17 = cpu_data->phys_stacked_size_p8
+(pUStk) ld4 r17=[r17]		// r17 = cpu_data->phys_stacked_size_p8
 (pKStk)	br.cond.dpnt skip_rbs_switch
 
 	/*


