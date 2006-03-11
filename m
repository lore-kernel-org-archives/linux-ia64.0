From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 11 Mar 2006 00:34:05 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200603110034.k2B0Y5F7018851@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/ivt.S |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

Christoph Lameter:
      [IA64] Fix race in the accessed/dirty bit handlers

diff-tree d8117ce5a679ff1f48df247da30fb62c16d562c5 (from 2ec5e3a867d63d04932e11c6097f63760d9be3fe)
Author: Christoph Lameter <clameter@engr.sgi.com>
Date:   Tue Mar 7 19:05:32 2006 -0800

    [IA64] Fix race in the accessed/dirty bit handlers
    
    A pte may be zapped by the swapper, exiting process, unmapping or page
    migration while the accessed or dirty bit handers are about to run. In that
    case the accessed bit or dirty is set on an zeroed pte which leads the VM to
    conclude that this is a swap pte. This may lead to
    
    - Messages from the vm like
    
    swap_free: Bad swap file entry 4000000000000000
    
    - Processes being aborted
    
    swap_dup: Bad swap file entry 4000000000000000
    VM: killing process ....
    
    Page migration is particular suitable for the creation of this race since
    it needs to remove and restore page table entries.
    
    The fix here is to check for the present bit and simply not update
    the pte if the page is not present anymore. If the page is not present
    then the fault handler should run next which will take care of the problem
    by bringing the page back and then mark the page dirty or move it onto the
    active list.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 9f80569..dcd906f 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -561,11 +561,12 @@ ENTRY(dirty_bit)
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
+	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
 	;;
-	cmpxchg8.acq r26=[r17],r25,ar.ccv
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only update if page is present
 	mov r24=PAGE_SHIFT<<2
 	;;
-	cmp.eq p6,p7=r26,r18
+(p6)	cmp.eq p6,p7=r26,r18			// Only compare if page is present
 	;;
 (p6)	itc.d r25				// install updated PTE
 	;;
@@ -626,11 +627,12 @@ ENTRY(iaccess_bit)
 	;;
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_A,r18			// set the accessed bit
+	tbit.z p7,p6 = r18,_PAGE_P_BIT	 	// Check present bit
 	;;
-	cmpxchg8.acq r26=[r17],r25,ar.ccv
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only if page present
 	mov r24=PAGE_SHIFT<<2
 	;;
-	cmp.eq p6,p7=r26,r18
+(p6)	cmp.eq p6,p7=r26,r18			// Only if page present
 	;;
 (p6)	itc.i r25				// install updated PTE
 	;;
@@ -680,11 +682,12 @@ ENTRY(daccess_bit)
 	;;					// avoid RAW on r18
 	mov ar.ccv=r18				// set compare value for cmpxchg
 	or r25=_PAGE_A,r18			// set the dirty bit
+	tbit.z p7,p6 = r18,_PAGE_P_BIT		// Check present bit
 	;;
-	cmpxchg8.acq r26=[r17],r25,ar.ccv
+(p6)	cmpxchg8.acq r26=[r17],r25,ar.ccv	// Only if page is present
 	mov r24=PAGE_SHIFT<<2
 	;;
-	cmp.eq p6,p7=r26,r18
+(p6)	cmp.eq p6,p7=r26,r18			// Only if page is present
 	;;
 (p6)	itc.d r25				// install updated PTE
 	/*
