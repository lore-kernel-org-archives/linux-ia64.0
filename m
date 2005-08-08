From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Aug 2005 16:37:22 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04163268@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What about this then? I looked a bit further at treating the attribute
>bit as a bitmask, however it doesn't really make sense as we can't
>really use uncached memory which has the write protect bit set for

Uncached + write-protect = ROM?

>instance (I see those in the EFI mem map on the SN2). Worse is that I
>have also seen regions marked both uncached and writeback which seems
>pretty absurd, but to avoid getting trapped by these I think it's
>safer to stick to using '='.

The attribute field tells you which modes are *possible*. E.g. on Tiger
most blocks of memory in the EFI memory map have attribute 0xB
(WB + WC + UC) ... meaning that the chipset will support any of these
modes to use this memory.  The Itanium processor won't let you mix
and match modes (unless you go through the appropriate cache and TLB
flushing ritual when switching) ... but that is an orthogonal question
to what the chipset/platform will allow you to do.

So you are moving in the right direction ... you need to check the type
to see what sort of memory a block is.  Here "type" is overloaded
to report some physical properties (e.g. EFI_CONVENTIONAL_MEMORY vs.
EFI_MEMORY_MAPPED_IO) and also what the memory is being used for (e.g.
EFI_{LOADER|BOOT_SERVICES|RUNTIME_SERVICES}_{CODE|DATA} are probably
all regular RAM, but they are being used for various purposes which
means they may or may not be available for re-allocation, depending
on when that use is over.

On my Tiger there is no memory that is marked _just_ UC, but I have about
18MB in bits trimmed off because of holes or incompatible attributes
within the same granule ... all of this is UC capable.

-Tony
