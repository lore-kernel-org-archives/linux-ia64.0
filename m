From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 Sep 2005 22:51:08 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200509222251.j8MMp8LZ004692@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
In-Reply-To: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/simscsi.c |   29 ++++++++++---
 arch/ia64/kernel/mca_asm.S |   96 +++++++++++++++++++++++++++++++++++++++------
 arch/ia64/kernel/mca_drv.c |   21 +++++++--
 include/asm-ia64/mca.h     |    5 ++
 4 files changed, 128 insertions(+), 23 deletions(-)

Hidetoshi Seto:
  [IA64] MCA recovery verify pfn_valid

Keith Owens:
  [IA64] Wire in the MCA/INIT handler stacks

Peter Chubb:
  [IA64] Fix simscsi for new SCSI midlayer


$ git-whatchanged -p release ^linus
diff-tree 4881e2cd25d2d9cf9fca263caff3a0ce732d7d6b (from 20bb86852a6b7d9ca8c48ff921ff3904038959cf)
Author: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date:   Tue Sep 20 16:34:41 2005 +0900

    [IA64] MCA recovery verify pfn_valid
    
    Verify the pfn is valid before calling pfn_to_page(),
    and cut isolation message if nothing was done.
    
    Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
    Acked-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -56,8 +56,9 @@ static struct page *page_isolate[MAX_PAG
 static int num_page_isolate = 0;
 
 typedef enum {
-	ISOLATE_NG = 0,
-	ISOLATE_OK = 1
+	ISOLATE_NG,
+	ISOLATE_OK,
+	ISOLATE_NONE
 } isolate_status_t;
 
 /*
@@ -74,7 +75,7 @@ static struct {
  * @paddr:	poisoned memory location
  *
  * Return value:
- *	ISOLATE_OK / ISOLATE_NG
+ *	one of isolate_status_t, ISOLATE_OK/NG/NONE.
  */
 
 static isolate_status_t
@@ -85,7 +86,10 @@ mca_page_isolate(unsigned long paddr)
 
 	/* whether physical address is valid or not */
 	if (!ia64_phys_addr_valid(paddr))
-		return ISOLATE_NG;
+		return ISOLATE_NONE;
+
+	if (!pfn_valid(paddr))
+		return ISOLATE_NONE;
 
 	/* convert physical address to physical page number */
 	p = pfn_to_page(paddr>>PAGE_SHIFT);
@@ -122,10 +126,15 @@ mca_handler_bh(unsigned long paddr)
 		current->pid, current->comm);
 
 	spin_lock(&mca_bh_lock);
-	if (mca_page_isolate(paddr) = ISOLATE_OK) {
+	switch (mca_page_isolate(paddr)) {
+	case ISOLATE_OK:
 		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
-	} else {
+		break;
+	case ISOLATE_NG:
 		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+		break;
+	default:
+		break;
 	}
 	spin_unlock(&mca_bh_lock);
 

diff-tree 20bb86852a6b7d9ca8c48ff921ff3904038959cf (from 83a78d9ba792660418d692fd6737871aefdbff36)
Author: Keith Owens <kaos@sgi.com>
Date:   Thu Sep 22 18:49:15 2005 +1000

    [IA64] Wire in the MCA/INIT handler stacks
    
    Wire the MCA/INIT handler stacks into DTR[2] and track them in
    IA64_KR(CURRENT_STACK).  This gives the MCA/INIT handler stacks the
    same TLB status as normal kernel stacks.  Reload the old CURRENT_STACK
    data on return from OS to SAL.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -489,24 +489,27 @@ ia64_state_save:
 	;;
 	st8 [temp1]=r17,16	// pal_min_state
 	st8 [temp2]=r6,16	// prev_IA64_KR_CURRENT
+	mov r6=IA64_KR(CURRENT_STACK)
+	;;
+	st8 [temp1]=r6,16	// prev_IA64_KR_CURRENT_STACK
+	st8 [temp2]=r0,16	// prev_task, starts off as NULL
 	mov r6=cr.ifa
 	;;
-	st8 [temp1]=r0,16	// prev_task, starts off as NULL
-	st8 [temp2]=r12,16	// cr.isr
+	st8 [temp1]=r12,16	// cr.isr
+	st8 [temp2]=r6,16	// cr.ifa
 	mov r12=cr.itir
 	;;
-	st8 [temp1]=r6,16	// cr.ifa
-	st8 [temp2]=r12,16	// cr.itir
+	st8 [temp1]=r12,16	// cr.itir
+	st8 [temp2]=r11,16	// cr.iipa
 	mov r12=cr.iim
 	;;
-	st8 [temp1]=r11,16	// cr.iipa
-	st8 [temp2]=r12,16	// cr.iim
-	mov r6=cr.iha
+	st8 [temp1]=r12,16	// cr.iim
 (p1)	mov r12=IA64_MCA_COLD_BOOT
 (p2)	mov r12=IA64_INIT_WARM_BOOT
+	mov r6=cr.iha
 	;;
-	st8 [temp1]=r6,16	// cr.iha
-	st8 [temp2]=r12		// os_status, default is cold boot
+	st8 [temp2]=r6,16	// cr.iha
+	st8 [temp1]=r12		// os_status, default is cold boot
 	mov r6=IA64_MCA_SAME_CONTEXT
 	;;
 	st8 [temp1]=r6		// context, default is same context
@@ -823,9 +826,12 @@ ia64_state_restore:
 	ld8 r12=[temp1],16	// sal_ra
 	ld8 r9=[temp2],16	// sal_gp
 	;;
-	ld8 r22=[temp1],24	// pal_min_state, virtual.  skip prev_task
+	ld8 r22=[temp1],16	// pal_min_state, virtual
 	ld8 r21=[temp2],16	// prev_IA64_KR_CURRENT
 	;;
+	ld8 r16=[temp1],16	// prev_IA64_KR_CURRENT_STACK
+	ld8 r20=[temp2],16	// prev_task
+	;;
 	ld8 temp3=[temp1],16	// cr.isr
 	ld8 temp4=[temp2],16	// cr.ifa
 	;;
@@ -846,6 +852,45 @@ ia64_state_restore:
 	ld8 r8=[temp1]		// os_status
 	ld8 r10=[temp2]		// context
 
+	/* Wire IA64_TR_CURRENT_STACK to the stack that we are resuming to.  To
+	 * avoid any dependencies on the algorithm in ia64_switch_to(), just
+	 * purge any existing CURRENT_STACK mapping and insert the new one.
+	 *
+	 * r16 contains prev_IA64_KR_CURRENT_STACK, r21 contains
+	 * prev_IA64_KR_CURRENT, these values may have been changed by the C
+	 * code.  Do not use r8, r9, r10, r22, they contain values ready for
+	 * the return to SAL.
+	 */
+
+	mov r15=IA64_KR(CURRENT_STACK)		// physical granule mapped by IA64_TR_CURRENT_STACK
+	;;
+	shl r15=r15,IA64_GRANULE_SHIFT
+	;;
+	dep r15=-1,r15,61,3			// virtual granule
+	mov r18=IA64_GRANULE_SHIFT<<2		// for cr.itir.ps
+	;;
+	ptr.d r15,r18
+	;;
+	srlz.d
+
+	extr.u r19=r21,61,3			// r21 = prev_IA64_KR_CURRENT
+	shl r20=r16,IA64_GRANULE_SHIFT		// r16 = prev_IA64_KR_CURRENT_STACK
+	movl r21=PAGE_KERNEL			// page properties
+	;;
+	mov IA64_KR(CURRENT_STACK)=r16
+	cmp.ne p6,p0=RGN_KERNEL,r19		// new stack is in the kernel region?
+	or r21=r20,r21				// construct PA | page properties
+(p6)	br.spnt 1f				// the dreaded cpu 0 idle task in region 5:(
+	;;
+	mov cr.itir=r18
+	mov cr.ifa=r21
+	mov r20=IA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r20]=r21
+	;;
+	srlz.d
+1:
+
 	br.sptk b0
 
 //EndStub//////////////////////////////////////////////////////////////////////
@@ -982,6 +1027,7 @@ ia64_set_kernel_registers:
 	add temp4=temp4, temp1	// &struct ia64_sal_os_state.os_gp
 	add r12=temp1, temp3	// kernel stack pointer on MCA/INIT stack
 	add r13=temp1, r3	// set current to start of MCA/INIT stack
+	add r20=temp1, r3	// physical start of MCA/INIT stack
 	;;
 	ld8 r1=[temp4]		// OS GP from SAL OS state
 	;;
@@ -991,7 +1037,35 @@ ia64_set_kernel_registers:
 	;;
 	mov IA64_KR(CURRENT)=r13
 
-	// FIXME: do I need to wire IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK?
+	/* Wire IA64_TR_CURRENT_STACK to the MCA/INIT handler stack.  To avoid
+	 * any dependencies on the algorithm in ia64_switch_to(), just purge
+	 * any existing CURRENT_STACK mapping and insert the new one.
+	 */
+
+	mov r16=IA64_KR(CURRENT_STACK)		// physical granule mapped by IA64_TR_CURRENT_STACK
+	;;
+	shl r16=r16,IA64_GRANULE_SHIFT
+	;;
+	dep r16=-1,r16,61,3			// virtual granule
+	mov r18=IA64_GRANULE_SHIFT<<2		// for cr.itir.ps
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+
+	shr.u r16=r20,IA64_GRANULE_SHIFT	// r20 = physical start of MCA/INIT stack
+	movl r21=PAGE_KERNEL			// page properties
+	;;
+	mov IA64_KR(CURRENT_STACK)=r16
+	or r21=r20,r21				// construct PA | page properties
+	;;
+	mov cr.itir=r18
+	mov cr.ifa=r13
+	mov r20=IA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r20]=r21
+	;;
+	srlz.d
 
 	br.sptk b0
 
diff --git a/include/asm-ia64/mca.h b/include/asm-ia64/mca.h
--- a/include/asm-ia64/mca.h
+++ b/include/asm-ia64/mca.h
@@ -80,7 +80,12 @@ struct ia64_sal_os_state {
 	u64			sal_ra;			/* Return address in SAL, physical */
 	u64			sal_gp;			/* GP of the SAL - physical */
 	pal_min_state_area_t	*pal_min_state;		/* from R17.  physical in asm, virtual in C */
+	/* Previous values of IA64_KR(CURRENT) and IA64_KR(CURRENT_STACK).
+	 * Note: if the MCA/INIT recovery code wants to resume to a new context
+	 * then it must change these values to reflect the new kernel stack.
+	 */
 	u64			prev_IA64_KR_CURRENT;	/* previous value of IA64_KR(CURRENT) */
+	u64			prev_IA64_KR_CURRENT_STACK;
 	struct task_struct	*prev_task;		/* previous task, NULL if it is not useful */
 	/* Some interrupt registers are not saved in minstate, pt_regs or
 	 * switch_stack.  Because MCA/INIT can occur when interrupts are

diff-tree 83a78d9ba792660418d692fd6737871aefdbff36 (from 0fc084eaffe0a9a82a0c94da9ee9f7060ade8b04)
Author: Peter Chubb <peterc@gelato.unsw.edu.au>
Date:   Mon Sep 19 09:36:12 2005 +1000

    [IA64] Fix simscsi for new SCSI midlayer
    
    The sd driver now uses scsi_execute_req() for almost everything.
    scsi_execute_req() converts requests into scatterlists.
    
    Fix the HP SCSI disk simulator to understand scatterlists for
    more commands.
    
    Without this patch the current kernel will not boot on the simulator
    (the disks are always detected as having no sectors, and so cannot be
    mounted).
    
    Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -233,6 +233,23 @@ simscsi_readwrite10 (struct scsi_cmnd *s
 		simscsi_readwrite(sc, mode, offset, ((sc->cmnd[7] << 8) | sc->cmnd[8])*512);
 }
 
+static void simscsi_fillresult(struct scsi_cmnd *sc, char *buf, unsigned len)
+{
+
+	int scatterlen = sc->use_sg;
+	struct scatterlist *slp;
+
+	if (scatterlen = 0)
+		memcpy(sc->request_buffer, buf, len);
+	else for (slp = (struct scatterlist *)sc->buffer; scatterlen-- > 0 && len > 0; slp++) {
+		unsigned thislen = min(len, slp->length);
+
+		memcpy(page_address(slp->page) + slp->offset, buf, thislen);
+		slp++;
+		len -= thislen;
+	}
+}
+
 static int
 simscsi_queuecommand (struct scsi_cmnd *sc, void (*done)(struct scsi_cmnd *))
 {
@@ -240,6 +257,7 @@ simscsi_queuecommand (struct scsi_cmnd *
 	char fname[MAX_ROOT_LEN+16];
 	size_t disk_size;
 	char *buf;
+	char localbuf[36];
 #if DEBUG_SIMSCSI
 	register long sp asm ("sp");
 
@@ -263,7 +281,7 @@ simscsi_queuecommand (struct scsi_cmnd *
 				/* disk doesn't exist... */
 				break;
 			}
-			buf = sc->request_buffer;
+			buf = localbuf;
 			buf[0] = 0;	/* magnetic disk */
 			buf[1] = 0;	/* not a removable medium */
 			buf[2] = 2;	/* SCSI-2 compliant device */
@@ -273,6 +291,7 @@ simscsi_queuecommand (struct scsi_cmnd *
 			buf[6] = 0;	/* reserved */
 			buf[7] = 0;	/* various flags */
 			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
+			simscsi_fillresult(sc, buf, 36);
 			sc->result = GOOD;
 			break;
 
@@ -304,16 +323,13 @@ simscsi_queuecommand (struct scsi_cmnd *
 			simscsi_readwrite10(sc, SSC_WRITE);
 			break;
 
-
 		      case READ_CAPACITY:
 			if (desc[target_id] < 0 || sc->request_bufflen < 8) {
 				break;
 			}
-			buf = sc->request_buffer;
-
+			buf = localbuf;
 			disk_size = simscsi_get_disk_size(desc[target_id]);
 
-			/* pretend to be a 1GB disk (partition table contains real stuff): */
 			buf[0] = (disk_size >> 24) & 0xff;
 			buf[1] = (disk_size >> 16) & 0xff;
 			buf[2] = (disk_size >>  8) & 0xff;
@@ -323,13 +339,14 @@ simscsi_queuecommand (struct scsi_cmnd *
 			buf[5] = 0;
 			buf[6] = 2;
 			buf[7] = 0;
+			simscsi_fillresult(sc, buf, 8);
 			sc->result = GOOD;
 			break;
 
 		      case MODE_SENSE:
 		      case MODE_SENSE_10:
 			/* sd.c uses this to determine whether disk does write-caching. */
-			memset(sc->request_buffer, 0, 128);
+			simscsi_fillresult(sc, (char *)empty_zero_page, sc->request_bufflen);
 			sc->result = GOOD;
 			break;
 
