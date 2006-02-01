From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 01 Feb 2006 14:35:25 +0000
Subject: Re: [Patch:000/004] Unify pxm_to_node id ver.2.
Message-Id: <43E0C72D.4070709@shadowen.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201205152.41E6.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060201205152.41E6.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Brown, Len" <len.brown@intel.com>, Bob Picco <bob.picco@hp.com>, Paul Jackson <pj@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, ACPI-ML <linux-acpi@vger.kernel.org>, linux-ia64@vger.kernel.org, x86-64 Discuss <discuss@x86-64.org>

Yasunori Goto wrote:
> Hello.
> 
> I rewrote patches to unify mapping from pxm to node id as ver.2.
> I already posted all of fixes for ver.1.
> However, searching first patch and appling fixes are a bit messy
> due to too many mail and patches in LKML.
> So, I rearranged them to find all of them easier.
> Basically, (ver.1 + previous fix patches) = ver.2.
> But ver.2 is set of following patches.
>   - generic code.
>   - for ia64.
>   - for x86_64.
>   - for i386.
> 
> Fixes from ver.1 are followigs.
>   - They are for 2.6.16-rc1-mm4.
>   - Fix old map from HP and SGI's code by Bob Picco-san.
>   - Remove MAX_PXM_DOMAINS from asm-ia64/acpi.h. It is already defined at
>     include/acpi/acpi_numa.h.
>   - Fix return code of setup_node() at arch/x86_64/mm/srat.c
>   - Fix ACPI_NUMA config for i386 by Andy Witcroft-san.
>   - Define dummy functions for i386's compile error.
>   - Remove garbage nid_to_pxm_map from acpi20_parse_srat() 
>     at arch/i386/kernel/srat.c
> 
> I tested ia64 and x86_64 with dummy SRAT NUMA emulation.
> And I checked compile completion for hp, SGI, and Summit.

Ran it across my test boxes, builds and boots on the affected platforms
and generally elsewhere.

-apw

