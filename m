From: Khalid Aziz <khalid_aziz@hp.com>
Date: Mon, 22 Nov 2004 19:10:11 +0000
Subject: Re: [PATCH] Fix for kexec reboot failing after multiple continued
Message-Id: <1101150611.19827.24.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100633878.21234.15.camel@lyra.fc.hp.com>
In-Reply-To: <1100633878.21234.15.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse,

EFI mem map gets trimmed by efi_memmap_walk(). What you are seeing might
be the effect of trimming as opposed to corruption. Once we have code in
place to save unmodified EFI memory map, kexec might work better for
you.

--
Khalid

On Wed, 2004-11-17 at 17:08, Jesse Barnes wrote:
> On Wednesday, November 17, 2004 3:44 pm, Jesse Barnes wrote:
> > It's dying in find_pernode_space.  The efi memmap, though trimmed, should
> > be ok at this point, so I'm still trying to figure out what's going on in
> > that routine.
> 
> Actually, it looks like the EFI memmap isn't the same between a regular boot
>  and a kexec boot even though I'm not messing with it via mem= or anything.
> I check it in find_pernode_space and though the start is the same, the
> length isn't.  In the kexec kernel, the length that's passed in is much bigger
> in fact.
> 
> Regular boot:
> find_pernode_space(0000003003000000, 0000000011000000, 0): pernodesize = 33783808
> found space at 0000003003000000
> 
> kexec boot:
> find_pernode_space(0000003003000000, 0000000079000000, 0): pernodesize = 163840
> found space at 0000003003000000
> 
> (the kexec kernel was configured for 2p, while the regular one was 512p, which
> explains the difference in pernodesize requirements).  I think the kexec kernel
> is corrupting all sorts of important memory since it thinks it's got pages that
> it shouldn't be touching.
> 
> Thanks,
> Jesse
-- 

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini


