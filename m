From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jan 2016 08:35:46 +0000
Subject: [PATCH] documentation: Add disclaimer
Message-Id: <20160127083546.GJ6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <5696BA6E.4070508@imgtec.com> <20160114120445.GB15828@arm.com>
 <56980145.5030901@imgtec.com>
 <20160114204827.GE3818@linux.vnet.ibm.com>
 <56981212.7050301@imgtec.com>
 <20160114222046.GH3818@linux.vnet.ibm.com>
 <20160126102402.GE6357@twins.programming.kicks-ass.net>
 <20160126103200.GI6375@twins.programming.kicks-ass.net>
 <20160126110053.GA21553@arm.com>
 <20160126201143.GV4503@linux.vnet.ibm.com>
In-Reply-To: <20160126201143.GV4503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orgl

On Tue, Jan 26, 2016 at 12:11:43PM -0800, Paul E. McKenney wrote:
> So Peter, would you like to update your patch to include yourself
> and Will as authors?

Sure, here goes.

---
Subject: documentation: Add disclaimer

It appears people are reading this document as a requirements list for
building hardware. This is not the intent of this document. Nor is it
particularly suited for this purpose.

The primary purpose of this document is our collective attempt to define
a set of primitives that (hopefully) allow us to write correct code on
the myriad of SMP platforms Linux supports.

Its a definite work in progress as our understanding of these platforms,
and memory ordering in general, progresses.

Nor does being mentioned in this document mean we think its a
particularly good idea; the data dependency barrier required by Alpha
being a prime example. Yes we have it, no you're insane to require it
when building new hardware.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 Documentation/memory-barriers.txt | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index a61be39c7b51..98626125f484 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -4,8 +4,24 @@
 
 By: David Howells <dhowells@redhat.com>
     Paul E. McKenney <paulmck@linux.vnet.ibm.com>
+    Will Deacon <will.deacon@arm.com>
+    Peter Zijlstra <peterz@infradead.org>
 
-Contents:
+=====
+DISCLAIMER
+=====
+
+This document is not a specification; it is intentionally (for the sake of
+brevity) and unintentionally (due to being human) incomplete. This document is
+meant as a guide to using the various memory barriers provided by Linux, but
+in case of any doubt (and there are many) please ask.
+
+I repeat, this document is not a specification of what Linux expects from
+hardware.
+
+====
+CONTENTS
+====
 
  (*) Abstract memory access model.
 
