From: Robin Holt <holt@sgi.com>
Date: Sun, 24 Aug 2008 12:52:02 +0000
Subject: [Patch] Export cpu_core_map.
Message-Id: <20080824125202.GC9501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This is actually a build fix for 2.6.27.  If you select SFC=m, you get
a missing symbol build failure due to cpu_core_map not being exported.
The function actually being used is topology_core_siblings.

Signed-off-by: Robin Holt <holt@sgi.com>

---

Tony,

I realize there was discussion about topology_core_siblings being the
wrong thing for the SFC driver to use.  I think this change is justified
despite that discussion.  This also gets an allmodconfig to build again
for ia64.  This patch merely brings parity between x86 and ia64.

Thanks,
Robin
