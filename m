From: Jay Lan <jlan@sgi.com>
Date: Fri, 03 Nov 2006 17:42:23 +0000
Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <454B7F7F.2050802@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:
>   --noio patch should be the same to my original sugguestion..., it bypass all PIO and MMIO in purgatory with --noio option. I need to have a check though.

Hi Nanhai,

I finally got a chance to look at this further.

Your patch touched four files:
    kexec/arch/ia64/kexec-elf-ia64.c
    purgatory/arch/ia64/entry.S
    purgatory/arch/ia64/include/arch/io.h
    purgatory/arch/ia64/io.h

I replaced both of the io.h with my version and it still
failed. So, it should be the way --noio option being handled
that made the difference.

I did have debug messages showing that "noio" option was
processed in elf_rel_set_symbol() in my testing. Does
kernel code need to know about this option? Somehow
this change makes kernel fail in init().

Thanks,
 - jay


> 
>   Thanks
>   Zou Nan hai
