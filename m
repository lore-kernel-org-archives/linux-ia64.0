From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 15 Jan 2003 00:53:48 +0000
Subject: [Linux-ia64] Re: [RFC] proposed change for syscall stub
Message-Id: <marc-linux-ia64-105590709805674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805643@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805643@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:


really_new_syscall_stub: 
	adds r2 = SYSINFO_OFF, r13;; 
	ld8 r2 = [r2] 
	mov r9 = ar.pfs;; 
	mov r15 = SYSCALL_NR 
	mov b7 = r2
	br.call.sptk.many b6 = b7;; 
	cmp.eq p6,p0 = -1, r10 
	mov ar.pfs = r9 
(p6)	br.cond.spnt.few syscall_error 
	br.ret.sptk.many rp;;

David> Here, SYSINFO_OFF is the offset in the user-level thread-control-block
David> at which the system call entry point is stored.  glibc initializes
David> this value to point to the following piece of code:


The ABI only allows 16 bytes for the TCB pointed to by R13; 
the first 8 bytes are a pointer to the dynamic thread vector, the
second 8 bytes a pointer to the per-thread thread-library-private data
(for linuxthreads, it points to a _pthread_descr)

So is the idea to extend the TCB (in contravention of the current
ABI), or should this code have an extra level of indirection, to get at the
sysinfo field from the library-specific structure?

Or am I missing something obvious?


--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

