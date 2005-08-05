From: Khalid Aziz <khalid_aziz@hp.com>
Date: Fri, 05 Aug 2005 22:46:23 +0000
Subject: Re: efi_memmapwalk re-write
Message-Id: <1123281983.23905.50.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-08-03 at 15:45 -0700, Luck, Tony wrote:
> >one on x86. This patch is relative to 2.6.13-rc3 and applies on top of 
> >the EFI memory map walk rewrite patch at 
> ><http://free.linux.hp.com/~khalid/ia64/efi_memmapwalk_2.6.13rc3.patch>
> >(Tony, this EFI memory map walk patch is same as the one I sent you this
> >morning).
> 
> Khalid,
> 
> Thanks for working on this.  I'm sorry it has taken this long to look
> at it.
> 
> I think some areas can still benefit from more simplification.  The only
> place I see you split a kern_memdesc_t is in efi_trim_memory() in order
> to limit memory according to either of mem_limit or max_addr.  Wouldn't
> it be simpler to just adjust num_pages element of the element instead
> of splitting?
> 
> If you do that ... then you don't need to have a linked list of kern_memdesc
> structures, you can treat them just like an array, nor do you need
> MEM_DESC_SAFETY_MARGIN

Tony,

I was a little reluctant to throw away information about physical memory
that was on the system when I wrote this code originally. That
information could be useful for instance if we choose to implement to
allow adding that memory back to the system without having to reboot the
system, using hotplug memory infrastructure. Cost of retaining this
information looked reasonable enough to me.

> 
> Likewise the granule alignment functions.  The original trim_top() and
> trim_bottom() are insanely complex ... and perhaps you were led astray
> trying to duplicate their behaivour?  I believe that you should end up
> with the desired behaivour if you just do any coalescing of memory blocks
> that are WB and have one of the allowable types, then round the base
> addresses up to granule boundaries and the tops down.  All that scanning
> around looking for holes or non-WB sections of memory looks pointless to
> me ... perhaps I'm missing some incredible subtlety in the original?

I was mostly afraid to touch that code:) That code has been debugged
over years and I did not want to drop those fixes by rewriting it. I
will take another look at it.

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

