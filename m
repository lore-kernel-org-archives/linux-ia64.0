From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 18 Nov 2003 21:54:41 +0000
Subject: serious multithreaded core-dumping problems
Message-Id: <marc-linux-ia64-106919259317135@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on a new-syscall-stub-enabled libc, I noticed serious
stability problems with 2.6.0-test9 when dumping core from a
multi-threaded app.  I thought this code had been well-tested on ia64
and multi-threaded apps, but I'm wondering now whether the code relied
on implicit synchronization guarantees from LinuxThreads which don't
hold for NPTL (and indeed, the code in binfmt_elf32 looks rather racy
to me).  Does someone have the bandwidth to investigate this?  I'm
willing to do it, but my plate is pretty full and I'm worried we may
miss the 2.6.0 (final) if I have to look into it.

	--david
