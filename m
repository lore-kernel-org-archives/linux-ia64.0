From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Aug 2005 17:00:06 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F041A1C5F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Tony> The attribute field tells you which modes are
>Tony> *possible*.
>
>Ok if thats the case we really have to check for equals to and not the
>bit flag. We're trying to pick out spill pages that can be used for
>the uncached allocator and if pages can be supported in multiple ways
>we will have to pull out the full granule and convert it to uncached
>if we wish to use it, which may conflict with the use the rest of the
>granule is currently being used for.

The kernel is only using complete granules of WB memory.  So many of the
trimmed off pieces that the kernel ignores will be usable as UC even
if they happen to support other attributes too.

>EFI_CONVENTIONAL_MEMORY and EFI_MEMORY_MAPPED_IO are all part of the
>same type as the EFI_LOAD_DATA enum, at least according to
>include/linux/efi.h. In other words it's going to be one or the other,
>not both EFI_CONVENTIONAL_MEMORY + EFI_BOOT_SERVICES_DATA for the same
>block.

That's correct ... the "type" field isn't a bitmap, you only get to
choose one of the possible options.  My point here is that many of
these types refer to ordinary memory that happens to have been assigned
some purpose.  E.g. EFI allocates some memory for elilo.efi.  This memory
would have been EFI_CONVENTIONAL_MEMORY, but now it is being used for
a specific purpose, so it gets a different type.  Linux sees that and
knows that once it has copied out anything it may need (e.g. the
command line arguments) it can use that memory.


> The patch I sent you did check for the five types,
>EFI_LOADER_CODE, EFI_LOADER_DATA, EFI_BOOT_SERVICES_CODE,
>EFI_BOOT_SERVICES_DATA, and EFI_CONVENTIONAL_MEMORY which should be
>valid for the driver if they are just UC capable and nothing else.

While safe, this is being overly restrictive.

>SN2 has a couple of blocks marked just UC, they are the ones I am
>trying to grab.
>
>I think the patch I sent you yesterday does exactly this.

But this is trying to grow up to be a generic UC allocator
for use on systems other than SN2 ... so it needs to be
smart enough to find some memory to use on those systems
as well.

-Tony


