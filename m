From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 11 Oct 2004 15:52:44 +0000
Subject: q-tools v0.2 released
Message-Id: <200410111552.i9BFqiHj020907@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm happy to announce that q-tools v0.2 has been released.  q-tools is
a collection of Linux performance analysis tools.  In particular, they
include q-syscollect and q-view, which can be thought of as being more
powerful than gprof, without its pain (no recompilation needed;
multi-threaded apps and shared libraries are supported;
kernel-execution can be profiled; any Itanium 2 PMU event can be
profiled, etc.).

As usual, you can get q-tools via the web page at:

	http://www.hpl.hp.com/research/linux/q-tools/

It may take a couple of hours before the web pages migrate across the
firewall but in the meantime you may also get the q-tools-0.2 tar-ball
directly from the ftp site:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/

There are two major enhancements in this release:

 - SuSE Enterprise Linux 9 (SLES9) is now supported out-of-the-box
   (in addition to the existing Debian support)

 - q-syscollect now has the ability to profile the time spent in
   code which has interrupts disabled (see section
   "Blind-spot-free profiling" in the README for details).

In addition, there are many bug-fixes, in particular some nasty bugs
in q-syscollect got fixed which reared their ugly face primarily on
large SMP machines.

For additional details, I attached the relevant section from the NEWS
file.

Enjoy,

	--david

----
* News for v0.2:

** New features

*** q-syscollect: Add support for interruption-level code-sampling (-i option).
*** q-tools now builds and works out-of-the-box for SuSE (SLES 9).

** Bug fixes

*** q-syscollect: Make it robust against small RLIMIT_MEMLOCK values.
*** q-syscollect: Fix bug which could cause killing of "random" processes.
*** q-syscollect: Fix bug which could cause live-lock when the
                  sampling-buffer filled up.
*** q-syscollect: Fix a memory leak.
*** q-syscollect: Fix handling of backslashes in argument vectors.
*** q-view: Ignore non-function symbols to avoid confusion when a function
            contains a local lable.
*** q-view: Fix topological sort of the call-graph for good.
*** q-view: Ensure weird symbols such as "operator|=" get parsed properly.
*** q-view: Display fully-qualified kernel symbols as SYMNAME<kernel> for
            consistency.
*** q-view: Build symbol table more carefully, e.g., suppressing duplicates
            and use unwind-info to detect procedure-boundaries in stripped
            binaries.
*** q-view: Allow for multiple kallsyms-formated symbol-files to enable,
            e.g., firmware symbol-tables.
