From: Khalid Aziz <khalid_aziz@hp.com>
Date: Mon, 15 Aug 2005 14:33:10 +0000
Subject: RE: efi_memmapwalk re-write
Message-Id: <1124116390.29568.27.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-08-12 at 16:48 -0700, Luck, Tony wrote:
> >Here is the updated patch. It incorporates your suggestions. I have left
> >kern_memdesc as a linked list as opposed to array. Linked list is little
> >more versatile structure and the cost is minimal over an array. Unless
> >you feel strongly about using arrays instead of linked list, I would
> >prefer to leave it this way.
> 
> Khalid,
> 
> Looking good (from my 2 minute scan, I'll take a better look
> later).  One question ... why do we need "is_available_memory"
> and "is_usable_memory"?  They look to be almost the same (except
> is_usable... doesn't consider EFI_LOADER_DATA to be usable).

I am using is_usable_memory while scanning for space for kern_memdesc
structure. Since EFI_LOADER_DATA can contain boot parameters and/or
ramdisk, I don't want to allocate any space out of there.
is_available_memory calls EFI_LOADER_DATA type memory to be avialble
because that memory gets marked reserved any way.

> 
> It doesn't look like is_available_memory needs to be in meminit.h
> [in last version of this patch it was used in more than one file,
> but now the only usage in in efi.c]

You are right. It can be moved to efi.c.

> 
> I'll ponder the linked question ... if you really think the
> extra versatility is worthwhile, then I'll consider them ...
> but that will raise the issue of why aren't you using the
> standard Linux kernel list.h macros.
> 
> -Tony

--
Khalid 

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

