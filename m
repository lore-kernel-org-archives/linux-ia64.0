From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 17:01:33 +0000
Subject: [patch 0/2] remove per-cpu dtr requirement
Message-Id: <000001c6eee9$3d10ce20$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph's variable kernel page size support patch reminds me
this 10 month old patch:
http://marc.theaimsgroup.com/?l=linux-ia64&m4074826111970&w=2


I strongly believe it is stable enough for 2.6.19.  Reposted here
for mainline consideration.

----

Patch set that remove pinned DTR per-cpu TLB requirement.  Instead
we use DTC to map that translation.

With these two patches, we measured substantial performance gain
on a database benchmark, in the vicinity of 1.6%. I've also done
extensive performance measurement on two other industry standard
benchmarks (cpu, java), and have found to have small gain on those
workloads.

Detail description in the follow on patches.

- Ken
