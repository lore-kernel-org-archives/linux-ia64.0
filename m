From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jan 2003 18:32:42 +0000
Subject: [Linux-ia64] Re: [RFC] proposed change for syscall stub
Message-Id: <marc-linux-ia64-105590709805643@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Hull noticed that I posted the wrong code for the syscall stub:
the one I sent out fits in 5 bundles, not 4 as advertised.  The
4-bundle code looks like this:

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

The only difference here is that we dirty both b6 and b7, which allows
us to remove one stop bit and hence save one bundle.  On McKinley,
dirtying more scratch branch registers may impact branch target
address prediction accuracy, but the effect is small enough that I
decided to go for better code-density instead.

	--david

