From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 04:25:37 +0000
Subject: Re: [Linux-ia64] High fpu register corruption (PATCH)
Message-Id: <marc-linux-ia64-105590723706067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Which tree are you looking at? to-linus-2.5 or linux-ia64-2.5?  I have
> gotten quite lazy in pushing the former, since the only reason now to
> do a push there is when I want Linus to do a pull.  The latter tree is
> much more active.

The latter (linux-ia64-2.5).  But ... argh!  I've been doing "bk changes -R"
to watch for your updates, and saw none.  BUT, I just did a "bk pull"
and got a lot of them.

OK, ignore my questions about ptrace.c and setup.c.  Questions still
open:

arch/ia64/kernel/signal.c:
        restore_sigcontext() changes look equivalent, but have
        gratuitous differences from 2.5 (reversed sense of test,
        comment)

arch/ia64/kernel/traps.c:
        Gratuitous whitespace differences.

include/asm-ia64/processor.h:
        ia64_is_local_fpu_owner(), ia64_set_local_fpu_owner():
        these look functionally equivalent in 2.4 and 2.5.
        Can they be made identical?

include/asm-ia64/system.h:
        IA64_HAS_EXTRA_STATE() and switch_to() appear to be
        identical in 2.4 and 2.5 except for whitespace changes.
        Can they be made identical?

Bjorn


