From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 15 Jul 2005 19:16:03 +0000
Subject: [announce] linux kernel performance project launch at sourceforge.net
Message-Id: <200507151916.j6FJG3g16619@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Forward for people who might missed the "linux kernel performance"
announcement on LKML yesterday. It has performance data for ia64,
in case if you are interested, you are welcome to browse the data
and join the discussion on kernel performance.

		Ken Chen <kenneth.w.chen@intel.com>
		Intel Open Source Technology Center



-----Original Message-----
From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com] 
Sent: Thursday, July 14, 2005 1:21 PM
To: linux-kernel@vger.kernel.org
Subject: [announce] linux kernel performance project launch at sourceforge.net

I'm pleased to announce that we have established a linux kernel
performance project, hosted at sourceforge.net:

http://kernel-perf.sourceforge.net

As much as discussed various time in the past on LKML that Linux
kernel needs a systematic and disciplined way to measure and track
kernel performance on a regular basis.  To do that, we decided to
run a large set of benchmarks covering core components of the Linux
kernel (virtual memory management, I/O subsystem, process scheduler,
file system, network, device driver, etc) on a regular basis.
Benchmarks are run on a variety of platforms (4P Intel Xeon processor,
2P Xeon, several ia64 server boxes etc) every week, measuring the
latest snapshot of Linus' git development tree. Comprehensive performance
data from our tests will be published for easy access.

Our goal is to work with the Linux community to further enhance the
performance of the Linux kernel. The data available on the site allows
community members to closely track performance gains and losses with
every version of the kernel. Ultimately, we hope that this data will
result in performance increases in Linux kernel development.

The benchmark result pages are populated with a few benchmarks at the
moment.  In the coming weeks, we will be populating more benchmark data.
Happy surfing and hacking!!


		Ken Chen <kenneth.w.chen@intel.com>
		Intel Open Source Technology Center

