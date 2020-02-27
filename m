From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 27 Feb 2020 18:08:09 +0000
Subject: Re: [PATCH v3 0/7] Allow setting caching mode in arch_add_memory() for P2PDMA
Message-Id: <CAPcyv4g6OYvD57LdWcqGuWVanckQv4a1uzJrE1OZyMH+z=5KZw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200227171704.GK31668@ziepe.ca>
 <e8781f85-3fc7-b9ce-c751-606803cbdc77@deltatee.com>
 <20200227174311.GL31668@ziepe.ca>
 <CAPcyv4iek=EmNk9JgXq=-HcZjd9Kz4m2+qXMhnDWMshFKFZPXQ@mail.gmail.com>
 <20200227180346.GM31668@ziepe.ca>
In-Reply-To: <20200227180346.GM31668@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390 <linux-s390@vger.kernel.org>, David Hildenbrand <david@redhat.com>, Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Eric Badger <ebadger@gigaio.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>

On Thu, Feb 27, 2020 at 10:03 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Feb 27, 2020 at 09:55:04AM -0800, Dan Williams wrote:
> > On Thu, Feb 27, 2020 at 9:43 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Thu, Feb 27, 2020 at 10:21:50AM -0700, Logan Gunthorpe wrote:
> > > >
> > > >
> > > > On 2020-02-27 10:17 a.m., Jason Gunthorpe wrote:
> > > > >> Instead of this, this series proposes a change to arch_add_memory()
> > > > >> to take the pgprot required by the mapping which allows us to
> > > > >> explicitly set pagetable entries for P2PDMA memory to WC.
> > > > >
> > > > > Is there a particular reason why WC was selected here? I thought for
> > > > > the p2pdma cases there was no kernel user that touched the memory?
> > > >
> > > > Yes, that's correct. I choose WC here because the existing users are
> > > > registering memory blocks without side effects which fit the WC
> > > > semantics well.
> > >
> > > Hm, AFAIK WC memory is not compatible with the spinlocks/mutexs/etc in
> > > Linux, so while it is true the memory has no side effects, there would
> > > be surprising concurrency risks if anything in the kernel tried to
> > > write to it.
> > >
> > > Not compatible means the locks don't contain stores to WC memory the
> > > way you would expect. AFAIK on many CPUs extra barriers are required
> > > to keep WC stores ordered, the same way ARM already has extra barriers
> > > to keep UC stores ordered with locking..
> > >
> > > The spinlocks are defined to contain UC stores though.
> >
> > How are spinlocks and mutexes getting into p2pdma ranges in the first
> > instance? Even with UC, the system has bigger problems if it's trying
> > to send bus locks targeting PCI, see the flurry of activity of trying
> > to trigger faults on split locks [1].
>
> This is not what I was trying to explain.
>
> Consider
>
>  static spinlock lock; // CPU DRAM
>  static idx = 0;
>  u64 *wc_memory = [..];
>
>  spin_lock(&lock);
>  wc_memory[0] = idx++;
>  spin_unlock(&lock);
>
> You'd expect that the PCI device will observe stores where idx is
> strictly increasing, but this is not guarenteed. idx may decrease, idx
> may skip. It just won't duplicate.
>
> Or perhaps
>
>  wc_memory[0] = foo;
>  writel(doorbell)
>
> foo is not guarenteed observable by the device before doorbell reaches
> the device.
>
> All of these are things that do not happen with UC or NC memory, and
> are surprising violations of our programming model.
>
> Generic kernel code should never touch WC memory unless the code is
> specifically designed to handle it.

Ah, yes, agree.
