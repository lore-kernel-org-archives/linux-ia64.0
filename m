From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 May 2003 04:40:40 +0000
Subject: Re: [Linux-ia64] High fpu register corruption (PATCH)
Message-Id: <marc-linux-ia64-105590723706070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 22:25:37 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> OK, ignore my questions about ptrace.c and setup.c.  Questions still
  Bjorn> open:

  Bjorn> arch/ia64/kernel/signal.c:
  Bjorn> restore_sigcontext() changes look equivalent, but have
  Bjorn> gratuitous differences from 2.5 (reversed sense of test,
  Bjorn> comment)

  Bjorn> arch/ia64/kernel/traps.c:
  Bjorn> Gratuitous whitespace differences.

  Bjorn> include/asm-ia64/processor.h:
  Bjorn> ia64_is_local_fpu_owner(), ia64_set_local_fpu_owner():
  Bjorn> these look functionally equivalent in 2.4 and 2.5.
  Bjorn> Can they be made identical?

  Bjorn> include/asm-ia64/system.h:
  Bjorn> IA64_HAS_EXTRA_STATE() and switch_to() appear to be
  Bjorn> identical in 2.4 and 2.5 except for whitespace changes.
  Bjorn> Can they be made identical?

Not sure if those are intentional.  I of course would prefer if 2.5
were followed. ;-) Asit?

	--daivd

