From: Keith Owens <kaos@sgi.com>
Date: Thu, 13 Mar 2003 21:59:54 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 Mar 2003 11:16:26 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>It should be easy to fix: save ar.pfs in a scratch register, then use
>br.call/brl.call to invoke the ia64_spinlock_contention.  Then
>everything will work out properly.

To avoid disturbing leaf functions, spin_lock() would have to both save
and restore ar.pfs, increasing the number of bundles.  To make unwind
work through spin_lock() that modifies ar.pfs, spin_lock() would need
unwind directives, including prologue, body and epilogue records.  That
would significantly increase the amount of unwind data for anything
that uses spin locks.  I originally used br.call but the side effects
of trying to hide the changes to ar.pfs from gcc to avoid converting
leaf functions to interior were too high.

All is not lost, there is one spare slot in spin_lock which can clear
r29 (dummy ar.pfs) before entering ia64_spinlock_contention.  If I have
my unwind directives right, this should close the 1 instruction unwind
window.  David, can you confirm?  McKinley version, not Itanium.

include/asm-ia64/spinlock.h

#define spin_lock(x) 									\
({											\
	register char *addr __asm__ ("r31") = (char *) &(x)->lock;			\
											\
	__asm__ __volatile__ (								\
		"1:\n"		/* force a new bundle, r28 points here */		\
		"mov ar.ccv=r0\n"							\
		"mov r28=ip\n"								\
		"mov r30=1\n"								\
		";;\n"									\
		"cmpxchg4.acq r30=[%0],r30,ar.ccv\n"					\
		";;\n"									\
		"cmp.ne p15,p0=r30,r0\n"						\
		";;\n"									\
		"mov r29=0\n"								\
		"(p15) brl.cond.spnt.few ia64_spinlock_contention\n"			\
		";;\n"									\
		"2:\n"		/* force a new bundle */				\
		:: "r"(addr)								\
		: "ar.ccv", "r28", "r29", "r30", "b7", "p15", "memory");		\
})

arch/ia64/kernel/head.S

GLOBAL_ENTRY(ia64_spinlock_contention)
	// To get decent unwind data, lie about our state
	.prologue
	.save ar.pfs, r29	// r29 = 0 from spin_lock()
	.save rp, r28		// r28 = my "return" address
	mov b7=r28
	.altrp b7
	;;
	.body
.retry:
	// exponential backoff, kdb, lockmeter etc. go in here
	//
	;;
	ld4 r28=[r31]
	;;
	cmp4.eq p15,p0=r28,r0
(p15)	br.cond.spnt.few b7	// lock is now free, try to acquire
	br.cond.sptk.few .retry

END(ia64_spinlock_contention)


