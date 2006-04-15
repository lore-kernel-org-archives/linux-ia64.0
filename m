From: Steven Rostedt <rostedt@goodmis.org>
Date: Sat, 15 Apr 2006 03:10:24 +0000
Subject: [PATCH 00/08] robust per_cpu allocation for modules - V2
Message-Id: <1145070624.27407.26.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain>
In-Reply-To: <1145049535.1336.128.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, paulus@samba.org, linux390@de.ibm.com, davem@davemloft.net, SamRavnborg <sam@ravnborg.org>

This is version 2 of the percpu patch set.

Changes from version 1:

- Created a PERCPU_OFFSET variable to use in vmlinux.lds.h
  (suggested by Sam Ravnborg)

- Added support for x86_64 (Steven Rostedt)

The support for x86_64 goes back to the asm-generic handling when both
CONFIG_SMP and CONFIG_MODULES are set. This is due to the fact that the
__per_cpu_offset array is no longer referenced in per_cpu, but instead a
per per_cpu variable is used to find the offset.

Again, the rest of the patches are only sent to the LKML.

Still I need help to port this to the rest of the architectures.

Thanks,

-- Steve

