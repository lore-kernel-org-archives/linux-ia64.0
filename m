From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 02:30:35 +0000
Subject: [patch 0/2] remove per-cpu dtr requirement
Message-Id: <200602240230.k1O2UZg05919@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a respin of previously posted patches that remove pinned
DTR per-cpu TLB requirement.  Instead we use DTC to map that
translation.

With these two patches, we measured substantial performance gain
on a database benchmark, in the vicinity of 1.6%. I've also done
extensive performance measurement on two other industry standard
benchmarks (cpu, java), and have found to have small gain on those
workloads.

Detail description in the follow on patches.

- Ken

