From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 15 Jan 2016 17:46:12 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160115174612.GV3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <569565DA.2010903@imgtec.com> <20160113104516.GE25458@arm.com>
	<5696CF08.8080700@imgtec.com> <20160114121449.GC15828@arm.com>
	<5697F6D2.60409@imgtec.com>
	<20160114203430.GC3818@linux.vnet.ibm.com>
	<56980C91.1010403@imgtec.com>
	<20160114212913.GF3818@linux.vnet.ibm.com>
	<20160115085554.GF3421@worktop> <20160115091348.GA27936@worktop>
In-Reply-To: <20160115091348.GA27936@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org

On Fri, Jan 15, 2016 at 10:13:48AM +0100, Peter Zijlstra wrote:
> On Fri, Jan 15, 2016 at 09:55:54AM +0100, Peter Zijlstra wrote:
> > On Thu, Jan 14, 2016 at 01:29:13PM -0800, Paul E. McKenney wrote:
> > > So smp_mb() provides transitivity, as do pairs of smp_store_release()
> > > and smp_read_acquire(), 
> > 
> > But they provide different grades of transitivity, which is where all
> > the confusion lays.
> > 
> > smp_mb() is strongly/globally transitive, all CPUs will agree on the order.
> > 
> > Whereas the RCpc release+acquire is weakly so, only the two cpus
> > involved in the handover will agree on the order.
> 
> And the stuff we're confused about is how best to express the difference
> and guarantees of these two forms of transitivity and how exactly they
> interact.

Hoping my memory-barrier.txt patch helps here...

> And smp_load_acquire()/smp_store_release() are RCpc because TSO archs
> and PPC. the atomic*_{acquire,release}() are RCpc because PPC and
> LOCK,UNLOCK are similarly RCpc because of PPC.
> 
> Now we'd like PPC to stick a SYNC in either LOCK or UNLOCK so at least
> the locks are RCsc again, but they resist for performance reasons but
> waver because they don't want to be the ones finding all the nasty bugs
> because they're the only one.

I believe that the relevant proverb said something about starving to
death between two bales of hay...  ;-)

> Now the thing I worry about, and still have not had an answer to is if
> weakly ordered MIPS will end up being RCsc or RCpc for their locks if
> they get implemented with SYNC_ACQUIRE and SYNC_RELEASE instead of the
> current SYNC.

It would be good to have better clarity on this, no two ways about it.

							Thanx, Paul

