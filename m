From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 23 May 2000 23:44:17 +0000
Subject: Re: [Linux-ia64] Profiling
Message-Id: <marc-linux-ia64-105590678205105@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205104@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205104@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I'm trying to profile a large program using gcc's -pg option and gprof,
	but so far have met with little success. It seems that -pg is causing the
	compiler to generate a certain amount of crappy code...

-pg profiling is bleeding edge stuff.  It is not supported by the February
toolchain release.  Patches exist for gcc and gprof that were written by
David Mosberger.  The gcc patches have been merged into the FSF gcc sources,
but there is no usable FSF gcc yet.  I doubt that the gprof patches have been
merged in yet.  I have not yet tried to use -pg myself.

	 The -a option (for
	basic block profiling) merely causes an internal compiler error.

I'd avoid -a like the plague.  It has never been useful except for a few
CISC machines like the x86.  It is known to be broken for most RISC targets,
and it will probably never work for IA-64 without a redesign.

If you want basic block profiling, you are better off using gcov and the
-fprofile-arcs/-ftest-coverage options.  This works for all targets, if it
works at all.  I don't know if it works with the February release though.

Jim


