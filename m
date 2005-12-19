From: Andi Kleen <ak@muc.de>
Date: Mon, 19 Dec 2005 08:17:14 +0000
Subject: [ANNOUNCE] numactl-0.8 - user space NUMA policy interface released
Message-Id: <20051219081714.GA33604@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: lse-tech@projects.sourceforge.net


Sorry for the huge cc list. I will try to create a more focussed
list for numa policy user space in the future.

numactl-0.8 has been released. It consists of libnuma - which
is the prefered NUMA API to the NUMA policy system calls in the
Linux kernel -, numactl - a command line program for to 
run programs with a specific NUMA policy and various tools.

The biggest new features compared to 0.6 (0.7 was skipped) are lots
of bug fixes, PPC support and support for parsing numa distances
from sysfs.

It is backwards binary compatible to earlier libnuma releases. 

This version has everything I wanted to implement for numactl 1.0.
Unless some bad bugs come up it will be eventually renamed to
numactl-1.0

Please report all problems to ak@suse.de

ftp://ftp.suse.com/pub/people/ak/numa/numactl-0.8.tar.gz
36fb1f81d647d66cf9c119db3c215be4  numactl-0.8.tar.gz

Changes since 0.6.5: 

0.7-pre1

- add test/regress2 and some fixes to test programs
- Fix DSO relocation patch for global variables
- Change nodeset sizes back to be binary compatible with SLES9
- Cosmetic changes to manpages (pointed out by Eric S. Raymond) 
- Make numa_run_on_node etc. act on current thread only even on NPTL systems
  (Dinakar Guniguntala)
- Make numa_no_nodes / numa_all_nodes const (Werner Almesberger) 
- Fix up the warnings caused by above change
- Add numa_distance() on systems with ACPI
- remove some obsolete code
- add rdtsc for ppc64
- fix unsigned/unsigned long confusion in cpumasks (Matt Dobson)
- fix CPU_BYTES and rename CPU_WORDS to CPU_LONGS (Matt Dobson) 
- Print node distances in numactl

0.8
- hardend numactl command line parsing against bad arguments in some cases
- remove cpumask/nodemask confusion which has become a FAQ:
  --cpubind deprecated, added --cpunodebind and --physcpubind= options
  print both in --show, old cpumask kept for compatibility
- Fix --show problems
- various fixes for bugs noted by Mike Stroyan (thanks!)
- install set_mempolicy manpage
- various smaller fixes

-Andi Kleen
