From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Thu, 12 May 2016 08:22:42 +0000
Subject: Re: [PATCH 11/12] kexec: allow architectures to override boot mapping
Message-Id: <20160512082242.GQ19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviFU-0000jk-9q@rmk-PC.arm.linux.org.uk>
 <20160512062627.GB2711@x1.redhat.com>
In-Reply-To: <20160512062627.GB2711@x1.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>, Eric Biederman <ebiederm@xmission.com>
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Ian Campbell <ijc+devicetree@hellion.org.uk>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, linux-arm-kernel@lists.infradead.org

On Thu, May 12, 2016 at 02:26:27PM +0800, Baoquan He wrote:
> On 04/28/16 at 10:28am, Russell King wrote:
> > diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> > index 52a3a221bcb2..99cb9dac7909 100644
> > --- a/include/linux/kexec.h
> > +++ b/include/linux/kexec.h
> > @@ -318,6 +318,44 @@ int __weak arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr,
> >  int __weak arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
> >  					unsigned int relsec);
> >  
> > +#ifndef page_to_boot_pfn
> > +static inline unsigned long page_to_boot_pfn(struct page *page)
> > +{
> > +	return page_to_pfn(page);
> > +}
> > +#endif
> 
> I am thinking if it's appropriate to introduce a new concept which only
> exists in a certain system of a certain ARCH. Is it unavoidable? If have
> to can we name it as kexec_page_to_pfn/kexec_pfn_to_page, etc? People
> might not need to know about boot view physical address and kernel view
> physical address things when they just want to understand kexec
> implementation related to one ARCH except of ARM, even related to ARM
> but not Keystone 2.

Well, what do you suggest we do instead?

Eric, please get involved in this discussion, as this was your idea.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
