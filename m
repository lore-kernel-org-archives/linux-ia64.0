From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 15 Jan 2003 01:14:10 +0000
Subject: Re: [Linux-ia64] Re: [RFC] proposed change for syscall stub
Message-Id: <marc-linux-ia64-105590709805676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805643@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805643@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Peter Chubb wrote:
>>>>>>"David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
> 
> 
> 
> really_new_syscall_stub: 
> 	adds r2 = SYSINFO_OFF, r13;; 
> 	ld8 r2 = [r2] 
> 	mov r9 = ar.pfs;; 
> 	mov r15 = SYSCALL_NR 
> 	mov b7 = r2
> 	br.call.sptk.many b6 = b7;; 
> 	cmp.eq p6,p0 = -1, r10 
> 	mov ar.pfs = r9 
> (p6)	br.cond.spnt.few syscall_error 
> 	br.ret.sptk.many rp;;
> 
> David> Here, SYSINFO_OFF is the offset in the user-level thread-control-block
> David> at which the system call entry point is stored.  glibc initializes
> David> this value to point to the following piece of code:
> 
> 
> The ABI only allows 16 bytes for the TCB pointed to by R13; 
> the first 8 bytes are a pointer to the dynamic thread vector, the
> second 8 bytes a pointer to the per-thread thread-library-private data
> (for linuxthreads, it points to a _pthread_descr)

I haven't yet decided how I'll handle this for IA-64 but I think the
thread descriptor should be placed before what the IA-64 ABI
unfortunately calls TCB.  I.e., SYSINFO_OFF will be a negative value.

- -- 
- --------------.                        ,-.            444 Castro Street
Ulrich Drepper \    ,-----------------'   \ Mountain View, CA 94041 USA
Red Hat         `--' drepper at redhat.com `---------------------------
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+JLXi2ijCOnn/RHQRAgHLAJ9l2WqOeUqjK4uqVvR7Cp0SO58a6QCghwB/
mR6zJ3mrvjlB7GycnU3cqNUhG8
-----END PGP SIGNATURE-----


