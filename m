From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:44 +0000
Subject: [PATCH 28/32] docs/vm: z3fold.txt: convert to ReST format
Message-Id: <1521660168-14372-29-git-send-email-rppt@linux.vnet.ibm.com>
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
 Documentation/vm/z3fold.txt | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/z3fold.txt b/Documentation/vm/z3fold.txt
index 38e4dac..224e3c6 100644
--- a/Documentation/vm/z3fold.txt
+++ b/Documentation/vm/z3fold.txt
@@ -1,5 +1,8 @@
+.. _z3fold:
+
+===
 z3fold
-------
+===
 
 z3fold is a special purpose allocator for storing compressed pages.
 It is designed to store up to three compressed pages per physical page.
@@ -7,6 +10,7 @@ It is a zbud derivative which allows for higher compression
 ratio keeping the simplicity and determinism of its predecessor.
 
 The main differences between z3fold and zbud are:
+
 * unlike zbud, z3fold allows for up to PAGE_SIZE allocations
 * z3fold can hold up to 3 compressed pages in its page
 * z3fold doesn't export any API itself and is thus intended to be used
-- 
2.7.4

