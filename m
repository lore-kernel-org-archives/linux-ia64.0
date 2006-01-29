From: "Bob Picco" <bob.picco@hp.com>
Date: Sun, 29 Jan 2006 03:44:34 +0000
Subject: Re: [PATCH 001/003]Fix unify mapping from pxm to node id.
Message-Id: <20060129034434.GO7306@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060123165644.C147.Y-GOTO@jp.fujitsu.com> <20060126074846.1a6dd300.pj@sgi.com> <20060128122758.CF50.Y-GOTO@jp.fujitsu.com> <20060127231517.4c0ce573.pj@sgi.com>
In-Reply-To: <20060127231517.4c0ce573.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, akpm@osdl.org, apw@shadowen.org, bob.picco@hp.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, ak@suse.de, len.brown@intel.com, discuss@x86-64.org

Paul Jackson wrote:	[Sat Jan 28 2006, 02:15:17AM EST]
> Yasunori-san,
> 
> Thank-you for updating your patch.
> 
> However I am still puzzled by one detail.
> 
> Your latest patchset removes the defines:
> -#define MAX_PXM_DOMAINS	256	/* 1 byte and no promises about values */
> 
> and:
> -#define MAX_PXM_DOMAINS (256)
> 
> but continues to have code using MAX_PXM_DOMAINS.  I am unable
> to compile ia64 with it now, for lack of this define.
> 
> -- 
>                   I won't rest till it's the best ...
>                   Programmer, Linux Scalability
>                   Paul Jackson <pj@sgi.com> 1.925.600.0401
Hi Paul. 

MAX_PXM_DOMAINS is defined in include/acpi/acpi_numa.h.  So I'm confused.

I just built sn2 with Yasunori's patches applied to -mm3. I had previously
built sn2 with a slightly different patch series of mine which Yasunori 
later incorporated most of into this patch series. Would you please send your 
.config and the error output from the build? 

thanks,

bob
