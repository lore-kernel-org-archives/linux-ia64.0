From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 05 Oct 2004 15:43:44 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <200410050843.44265.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Pat Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Monday, October 4, 2004 10:13 pm, Luck, Tony wrote:
> I'm ok with the delete/add of most of the SGI
> specific files (maybe it still isn't perfect yet,
> but it may be close enough to take it, and then
> clean up with some small patches).
>
> But you seem to be touching some files outside of pure SGI
> stuff.  These two are a bit of a concern:
>
>   include/asm-ia64/io.h

Not sure about these changes...

>   arch/ia64/pci/pci.c

It looks like the only non-codingstyle change here is to make pci_root_ops 
non-static (and btw, some of the CodingStyle fixups look wrong).  If it needs 
to be non-static, it should be declared in a header file so we don't have to 
extern it in sn_pci_fixup_bus.

Jesse
