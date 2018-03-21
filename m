From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:32 +0000
Subject: [PATCH 16/32] docs/vm: numa: convert to ReST format
Message-Id: <1521660168-14372-17-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/numa | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/vm/numa b/Documentation/vm/numa
index a31b85b..c81e7c5 100644
--- a/Documentation/vm/numa
+++ b/Documentation/vm/numa
@@ -1,6 +1,10 @@
+.. _numa:
+
 Started Nov 1999 by Kanoj Sarcar <kanoj@sgi.com>
 
+====== What is NUMA?
+====== 
 This question can be answered from a couple of perspectives:  the
 hardware view and the Linux software view.
-- 
2.7.4

