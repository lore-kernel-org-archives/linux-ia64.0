From: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Date: Mon, 26 Apr 2004 19:30:10 +0000
Subject: Re: [patch 1/3] efivars driver update and move
Message-Id: <200404262115.i3QLFdKE001551@snoqualmie.dp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
In-Reply-To: <200404221732.i3MHWJcc023373@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, Matt_Domsch@dell.com, metolent@snoqualmie.dp.intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>Patch below fixes three small bugs in efivars.c as posted by Matt
>Tolentino last week and included in the latest -mm.  Aside from this
>small patch, I'm quite pleased with Matt T's work, thanks! 
>
>* dummy() used for reading write-only sysfs files should return
>  -ENODEV to indicate failure, not 0.
>* efivar_create() should return the number of bytes written on
>  success, not zero.  
>* efivar_delete() should return the number of bytes written on
>  success, not zero.
>
>Compiled, tested with efibootmgr-0.5.0-test3.  The anomolies I noted
>late Friday night are resolved by this kernel patch - efibootmgr was
>actually testing the values returned by writes.

Thanks for taking the time to look at this Matt...

matt

