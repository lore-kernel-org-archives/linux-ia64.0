From: Greg KH <greg@kroah.com>
Date: Fri, 07 May 2004 21:49:03 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040507214903.GE13511@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040506164040.GA15371@kroah.com> <006901c43418$095436f0$39624c0f@india.hp.com>
In-Reply-To: <006901c43418$095436f0$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, May 07, 2004 at 03:15:30PM +0530, Sourav Sen wrote:
> Here we have "Array of values of same types". And it does not do much
> nifty formatting either. Is that not acceptable?

But they are not of the same time, as you admitted :)

Also, they could be bigger than a single page, right?  That is not
possible right now in sysfs.

> If that is not, how about the following.
> 
> 	1. Create a directory "memmap" under firmware/efi/
> 	2. Create files "map_start", "map_size" and "mapdesc_size" under
>          that exposing ia64_boot_param->efi_memmap,
> ia64_boot_param->efi_memmap_size
> 	   and ia64_boot_param->efi_memdesc_size respectively.
> 
> Userland can make meaning out of them by knowing the values and knowing
> about "efi_memory_desc_t" which is already there in
> /usr/include/asm/efi.h

I think you should address the other issues in this thread before
worrying about the sysfs interface (why have this at all, incorrect
data for hotplug mem, etc.)

> PS: BTW, Your slides on "Dealing with the Linux Kernel Community" at:
> http://www.kroah.com/linux/talks/cgl_talk_2002_10_16/mgp00001.html
> is kind of useful to me. This is my first time :-)

If only more people/companies would heed those rules...

thanks,

greg k-h
