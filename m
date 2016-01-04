From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 04 Jan 2016 13:59:34 +0000
Subject: Re: [PATCH v2 17/32] arm: define __smp_xxx
Message-Id: <20160104135934.GE19062@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-18-git-send-email-mst@redhat.com>
 <20160102112438.GU8644@n2100.arm.linux.org.uk>
 <20160103110158-mutt-send-email-mst@redhat.com>
 <20160104133658.GY6344@twins.programming.kicks-ass.net>
 <20160104135420.GS6373@twins.programming.kicks-ass.net>
In-Reply-To: <20160104135420.GS6373@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Tony Lindgren <tony@atomide.com>, Andre

On Mon, Jan 04, 2016 at 02:54:20PM +0100, Peter Zijlstra wrote:
> On Mon, Jan 04, 2016 at 02:36:58PM +0100, Peter Zijlstra wrote:
> > On Sun, Jan 03, 2016 at 11:12:44AM +0200, Michael S. Tsirkin wrote:
> > > On Sat, Jan 02, 2016 at 11:24:38AM +0000, Russell King - ARM Linux wrote:
> > 
> > > > My only concern is that it gives people an additional handle onto a
> > > > "new" set of barriers - just because they're prefixed with __*
> > > > unfortunately doesn't stop anyone from using it (been there with
> > > > other arch stuff before.)
> > > > 
> > > > I wonder whether we should consider making the smp memory barriers
> > > > inline functions, so these __smp_xxx() variants can be undef'd
> > > > afterwards, thereby preventing drivers getting their hands on these
> > > > new macros?
> > > 
> > > That'd be tricky to do cleanly since asm-generic depends on
> > > ifndef to add generic variants where needed.
> > > 
> > > But it would be possible to add a checkpatch test for this.
> > 
> > Wasn't the whole purpose of these things for 'drivers' (namely
> > virtio/xen hypervisor interaction) to use these?
> 
> Ah, I see, you add virt_*mb() stuff later on for that use case.
> 
> So, assuming everybody does include asm-generic/barrier.h, you could
> simply #undef the __smp version at the end of that, once we've generated
> all the regular primitives from it, no?

Not so simple - that's why I mentioned using inline functions.

The new smp_* _macros_ are:

+#define smp_mb()       __smp_mb()

which means if we simply #undef __smp_mb(), smp_mb() then points at
something which is no longer available, and we'll end up with errors
saying that __smp_mb() doesn't exist.

My suggestion was to change:

#ifndef smp_mb
#define smp_mb()	__smp_mb()
#endif

to:

#ifndef smp_mb
static inline void smp_mb(void)
{
	__smp_mb();
}
#endif

which then means __smp_mb() and friends can be #undef'd afterwards.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
