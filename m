From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 13:31:19 +0000
Subject: Re: [PATCH v3 3/5] x86: Call efi_memblock_x86_reserve_range() on native EFI platform only
Message-Id: <20140326133119.GD24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-4-git-send-email-daniel.kiper@oracle.com>
 <20140326130009.GB24856@console-pimps.org>
 <5332E2B9020000780000255D@nat28.tlf.novell.com>
In-Reply-To: <5332E2B9020000780000255D@nat28.tlf.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

On Wed, 26 Mar, at 01:22:49PM, Jan Beulich wrote:
> >>> On 26.03.14 at 14:00, <matt@console-pimps.org> wrote:
> > 
> > This could do with a little bit more explanation. Why is it not
> > necessary to mark the EFI memory map that was passed to the kernel as
> > reserved in memblock?
> 
> Because that's in memory Dom0 doesn't even see: The EFI memory
> map is visible to the hypervisor only.

So where does boot_params.efi_info.efi_memmap point?

If nowhere (i.e. it's NULL) that's no problem because memblock_reserve()
handles zero size regions just fine.

-- 
Matt Fleming, Intel Open Source Technology Center
