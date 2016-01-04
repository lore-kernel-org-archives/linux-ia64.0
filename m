From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 04 Jan 2016 13:54:20 +0000
Subject: Re: [PATCH v2 17/32] arm: define __smp_xxx
Message-Id: <20160104135420.GS6373@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-18-git-send-email-mst@redhat.com>
	<20160102112438.GU8644@n2100.arm.linux.org.uk>
	<20160103110158-mutt-send-email-mst@redhat.com>
	<20160104133658.GY6344@twins.programming.kicks-ass.net>
In-Reply-To: <20160104133658.GY6344@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Tony Lindgren <tony@atomide.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.

On Mon, Jan 04, 2016 at 02:36:58PM +0100, Peter Zijlstra wrote:
> On Sun, Jan 03, 2016 at 11:12:44AM +0200, Michael S. Tsirkin wrote:
> > On Sat, Jan 02, 2016 at 11:24:38AM +0000, Russell King - ARM Linux wrote:
> 
> > > My only concern is that it gives people an additional handle onto a
> > > "new" set of barriers - just because they're prefixed with __*
> > > unfortunately doesn't stop anyone from using it (been there with
> > > other arch stuff before.)
> > > 
> > > I wonder whether we should consider making the smp memory barriers
> > > inline functions, so these __smp_xxx() variants can be undef'd
> > > afterwards, thereby preventing drivers getting their hands on these
> > > new macros?
> > 
> > That'd be tricky to do cleanly since asm-generic depends on
> > ifndef to add generic variants where needed.
> > 
> > But it would be possible to add a checkpatch test for this.
> 
> Wasn't the whole purpose of these things for 'drivers' (namely
> virtio/xen hypervisor interaction) to use these?

Ah, I see, you add virt_*mb() stuff later on for that use case.

So, assuming everybody does include asm-generic/barrier.h, you could
simply #undef the __smp version at the end of that, once we've generated
all the regular primitives from it, no?
