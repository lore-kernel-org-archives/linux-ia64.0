From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 12 Jul 2003 08:58:45 +0000
Subject: ia64 patch for 2.5.75
Message-Id: <marc-linux-ia64-105800033710325@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

	linux-2.5.75-ia64-030712.diff.gz

It's a "whopping" 10KB in size, so clearly things are heading in the
right direction.

The patch mostly fixes the ACPI irq breakage in the main tree (some
bits haven't made it yet, apparently) and some per-CPU related fixes
(those are just temporary workarounds; Rusty is working on the proper
fix).

There is one mildly interesting change: I moved per-CPU data area from
region 5 to the end of region 7.  This allows us to address this area
via a simple "addl" (instead of movl or a GOT access).  At the moment,
this hardly makes a difference because the compiler can't take
advantage of it.  I have a prototype of a GCC patch which would change
that though.  Once GCC can take advantage of this feature, addressing
CPU-local variables will become even cheaper.

This patch hasn't received a huge amount of testing, but it does seem
to work quite well for me on a 4-way Itanium 2 machine (rx5670) and
the Ski simulator.

Enjoy,

	--david
