From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 03 Jan 2016 09:12:44 +0000
Subject: Re: [PATCH v2 17/32] arm: define __smp_xxx
Message-Id: <20160103110158-mutt-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-18-git-send-email-mst@redhat.com>
	<20160102112438.GU8644@n2100.arm.linux.org.uk>
In-Reply-To: <20160102112438.GU8644@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Sat, Jan 02, 2016 at 11:24:38AM +0000, Russell King - ARM Linux wrote:
> On Thu, Dec 31, 2015 at 09:07:59PM +0200, Michael S. Tsirkin wrote:
> > This defines __smp_xxx barriers for arm,
> > for use by virtualization.
> > 
> > smp_xxx barriers are removed as they are
> > defined correctly by asm-generic/barriers.h
> > 
> > This reduces the amount of arch-specific boiler-plate code.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> In combination with patch 14, this looks like it should result in no
> change to the resulting code.
> 
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> My only concern is that it gives people an additional handle onto a
> "new" set of barriers - just because they're prefixed with __*
> unfortunately doesn't stop anyone from using it (been there with
> other arch stuff before.)
> 
> I wonder whether we should consider making the smp memory barriers
> inline functions, so these __smp_xxx() variants can be undef'd
> afterwards, thereby preventing drivers getting their hands on these
> new macros?

That'd be tricky to do cleanly since asm-generic depends on
ifndef to add generic variants where needed.

But it would be possible to add a checkpatch test for this.


> -- 
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
