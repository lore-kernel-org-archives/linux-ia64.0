From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 08:52:37 +0000
Subject: [patch 0/6] optimize kernel rbs in kernel exit path
Message-Id: <200601310852.k0V8qkg11440@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following is a set of 6 patches to optimize kernel RBS stack
access in the kernel exit path.  Our perfmon data collection on
several enterprise workloads showed that in the kernel exit path,
accessing to kernel RBS stack has generated quite a bit of L3
cache misses, primarily coming from loading the user dirty stack
register partition. This set of patch specifically tries to prefetch
the memory corresponding to the dirty RBS section as early as
possible in the kernel exit path.

Detail explanation is given in each follow up posting.  I'm posting
these patches for wider exposure.  Comments and feedback are appre-
ciated.

- Ken

