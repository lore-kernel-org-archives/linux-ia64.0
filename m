From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 09 Aug 2005 09:51:10 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <yq0acjr8mlt.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> What about this then? I looked a bit further at treating the
>> attribute bit as a bitmask, however it doesn't really make sense as
>> we can't really use uncached memory which has the write protect bit
>> set for

Tony> Uncached + write-protect = ROM?

Possibly, I am not sure, but certainly likely.

>> instance (I see those in the EFI mem map on the SN2). Worse is that
>> I have also seen regions marked both uncached and writeback which
>> seems pretty absurd, but to avoid getting trapped by these I think
>> it's safer to stick to using '='.

Tony> The attribute field tells you which modes are
Tony> *possible*. E.g. on Tiger most blocks of memory in the EFI
Tony> memory map have attribute 0xB (WB + WC + UC) ... meaning that
Tony> the chipset will support any of these modes to use this memory.
Tony> The Itanium processor won't let you mix and match modes (unless
Tony> you go through the appropriate cache and TLB flushing ritual
Tony> when switching) ... but that is an orthogonal question to what
Tony> the chipset/platform will allow you to do.

Ok if thats the case we really have to check for equals to and not the
bit flag. We're trying to pick out spill pages that can be used for
the uncached allocator and if pages can be supported in multiple ways
we will have to pull out the full granule and convert it to uncached
if we wish to use it, which may conflict with the use the rest of the
granule is currently being used for.

Tony> So you are moving in the right direction ... you need to check
Tony> the type to see what sort of memory a block is.  Here "type" is
Tony> overloaded to report some physical properties
Tony> (e.g. EFI_CONVENTIONAL_MEMORY vs.  EFI_MEMORY_MAPPED_IO) and
Tony> also what the memory is being used for (e.g.
Tony> EFI_{LOADER|BOOT_SERVICES|RUNTIME_SERVICES}_{CODE|DATA} are
Tony> probably all regular RAM, but they are being used for various
Tony> purposes which means they may or may not be available for
Tony> re-allocation, depending on when that use is over.

EFI_CONVENTIONAL_MEMORY and EFI_MEMORY_MAPPED_IO are all part of the
same type as the EFI_LOAD_DATA enum, at least according to
include/linux/efi.h. In other words it's going to be one or the other,
not both EFI_CONVENTIONAL_MEMORY + EFI_BOOT_SERVICES_DATA for the same
block. The patch I sent you did check for the five types,
EFI_LOADER_CODE, EFI_LOADER_DATA, EFI_BOOT_SERVICES_CODE,
EFI_BOOT_SERVICES_DATA, and EFI_CONVENTIONAL_MEMORY which should be
valid for the driver if they are just UC capable and nothing else.

Tony> On my Tiger there is no memory that is marked _just_ UC, but I
Tony> have about 18MB in bits trimmed off because of holes or
Tony> incompatible attributes within the same granule ... all of this
Tony> is UC capable.

SN2 has a couple of blocks marked just UC, they are the ones I am
trying to grab.

I think the patch I sent you yesterday does exactly this.

Cheers,
Jes
