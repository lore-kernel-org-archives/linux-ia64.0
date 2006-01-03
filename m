From: Andi Kleen <ak@suse.de>
Date: Tue, 03 Jan 2006 21:57:52 +0000
Subject: [ANNOUNCE] numactl 0.9 released
Message-Id: <200601032257.53039.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


A new release of the numactl / libnuma package has been released

ftp://ftp.suse.com/pub/people/ak/numa/numactl-0.9.tar.gz
af9f10f1f65a88b3368c02157718aa58  numactl-0.9.tar.gz

It consists of a numactl program to run other programs with a specific 
NUMA policy and a libnuma shared library ("NUMA API") to set NUMA policy in 
applications and some additional tools.

The 0.8 release had some problems (in fact it didn't even build on !x86-64
without tweaks) so I did 0.9 early. I fixed all the known bugs, added
some patches that were reported after releases and added some minor new features.

The compile flags can be now changed with the standard CFLAGS=..
argument, no need anymore for OPT_CFLAGS (thanks Ian!)

I tweaked numademo a bit and it should be more useful now. It has more
stable measurements now and reports the the results in MB/s instead
of the weird units used before. There is a new random test that tests the 
memory performance with randomized accesses to defeat any hardware prefetching.

And ppc64 support should really work now (I hope at least) 

And numastat now knows how to wrap the display for a large number
of nodes (a killer feature!)

I hope to declare this numactl 1.0 soon unless any bad bugs are reported.

Any feedback appreciated.

-Andi

Detailed changes since 0.8:
- Get rid of bogus distance.o that broke compilation on !x86-64 (sorry)
- Handle CFLAGS overriding without OPT_CFLAGS (Ian Wienand)
- Fix up section of get/set_mempolicy (Ian Wienand)
- When no NUMA available fall back to one global node instead of one node
per CPU (Samuel Thibault)
- Don't rely on architecture symbols for dependency generation
- Use __powerpc__ to detect PPC/PPC64
- numastat: 
  * wrap display properly with many nodes
  * display nodes in forward order
  * install manpage in `make install'.
- remove bogus numamemcpy.c
- numademo: 
  * allow standalone compile, make streamlib optional
  * clean up output
  * change output unit to standard MB/s
  * compile with more optimization
  * add random pass to fool any prefetching (slow)
- make numademo compileable outside source tree
- use gettimeofday instead of time stamp counters in benchmarks
- support valgrind in testsuite
- other minor changes
