From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Mar 2005 17:42:36 +0000
Subject: RE: take7: vector sharing (Large I/O system support)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03008A08@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Can I use alloc_bootmem as well as kmalloc to allocate arbitrary
> size of memory?

The decision on which to use is based on when in the boot sequence
you need to do the allocation.  Before "free_all_bootmem()" [or on
NUMA systems "free_all_bootmem_node()"] you must use alloc_bootmem(),
afterwards you must use kmalloc() [or vmalloc(), or alloc_pages()].

If the features of the allocation you need to make demand the semantics
of a particular allocator, then you will have to fix your code to
make the allocation during a period of the boot sequence when the
allocator you want to use is valid.

alloc_bootmem() is not so good at small allocations (especially of
objects that you plan to free again) ... for very large allocations
it may be the only choice (as it gets called before fragmentation
sets in).

-Tony
