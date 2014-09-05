From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 05 Sep 2014 18:09:50 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905180950.GU5001@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
 <54079B70.4050200@hurleysoftware.com>
 <1409785893.30640.118.camel@pasglop>
 <063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>
 <1409824374.4246.62.camel@pasglop>
 <5408E458.3@zytor.com>
 <54090AF4.7060406@hurleysoftware.com>
 <54091B30.2090509@zytor.com>
 <20140905081648.GB5281@omega>
In-Reply-To: <20140905081648.GB5281@omega>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Cree <mcree@orcon.net.nz>, "H. Peter Anvin" <hpa@zytor.com>, Peter Hurley <peter@hurleysoftware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On Fri, Sep 05, 2014 at 08:16:48PM +1200, Michael Cree wrote:
> On Thu, Sep 04, 2014 at 07:08:48PM -0700, H. Peter Anvin wrote:
> > On 09/04/2014 05:59 PM, Peter Hurley wrote:
> > > I have no idea how prevalent the ev56 is compared to the ev5.
> > > Still we're talking about a chip that came out in 1996.
> > 
> > Ah yes, I stand corrected.  According to Wikipedia, the affected CPUs
> > were all the 2106x CPUs (EV4, EV45, LCA4, LCA45) plus the 21164 with no
> > suffix (EV5).  However, we're still talking about museum pieces here.
> 
> Yes, that is correct, EV56 is the first Alpha CPU to have the byte-word
> extension (BWX) CPU instructions.
> 
> It would not worry me if the kernel decided to assume atomic aligned
> scalar accesses for all arches, thus terminating support for Alphas
> without BWX.
> 
> The X server, ever since the libpciaccess change, does not work on
> Alphas without BWX.
> 
> Debian Alpha (pretty much up to date at Debian-Ports) is still compiled
> for all Alphas, i.e., without BWX.  The last attempt to start compiling
> Debian Alpha with BWX, about three years ago when Alpha was kicked out
> to Debian-Ports resulted in a couple or so complaints so got nowhere.
> It's frustrating supporting the lowest common demoninator as many of
> the bugs specific to Alpha can be resolved by recompiling with the BWX.
> The kernel no longer supporting Alphas without BWX might just be the
> incentive we need to switch Debian Alpha to compiling with BWX.

Very good, then I update my patch as follows.  Thoughts?

							Thanx, Paul

------------------------------------------------------------------------

documentation: Record limitations of bitfields and small variables

This commit documents the fact that it is not safe to use bitfields as
shared variables in synchronization algorithms.  It also documents that
CPUs must provide one-byte and two-byte load and store instructions
in order to be supported by the Linux kernel.  (Michael Cree
has agreed to the resulting non-support of pre-EV56 Alpha CPUs:
https://lkml.org/lkml/2014/9/5/143.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index 87be0a8a78de..455df6b298f7 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -269,6 +269,30 @@ And there are a number of things that _must_ or _must_not_ be assumed:
 	STORE *(A + 4) = Y; STORE *A = X;
 	STORE {*A, *(A + 4) } = {X, Y};
 
+And there are anti-guarantees:
+
+ (*) These guarantees do not apply to bitfields, because compilers often
+     generate code to modify these using non-atomic read-modify-write
+     sequences.  Do not attempt to use bitfields to synchronize parallel
+     algorithms.
+
+ (*) Even in cases where bitfields are protected by locks, all fields
+     in a given bitfield must be protected by one lock.  If two fields
+     in a given bitfield are protected by different locks, the compiler's
+     non-atomic read-modify-write sequences can cause an update to one
+     field to corrupt the value of an adjacent field.
+
+ (*) These guarantees apply only to properly aligned and sized scalar
+     variables.  "Properly sized" currently means variables that are the
+     same size as "char", "short", "int" and "long".  "Properly aligned"
+     means the natural alignment, thus no constraints for "char",
+     two-byte alignment for "short", four-byte alignment for "int",
+     and either four-byte or eight-byte alignment for "long", on 32-bit
+     and 64-bit systems, respectively.  Note that this means that the
+     Linux kernel does not support pre-EV56 Alpha CPUs, because these
+     older CPUs do not provide one-byte and two-byte loads and stores.
+     Alpha EV56 and later Alpha CPUs are still supported.
+
 
 ============ WHAT ARE MEMORY BARRIERS?

