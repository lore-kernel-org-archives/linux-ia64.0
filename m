From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 16 Aug 2000 03:22:07 +0000
Subject: Re: [Linux-ia64] gas dependency checker bug [forwarded message from Xavier Leroy]
Message-Id: <marc-linux-ia64-105590678205333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	1- "addl" vs. "adds"
	... no DV reported for addl

This is a bug in gas.  addl takes a special operand type gr0-gr3 (in gas
IA64_OPND_R3_2) and this operand type was accidentally left out of the
dv checking code.  addl is the only instruction using this operand type,
so it is the only instruction effected by this problem.  This is easy to fix.

	2- Loads and stores with postincrement.

This is another oversight.  The code checking for operands modified by an
instruction doesn't include memory operands with postincrement addressing
modes.  This one is a little harder to fix, because the opcodes files need to
be modified to indicate which instructions are postincrement, and then gas
needs to use the new info, so I ended up with a pretty big patch.

While I was at it, I also fixed a few gas testsuite failures, added new
gas testsuite cases for these two bugs, and fixed some warnings from the
ia64-gen program.  The result is a 64K patch if I delete the diffs for
gas/testsuite/gas/ia64/opc-f.d and opcodes/ia64-asmtab.c both of which are
generated files.  With those files it is a 687K patch.

I am doing a little more cleanup and testing of these patches, and I expect
to check them into the FSF binutils source tree tomorrow.

Jim

