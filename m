From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Aug 2015 16:17:45 +0000
Subject: Re: [PATCH 29/31] parisc: handle page-less SG entries
Message-Id: <CAPcyv4idztwrtr5wBQkiTSNT8L3HWf8zk9webheQAmunLD7cBw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150813143150.GA17183@lst.de>
	<CAA9_cmcNA__N_yVTKsEqLAKBuoL-hx73t6opdsmb7w-0qKXaWg@mail.gmail.com>
	<1439524760.8421.23.camel@HansenPartnership.com>
	<20150813.211155.1774898831276303437.davem@davemloft.net>
In-Reply-To: <20150813.211155.1774898831276303437.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Jej B <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, "torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm <linux-nvdimm-y27Ovi1pjclAfugRpC6u6w@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, egtvedt-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, X86 ML <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, hskinnemoen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org, realmz6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgupta-HKixBCOQz3hWk0Htik3J/w@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>

On Thu, Aug 13, 2015 at 9:11 PM, David Miller <davem@davemloft.net> wrote:
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
>> At least on some PA architectures, you have to be very careful.
>> Improperly managed, multiple aliases will cause the system to crash
>> (actually a machine check in the cache chequerboard). For the most
>> temperamental systems, we need the cache line flushed and the alias
>> mapping ejected from the TLB cache before we access the same page at an
>> inequivalent alias.
>
> Also, I want to mention that on sparc64 we manage the cache aliasing
> state in the page struct.
>
> Until a page is mapped into userspace, we just record the most recent
> cpu to store into that page with kernel side mappings.  Once the page
> ends up being mapped or the cpu doing kernel side stores changes, we
> actually perform the cache flush.
>
> Generally speaking, I think that all actual physical memory the kernel
> operates on should have a struct page backing it.  So this whole
> discussion of operating on physical memory in scatter lists without
> backing page structs feels really foreign to me.

So the only way for page-less pfns to enter the system is through the
->direct_access() method provided by a pmem device's struct
block_device_operations.  Architectures that require struct page for
cache management to must disable ->direct_access() in this case.

If an arch still wants to support pmem+DAX then it needs something
like this patchset (feedback welcome) to map pmem pfns:

https://lkml.org/lkml/2015/8/12/970

Effectively this would disable ->direct_access() on /dev/pmem0, but
permit ->direct_access() on /dev/pmem0m.
