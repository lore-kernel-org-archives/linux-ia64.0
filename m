From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jan 2003 01:11:13 +0000
Subject: Re: [Linux-ia64] Re: [RFC] proposed change for syscall stub
Message-Id: <marc-linux-ia64-105590709805675@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805643@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805643@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

 >>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

 David> really_new_syscall_stub:
 David> 	adds r2 = SYSINFO_OFF, r13;;
 David> 	ld8 r2 = [r2]
 David> 	mov r9 = ar.pfs;;
 David> 	mov r15 = SYSCALL_NR
 David> 	mov b7 = r2
 David> 	br.call.sptk.many b6 = b7;;
 David> 	cmp.eq p6,p0 = -1, r10
 David> 	mov ar.pfs = r9
 David> (p6)	br.cond.spnt.few syscall_error
 David> 	br.ret.sptk.many rp;;

 David> Here, SYSINFO_OFF is the offset in the user-level
 David> thread-control-block at which the system call entry point is
 David> stored.  glibc initializes this value to point to the
 David> following piece of code:

 Peter> The ABI only allows 16 bytes for the TCB pointed to by R13;
 Peter> the first 8 bytes are a pointer to the dynamic thread vector,
 Peter> the second 8 bytes a pointer to the per-thread
 Peter> thread-library-private data (for linuxthreads, it points to a
 Peter> _pthread_descr)

Correct.

 Peter> So is the idea to extend the TCB (in contravention of the
 Peter> current ABI), or should this code have an extra level of
 Peter> indirection, to get at the sysinfo field from the
 Peter> library-specific structure?

The ABI only regulates positive offsets.  The current glibc stores the
actual (p-)thread-control block _below_ the thread-pointer.  I have a
glibc prototype which stores the sysinfo pointer at offset -8.  Seems
to work fine so far (see
http://sources.redhat.com/ml/libc-hacker/2003-01/msg00118.html).

BTW: I forgot that "r9" is used by some syscalls (e.g., pipe()) to
return a second value, so we can't use it in the syscall stub to
preserve ar.pfs.  I changed the stub to use "r11" instead (which
should be safe) and, while doing that, also added the necessary unwind
directives.  So the stub now stands at:

REALLY_new_syscall_stub:
	.prologue
 	adds r2 = SYSINFO_OFF, r13;;
 	ld8 r2 = [r2]
	.save ar.pfs, r11
 	mov r11 = ar.pfs;;
	.body
 	mov r15 = SYSCALL_NR
 	mov b7 = r2
 	br.call.sptk.many b6 = b7;;
 	cmp.eq p6,p0 = -1, r10
	.restore sp
 	mov ar.pfs = r11
(p6)	br.cond.spnt.few syscall_error
 	br.ret.sptk.many rp;;

I should have a kernel patch out soon (perhaps tonight) which will add
fsys-mode (light-weight system call) support to the kernel.  (Only for
getpid at the moment; I mainly care about getting the infrastructure
in place, we can add lightweight syscall handlers over time.)

	--david

