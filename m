From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 04 Jan 2016 15:30:36 +0000
Subject: Re: [PATCH v2 20/32] metag: define __smp_xxx
Message-Id: <20160104153036.GG6344@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-21-git-send-email-mst@redhat.com>
	<20160104134128.GZ6344@twins.programming.kicks-ass.net>
	<20160104152558.GD17861@jhogan-linux.le.imgtec.org>
In-Reply-To: <20160104152558.GD17861@jhogan-linux.le.imgtec.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Hogan <james.hogan@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dbueso@suse.de>, linux-sh@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Jan 04, 2016 at 03:25:58PM +0000, James Hogan wrote:
> It is used along with the metag specific __global_lock1() (global
> voluntary lock between hw threads) whenever a write is performed, and by
> smp_mb/smp_rmb to try to catch other cases, but I've never been
> confident this fixes every single corner case, since there could be
> other places where multiple CPUs perform unsynchronised writes to the
> same memory location, and expect cache not to become incoherent at that
> location.

Ah, yuck, I thought blackfin was the only one attempting !coherent SMP.
And yes, this is bound to break in lots of places in subtle ways. We
very much assume cache coherency for SMP in generic code.

> It seemed to be sufficient to achieve stability however, and SMP on Meta
> Linux never made it into a product anyway, since the other hw thread
> tended to be used for RTOS stuff, so it didn't seem worth extending the
> generic barrier API for it.

*phew*, should we take it out then, just to be sure nobody accidentally
tries to use it then?
