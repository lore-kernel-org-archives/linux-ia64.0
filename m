From: David Miller <davem@davemloft.net>
Date: Fri, 14 Aug 2015 04:11:55 +0000
Subject: Re: [PATCH 29/31] parisc: handle page-less SG entries
Message-Id: <20150813.211155.1774898831276303437.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150813143150.GA17183@lst.de>
	<CAA9_cmcNA__N_yVTKsEqLAKBuoL-hx73t6opdsmb7w-0qKXaWg@mail.gmail.com>
	<1439524760.8421.23.camel@HansenPartnership.com>
In-Reply-To: <1439524760.8421.23.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: James.Bottomley@HansenPartnership.com
Cc: dan.j.williams@intel.com, hch@lst.de, torvalds@linux-foundation.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-nvdimm@ml01.01.org, dhowells@redhat.com, sparclinux@vger.kernel.org, egtvedt@samfundet.no, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, dwmw2@infradead.org, hskinnemoen@gmail.com, linux-xtensa@linux-xtensa.org, grundler@parisc-linux.org, realmz6@gmail.com, alex.williamson@redhat.com, linux-metag@vger.kernel.org, axboe@kernel.dk, monstr@monstr.eu, linux-parisc@vger.kernel.org, vgupta@synopsys.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-media@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 13 Aug 2015 20:59:20 -0700

> On Thu, 2015-08-13 at 20:30 -0700, Dan Williams wrote:
>> On Thu, Aug 13, 2015 at 7:31 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > On Wed, Aug 12, 2015 at 09:01:02AM -0700, Linus Torvalds wrote:
>> >> I'm assuming that anybody who wants to use the page-less
>> >> scatter-gather lists always does so on memory that isn't actually
>> >> virtually mapped at all, or only does so on sane architectures that
>> >> are cache coherent at a physical level, but I'd like that assumption
>> >> *documented* somewhere.
>> >
>> > It's temporarily mapped by kmap-like helpers.  That code isn't in
>> > this series. The most recent version of it is here:
>> >
>> > https://git.kernel.org/cgit/linux/kernel/git/djbw/nvdimm.git/commit/?h=
=3Dpfn&id=DE8237c99fdb4352be2193f3a7610e902b9bb2f0
>> >
>> > note that it's not doing the cache flushing it would have to do yet, b=
ut
>> > it's also only enabled for x86 at the moment.
>>=20
>> For virtually tagged caches I assume we would temporarily map with
>> kmap_atomic_pfn_t(), similar to how drm_clflush_pages() implements
>> powerpc support.  However with DAX we could end up with multiple
>> virtual aliases for a page-less pfn.
>=20
> At least on some PA architectures, you have to be very careful.
> Improperly managed, multiple aliases will cause the system to crash
> (actually a machine check in the cache chequerboard). For the most
> temperamental systems, we need the cache line flushed and the alias
> mapping ejected from the TLB cache before we access the same page at an
> inequivalent alias.

Also, I want to mention that on sparc64 we manage the cache aliasing
state in the page struct.

Until a page is mapped into userspace, we just record the most recent
cpu to store into that page with kernel side mappings.  Once the page
ends up being mapped or the cpu doing kernel side stores changes, we
actually perform the cache flush.

Generally speaking, I think that all actual physical memory the kernel
operates on should have a struct page backing it.  So this whole
discussion of operating on physical memory in scatter lists without
backing page structs feels really foreign to me.
