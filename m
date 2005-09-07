From: Martin Hicks <mort@sgi.com>
Date: Wed, 07 Sep 2005 19:16:24 +0000
Subject: Re: efi_memmapwalk re-write (please test)
Message-Id: <20050907191624.GR13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
In-Reply-To: <200509062048.j86KmBPD004877@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, Sep 06, 2005 at 01:48:11PM -0700, Luck, Tony wrote:
> I cleaned up my find_memmap_space() to do the right thing (allocate
> from a block of memory that will be used by the kernel).  I also
> had a couple of bugs in my code to find/divide all the memory
> between WB:kernel and UC:uncached-allocator.
> 
> Tested on tiger and zx1 (N.B. it didn't find any trimmed off scraps
> of memory that could be used as uncached on zx1).

So its really close on sn2.  I'm not sure exactly what's going wrong,
but with the new efi_memmap_walk stuff something is getting clobbered, I
think.

The efivars.c driver is looping through all the efi vars more than once,
causing efivar_create_sysfs_entry() to croak on the kobject_add() and
return -EEXIST during the first attempt to register a duplicate
variable.

This happens on an sn2 kernel without the Cross partition stuff compiled
(eliminating the uncached allocator from being the culprit).

I stuck KDB into the kernel and it doesn't crash anymore so I'm not sure
what the problem is :-/

> *) still passes region 6 addresses in efi_memmap_walk_uc() case, but
> could easily revert to physical addresses.  Comments?  Jes?  Martin?
> 

I think we can work with this either way.

Attached is a very small patch to find the uncached memory on SN2.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
