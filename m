From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 05 Jan 2016 14:38:54 +0000
Subject: Re: [PATCH v2 17/32] arm: define __smp_xxx
Message-Id: <20160105163429-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-18-git-send-email-mst@redhat.com>
	<20160102112438.GU8644@n2100.arm.linux.org.uk>
	<20160103110158-mutt-send-email-mst@redhat.com>
	<20160104133658.GY6344@twins.programming.kicks-ass.net>
	<20160104135420.GS6373@twins.programming.kicks-ass.net>
	<20160104135934.GE19062@n2100.arm.linux.org.uk>
In-Reply-To: <20160104135934.GE19062@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Jan 04, 2016 at 01:59:34PM +0000, Russell King - ARM Linux wrote:
> On Mon, Jan 04, 2016 at 02:54:20PM +0100, Peter Zijlstra wrote:
> > On Mon, Jan 04, 2016 at 02:36:58PM +0100, Peter Zijlstra wrote:
> > > On Sun, Jan 03, 2016 at 11:12:44AM +0200, Michael S. Tsirkin wrote:
> > > > On Sat, Jan 02, 2016 at 11:24:38AM +0000, Russell King - ARM Linux wrote:
> > > 
> > > > > My only concern is that it gives people an additional handle onto a
> > > > > "new" set of barriers - just because they're prefixed with __*
> > > > > unfortunately doesn't stop anyone from using it (been there with
> > > > > other arch stuff before.)
> > > > > 
> > > > > I wonder whether we should consider making the smp memory barriers
> > > > > inline functions, so these __smp_xxx() variants can be undef'd
> > > > > afterwards, thereby preventing drivers getting their hands on these
> > > > > new macros?
> > > > 
> > > > That'd be tricky to do cleanly since asm-generic depends on
> > > > ifndef to add generic variants where needed.
> > > > 
> > > > But it would be possible to add a checkpatch test for this.
> > > 
> > > Wasn't the whole purpose of these things for 'drivers' (namely
> > > virtio/xen hypervisor interaction) to use these?
> > 
> > Ah, I see, you add virt_*mb() stuff later on for that use case.
> > 
> > So, assuming everybody does include asm-generic/barrier.h, you could
> > simply #undef the __smp version at the end of that, once we've generated
> > all the regular primitives from it, no?
> 
> Not so simple - that's why I mentioned using inline functions.
> 
> The new smp_* _macros_ are:
> 
> +#define smp_mb()       __smp_mb()
> 
> which means if we simply #undef __smp_mb(), smp_mb() then points at
> something which is no longer available, and we'll end up with errors
> saying that __smp_mb() doesn't exist.
> 
> My suggestion was to change:
> 
> #ifndef smp_mb
> #define smp_mb()	__smp_mb()
> #endif
> 
> to:
> 
> #ifndef smp_mb
> static inline void smp_mb(void)
> {
> 	__smp_mb();
> }
> #endif
> 
> which then means __smp_mb() and friends can be #undef'd afterwards.

Absolutely, I got it.
The issue is that e.g. tile has:
#define __smp_mb__after_atomic()        do { } while (0)

and this is cheaper than barrier().

For this reason I left
#define smp_mb__after_atomic()  __smp_mb__after_atomic()
in place there.

Now, of course I can do (in asm-generic):

#ifndef smp_mb__after_atomic
static inline void smp_mb__after_atomic(void)
{
...
}
#endif

but this seems ugly: architectures do defines, generic
version does inline.


And that is not all: APIs like smp_store_mb can take
a variety of types as arguments so they pretty much
must be implemented as macros.

Teaching checkpatch.pl to complain about it seems like the cleanest
approach.

> -- 
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
