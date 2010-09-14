From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 14 Sep 2010 06:06:34 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <1284444394.29843.251.camel@nathan.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Luck, Tony píše v Po 13. 09. 2010 v 11:33 -0700:
> Hi Linus,
> 
> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> 
> This will update the files shown below.

Hi Tony,

oops, it seems I shouldn't have gone on a short vacation with the
kids... :/

Actually, your patch works perfectly for me, but it spoils the highly
optimized fsyscall, so I invested some additional time into it and came
up with the following:

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

 arch/ia64/kernel/fsys.S |   33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff -u a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- a/arch/ia64/kernel/fsys.S	2009-12-03 04:51:21.000000000 +0100
+++ b/arch/ia64/kernel/fsys.S	2010-09-14 08:00:20.000000000 +0200
@@ -420,22 +420,30 @@
 	;;
 
 	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
-	mov ar.ccv=0
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
+	mov r8=EINVAL			// default to EINVAL
 
 #ifdef CONFIG_SMP
-	mov r17=1
-	;;
-	cmpxchg4.acq r18=[r31],r17,ar.ccv	// try to acquire the lock
-	mov r8=EINVAL			// default to EINVAL
+	// __ticket_spin_trylock(r31)
+	ld4 r17=[r31]
 	;;
+	mov.m ar.ccv=r17
+	extr.u r9=r17,17,15
+	adds r19=1,r17
+	extr.u r18=r17,0,15
+	;;
+	cmp.eq p6,p7=r9,r18
+	;;
+(p6)	cmpxchg4.acq r9=[r31],r19,ar.ccv
+(p6)	dep.z r20=r19,1,15		// next serving ticket for unlock
+(p7)	br.cond.spnt.many .lock_contention
+	;;
+	cmp4.eq p0,p7=r9,r17
+	adds r31=2,r31
+(p7)	br.cond.spnt.many .lock_contention
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	cmp4.ne p6,p0=r18,r0
-(p6)	br.cond.spnt.many .lock_contention
 	;;
 #else
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	mov r8=EINVAL			// default to EINVAL
 #endif
 	add r18=IA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
 	add r19=IA64_TASK_SIGNAL_OFFSET,r16
@@ -490,7 +499,10 @@
 (p6)	br.cond.spnt.few 1b			// yes -> retry
 
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	// __ticket_spin_unlock(r31)
+	st2.rel [r31]=r20
+	mov r20=0					// i must not leak kernel bits...
 #endif
 	SSM_PSR_I(p0, p9, r31)
 	;;
@@ -512,7 +524,8 @@
 
 .sig_pending:
 #ifdef CONFIG_SMP
-	st4.rel [r31]=r0			// release the lock
+	// __ticket_spin_unlock(r31)
+	st2.rel [r31]=r20			// release the lock
 #endif
 	SSM_PSR_I(p0, p9, r17)
 	;;


