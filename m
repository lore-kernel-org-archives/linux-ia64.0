From: "Sourav Sen" <souravs@india.hp.com>
Date: Tue, 11 May 2004 14:56:27 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <00b201c43766$7646a670$39624c0f@india.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040507214903.GE13511@kroah.com>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg KH' <greg@kroah.com>, 'Sourav Sen' <souravs@india.hp.com>
Cc: Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

+ -----Original Message-----
+ From: Greg KH [mailto:greg@kroah.com]
+ Sent: Saturday, May 08, 2004 3:19 AM
+ To: Sourav Sen
+ Cc: Matt_Domsch@dell.com; matthew.e.tolentino@intel.com;
+ linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
+ Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
+ 
+ 
+ On Fri, May 07, 2004 at 03:15:30PM +0530, Sourav Sen wrote:
+ > Here we have "Array of values of same types". And it does 
+ not do much
+ > nifty formatting either. Is that not acceptable?
+ 
+ But they are not of the same time, as you admitted :)
+ 

	Right. On similar lines I believe we need to split 
firmware/efi/systab as well.

+ Also, they could be bigger than a single page, right?  That is not
+ possible right now in sysfs.
+ 
+ > If that is not, how about the following.
+ > 
+ > 	1. Create a directory "memmap" under firmware/efi/
+ > 	2. Create files "map_start", "map_size" and "mapdesc_size" under
+ >          that exposing ia64_boot_param->efi_memmap,
+ > ia64_boot_param->efi_memmap_size
+ > 	   and ia64_boot_param->efi_memdesc_size respectively.
+ > 
+ > Userland can make meaning out of them by knowing the values 
+ and knowing
+ > about "efi_memory_desc_t" which is already there in
+ > /usr/include/asm/efi.h
+ 
+ I think you should address the other issues in this thread before
+ worrying about the sysfs interface (why have this at all, incorrect
+ data for hotplug mem, etc.)
+ 
	I did not hear whether the idea of updating efi memory map on a 
hotplug is good or bad. In any case, can somebody tell me to how do 
I get the available physical range map (only the ranges that VM is 
using at a given point in time) from userland. I believe I outlined 
a legitimate requirement earlier in this thread :-)

Thanks
Sourav 
