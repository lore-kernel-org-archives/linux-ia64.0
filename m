From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Sep 2004 19:09:54 +0000
Subject: RE: BUG: 2.6.8/2.6.9  register corruption with PTRACE_SYSCALL
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02005A70@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040913122656.GC30808@frankl.hpl.hp.com>
In-Reply-To: <20040913122656.GC30808@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Thanks for tracking this down.  If I'm affected, should I 
>expect something like ls to SEGV when run under strace?
>If so, I'm not seeing this problem with the Debian kernels.
>They are built w/ gcc 3.3.4 and have CONFIG_AUDIT disabled.
>I'm running Debian/sid which uses libc6.1 2.3.2.ds1-16.

The test program that Stephane showed to me just did:

	int pv[2];

	pipe(pv);

	printf("%d %d\n", pv[0], pv[1]);

This coredumps when run under strace on 2.6.8 or later kernel.

The fix is to add -fno-optimize-sibling-calls to cflags-y
in arch/ia64/Makefile.  I just put it into my tree.

-Tony
