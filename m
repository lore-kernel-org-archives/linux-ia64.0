From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 22 Aug 2000 01:48:51 +0000
Subject: Re: [Linux-ia64] parport for ia64
Message-Id: <marc-linux-ia64-105590678205371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205356@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	parport_pc.c:2719: Internal compiler error in
	`add_abstract_origin_attribute', at dwarf2out.c:7532

This testcase works OK with the current compiler development sources.

This was fixed by a gcc/dwarf2out.c patch on 2000-04-25.  However, I know
that patch only works if a few other following patches are also used, and
I don't know what the complete set of necessary patches is, so this doesn't
seem worthwhile to try to fix in the February compiler.

I'd suggest using a workaround until a newer compiler is ready.  Compiling
without -g will make the problem go away.  Also, getting rid of the inline
version of the parport_pc_read_status function will solve the problem.

Jim

