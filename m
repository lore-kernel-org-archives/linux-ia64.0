From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 14:29:04 +0000
Subject: Re: [PATCH v3 1/5] efi: Add efi_init_ops variable
Message-Id: <20140326142904.GI24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-2-git-send-email-daniel.kiper@oracle.com>
 <20140326125623.GA24856@console-pimps.org>
 <20140326140217.GO3454@olila.local.net-space.pl>
In-Reply-To: <20140326140217.GO3454@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

On Wed, 26 Mar, at 03:02:17PM, Daniel Kiper wrote:
> On Wed, Mar 26, 2014 at 12:56:23PM +0000, Matt Fleming wrote:
> >
> > Please don't create another struct of EFI function pointers.
> >
> > After this we'll have 3 global efi structures defintions and 4 global
> > efi objects on x86,
> >
> >   - struct efi_early [in the boot stub]
> >   - struct efi ['efi_phys' before/'efi' after SetVirtualAddressMap()]
> >   - struct efi_init_ops [for the benefit of xen]
> 
> What do you suggest? Should we fill all EFI related structures
> in xen_efi_probe() (called from xen_start_kernel()) and later
> they should be parsed by generic/x86 EFI initialization code?
> I suppose that many variables will have NULL (or something relevant)
> in Xen dom0 and it will require some changes in EFI initialization code.
 
Yeah, that is what I was thinking. And if we have to make some changes
to the generic code to accomodate NULL fields, etc, I don't think it's a
big deal.

> > I have a big problem with exposing .efi_reserve_boot_services as an API.
> 
> Why? efi_reserve_boot_services() is public right now.

Sure it's public, but it isn't implemented on ia64 at all, not even as a
stub function, and it's only called inside x86 code (the fact that the
prototype is in include/linux/efi.h is a bit of a bug).

My concern is that if in we bake into our APIs it's going to be
difficult in the future to get rid of it or disable it, or at least
allow people to write code for EFI without caring about it.

Afterall, it's a workaround for buggy firmware.

-- 
Matt Fleming, Intel Open Source Technology Center
