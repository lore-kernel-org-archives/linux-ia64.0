From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 18 Jul 2003 16:13:02 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105854507724104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 17 July 2003 8:22 pm, Christopher Wedgwood wrote:
> On Thu, Jul 17, 2003 at 04:52:53PM -0600, Bjorn Helgaas wrote:
> 
> > Have you tripped over something in particular that prevents
> > machvec_init() from working earlier?
> 
> I tried something similar earlier using ia64_platform_is("sn2") which
> uses the ACPI data and it didn't work that early on.  Let me check
> this again and also see if the machine vector approach works and
> resend a patch.

ia64_platform_is() only works after calling machvec_init().  If you
move the machvec_init() call into the middle of efi_init(), I think
it should work.  But I do prefer the machine vector approach,
and there are several other machine vectors used only at boot-time,
so I don't think that's an issue.

> It seems it *should* be safe to not trim PAL code and then the
> efi_mem_attributes check will work correctly in 2.5.  I couldn't see
> anything using the granule-sized-assumptions that would break if I did
> this (in fact, I didn't trim the PAL code in an internal tree for some
> time and never saw any problems on zx1, tiger or sn2 --- but I wasn't
> looking hard for it).

You said the granule containing PAL contained regions with different
cacheability attributes.  That means the kernel can't use any memory
in that granule (we would insert kernel mapping that covers the entire
granule).  So the kernel does have to ignore the granule, and modifying
the EFI memmap, while maybe not ideal, is the current approach.

Bjorn

