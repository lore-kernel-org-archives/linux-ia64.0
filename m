From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 22 Apr 2004 17:14:05 +0000
Subject: RE: [patch 1/3] efivars driver update and move
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEAB3@fmsmsx406.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
In-Reply-To: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt_Domsch@dell.com

> I like these changes.

Thanks!  

> I did notice that the new drivers/.../efivars.c is not identical to
> the old arch/ia64/kernel/efivars.c (the hints to emacs were removed).
> I like the emacs hint removal, but didn't review patch for any other
> differences.

Right, it's been fully converted to sysfs.  Just for reference, the 
resultant sysfs tree looks something like:

/sys |
     ...
     |-firmware 
	       |-efi
		   |-systab
		   |-vars 
			 |- BootNext-xxxx-xxx-x-x-x-x *
				|-attributes
				|-data
				|-guid
				|-raw_var
				|-size
			 |- BootCurrent-xxxxxx-x-x-x-x *
			 |- ConOut-xxxx-x-x-x-x-x-x-*
			 ...
			 |- del_var
			 |- new_var 

where xxxx-x-x-x-x-x is the GUID.  

> Any plans to consolidate other bits from efi.c?  There are a number
> of things there that look like they could be shared:

Yes, I plan to consolidate as much of the common code as possible soon.


matt

