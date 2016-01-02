From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 02 Jan 2016 11:20:12 +0000
Subject: Re: [PATCH v2 08/32] arm: reuse asm-generic/barrier.h
Message-Id: <20160102112011.GT8644@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-9-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-9-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Dec 31, 2015 at 09:06:46PM +0200, Michael S. Tsirkin wrote:
> On arm smp_store_mb, read_barrier_depends, smp_read_barrier_depends,
> smp_store_release, smp_load_acquire, smp_mb__before_atomic and
> smp_mb__after_atomic match the asm-generic variants exactly. Drop the
> local definitions and pull in asm-generic/barrier.h instead.
> 
> This is in preparation to refactoring this code area.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks, the asm-generic versions looks identical to me, so this should
result in no code generation difference.

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
