From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 14 Sep 2010 07:02:09 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <1284447729.29843.302.camel@nathan.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Petr Tesarik píše v Út 14. 09. 2010 v 08:06 +0200:
> Luck, Tony píše v Po 13. 09. 2010 v 11:33 -0700:
> > Hi Linus,
> > 
> > please pull from:
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> > 
> > This will update the files shown below.
> 
> Hi Tony,
> 
> oops, it seems I shouldn't have gone on a short vacation with the
> kids... :/
> 
> Actually, your patch works perfectly for me, but it spoils the highly
> optimized fsyscall, so I invested some additional time into it and came
> up with the following:

Argh, once more, re-based to the current tree and with correct patch
headers:

Optimize ticket spinlocks in fsys_rt_sigprocmask

Tony's fix works perfectly, but it adds more instructions than
necessary. Optimize the fast path again.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 fsys-optimized.S |   42 +++++++++++-------------------------------
 1 file changed, 11 insertions(+), 31 deletions(-)

diff -u a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys-optimized.S
--- a/arch/ia64/kernel/fsys.S	2010-09-14 09:11:07.000000000 +0200
+++ b/arch/ia64/kernel/fsys-optimized.S	2010-09-14 09:10:28.000000000 +0200
@@ -420,34 +420,31 @@
 	;;
 
 	RSM_PSR_I(p0, r18, r19)			// mask interrupt delivery
-	mov ar.ccv=0
 	andcm r14=r14,r17			// filter out SIGKILL & SIGSTOP
+	mov r8=EINVAL			// default to EINVAL
 
 #ifdef CONFIG_SMP
 	// __ticket_spin_trylock(r31)
 	ld4 r17=[r31]
-	mov r8=EINVAL			// default to EINVAL
-	;;
-	extr r9=r17,17,15
 	;;
-	xor r18=r17,r9
+	mov.m ar.ccv=r17
+	extr.u r9=r17,17,15
 	adds r19=1,r17
+	extr.u r18=r17,0,15
 	;;
-	extr.u r18=r18,0,15
+	cmp.eq p6,p7=r9,r18
 	;;
-	cmp.eq p0,p7=0,r18
+(p6)	cmpxchg4.acq r9=[r31],r19,ar.ccv
+(p6)	dep.z r20=r19,1,15		// next serving ticket for unlock
 (p7)	br.cond.spnt.many .lock_contention
-	mov.m ar.ccv=r17
-	;;
-	cmpxchg4.acq r9=[r31],r19,ar.ccv
 	;;
 	cmp4.eq p0,p7=r9,r17
+	adds r31=2,r31
 (p7)	br.cond.spnt.many .lock_contention
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
 	;;
 #else
 	ld8 r3=[r2]			// re-read current->blocked now that we hold the lock
-	mov r8=EINVAL			// default to EINVAL
 #endif
 	add r18=IA64_TASK_PENDING_OFFSET+IA64_SIGPENDING_SIGNAL_OFFSET,r16
 	add r19=IA64_TASK_SIGNAL_OFFSET,r16
@@ -503,16 +500,8 @@
 
 #ifdef CONFIG_SMP
 	// __ticket_spin_unlock(r31)
-	adds r31=2,r31
-	;;
-	ld2.bias r2=[r31]
-	mov r3e534
-	;;
-	adds r2=2,r2
-	;;
-	and r3=r3,r2
-	;;
-	st2.rel [r31]=r3
+	st2.rel [r31]=r20
+	mov r20=0					// i must not leak kernel bits...
 #endif
 	SSM_PSR_I(p0, p9, r31)
 	;;
@@ -535,16 +524,7 @@
 .sig_pending:
 #ifdef CONFIG_SMP
 	// __ticket_spin_unlock(r31)
-	adds r31=2,r31
-	;;
-	ld2.bias r2=[r31]
-	mov r3e534
-	;;
-	adds r2=2,r2
-	;;
-	and r3=r3,r2
-	;;
-	st2.rel [r31]=r3
+	st2.rel [r31]=r20			// release the lock
 #endif
 	SSM_PSR_I(p0, p9, r17)
 	;;


