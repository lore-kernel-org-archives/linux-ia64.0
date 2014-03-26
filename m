From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 13:46:17 +0000
Subject: Re: [PATCH v3 5/5] xen: Put EFI machinery in place
Message-Id: <20140326134617.GE24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-6-git-send-email-daniel.kiper@oracle.com>
 <20140326131214.GC24856@console-pimps.org>
 <5332E4A802000078000025B6@nat28.tlf.novell.com>
In-Reply-To: <5332E4A802000078000025B6@nat28.tlf.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, Tang Liang <liang.tang@oracle.com>, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

On Wed, 26 Mar, at 01:31:04PM, Jan Beulich wrote:
> >>> On 26.03.14 at 14:12, <matt@console-pimps.org> wrote:
> > 
> > Is there a reason that you can't just populate an efi_system_table_t
> > object, which could be used by efi_init(), so that we can save you the
> > trouble of duplicating all of this code?
> 
> Would the generic function cope with all other fields being NULL (or
> equivalent)?
 
I've no idea, but it shouldn't be difficult to make that work. And by
making it work in the generic code

> >> +/*
> >> + * Convenience functions to obtain memory types and attributes
> >> + */
> >> +static u32 efi_mem_type_xen(unsigned long phys_addr)
> >> +{
> >> +	struct xen_platform_op op;
> >> +	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
> >> +
> >> +	op.cmd = XENPF_firmware_info;
> >> +	op.u.firmware_info.type = XEN_FW_EFI_INFO;
> >> +	op.u.firmware_info.index = XEN_FW_EFI_MEM_INFO;
> >> +	info->mem.addr = phys_addr;
> >> +	info->mem.size = 0;
> >> +	return HYPERVISOR_dom0_op(&op) ? 0 : info->mem.type;
> >> +}
> > 
> > Same idea here. Unless you expect the EFI memory map to change at runtime
> > (and it's not clear to me whether that wouldn't cause other things to
> > explode) you'd be better off building a struct efi_memory_map and using
> > the existing generic functions.
> 
> As said in another reply to this series - the memory map isn't being
> (and shouldn't be) exposed to Dom0.
 
Right, so you might not necessarily expose the EFI memory map that was
constructed by the firmware, but it's worth looking at exposing *some*
boot memory map, e.g. the map of memory before the kernel took control
in DomU.

Whether the firmware or the kernel builds it doesn't really matter. My
point is that since we've already got a means of looking in the boot
memory map for EFI type and EFI attributes, let's use it.

-- 
Matt Fleming, Intel Open Source Technology Center
