From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 22 Apr 2004 16:46:59 +0000
Subject: Re: [patch 1/3] efivars driver update and move
Message-Id: <200404221046.59541.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
In-Reply-To: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt_Domsch@dell.com, matthew.e.tolentino@intel.com

On Thursday 22 April 2004 11:32 am, Matt Tolentino wrote:
> I broke up the efivars driver update patch I had sent out
> quite a while ago into several smaller patches.  This 
> includes several fixes and suggestions that were pointed
> out.  The patches are broken down as follows:
> 
> 1 - remove all traces of efivars from arch/ia64/
> 2 - add new sysfs based efivars driver into
>     drivers/firmware with accompanying Kconfig/Makefile 
>     changes to make it fully functional for ia64 again.
> 3 - cleans up x86 references to the /proc version of 
>     the efivars driver.

I like these changes.

I did notice that the new drivers/.../efivars.c is not identical to
the old arch/ia64/kernel/efivars.c (the hints to emacs were removed).
I like the emacs hint removal, but didn't review patch for any other
differences.

Any plans to consolidate other bits from efi.c?  There are a number
of things there that look like they could be shared:

	is_available_memory()
	efi_init()
		(mostly)
	efi_initialize_iomem_resources()
		(i386 only today, but I think we'd like it for ia64 also)
	efi_mem_type()
	efi_mem_attributes()
		(the i386 versions look slightly buggy in that they
		assume a fixed descriptor size, so old kernels won't
		work with new firmware that adds stuff to the descriptor)

Bjorn
