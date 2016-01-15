From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 15 Jan 2016 21:27:14 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160115212714.GM3421@worktop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160113104516.GE25458@arm.com> <5696CF08.8080700@imgtec.com>
	<20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
	<56980C91.1010403@imgtec.com>
	<20160114212913.GF3818@linux.vnet.ibm.com>
	<20160115085554.GF3421@worktop> <20160115091348.GA27936@worktop>
	<20160115174612.GV3818@linux.vnet.ibm.com>
In-Reply-To: <20160115174612.GV3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org

On Fri, Jan 15, 2016 at 09:46:12AM -0800, Paul E. McKenney wrote:
> On Fri, Jan 15, 2016 at 10:13:48AM +0100, Peter Zijlstra wrote:

> > And the stuff we're confused about is how best to express the difference
> > and guarantees of these two forms of transitivity and how exactly they
> > interact.
> 
> Hoping my memory-barrier.txt patch helps here...

Yes, that seems a good start. But yesterday you raised the 'fun' point
of two globally ordered sequences connected by a single local link.

And I think I'm still confused on LWSYNC (in the smp_wmb case) when one
of the stores looses a conflict, and if that scenario matters. If it
does, we should inspect the same case for other barriers.
