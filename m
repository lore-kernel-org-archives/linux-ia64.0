From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Sep 2006 19:25:55 +0000
Subject: Re: EFI returning incorrect value?
Message-Id: <200609261325.55696.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <004001c6e18c$972938d0$7401a8c0@Maelstrom>
In-Reply-To: <004001c6e18c$972938d0$7401a8c0@Maelstrom>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 26 September 2006 10:55, JWM wrote:
>     I've been trying to work through issues related to write combining on a 
> Bull Ia64 system and something caught my attention.
>     efi_range_is_wc returns a 0 - false or 1- true to say whether the 
> address range is available for write combining.
>     It calls efi_mem_attributes i.e.
> 
>     if(!(efi_mem_attributes(paddr) & EFI_MEMORY_WC))
>             return 0;

That looks right to me.  What problem do you see?

>     However - the attribute returned from efi_mem_attributes is often 0 - 
> which is defined as EFI_MEMORY_RUNTIME - or the range requires a runtime 
> mapping. This doesn't seem to be what was wanted - unless EFI must have a 
> mapping on this platform before WC is available for some reason.

EFI_MEMORY_RUNTIME is not zero:

#define EFI_MEMORY_RUNTIME      ((u64)0x8000000000000000ULL)

The memory attributes EFI reports are independent of any kernel
virtual mappings.

What is your specific problem?  What version of Linux are you using?
efi_mem_attribute() used to incorrectly return the attribute without
stripping out the EFI_MEMORY_RUNTIME bit.  Is that part of the issue?

Can you post the EFI memory map (I think most implementations have
an EFI "memmap" command) and the specific WC mapping you need?

Bjorn
