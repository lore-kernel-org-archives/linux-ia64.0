From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 24 Jul 2000 19:17:34 +0000
Subject: Re: [Linux-ia64] Bad unwind record ...
Message-Id: <marc-linux-ia64-105590678205224@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Bad unwind record format value '51' at offset 0 in record
	0x4000000000cc31ef
	Aborted (core dumped)

You probably have an inconsistent set of gcc/gas/libraries on your system.

There were a number of problems with the unwind sections created by gas
that were fixed by David Mosberger as part of his kernel unwinding work.
Some of the problems were endian related.  These changes made the new unwind
sections ABI incompatible with the old unwind sections.  David wrote only
gas changes.  Since C++ EH uses the unwind sections, this required
corresponding gcc changes that I wrote.  Also, this requires recompiling all
libraries on the system with the new compiler.

If you accidentally mix the new compiler with old libraries, or the old
compiler with new libraries, then you will see the error above.

Are you perhaps using TurboLinux?  I think TurboLinux applied the gas patches
to their toolchain on their own initiative, but they didn't add the gcc
changes, which means that kernel unwinding will work with the TurboLinux
toolchain, but C++ EH won't.

Jim


