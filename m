From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 10 Dec 2004 02:46:51 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <200412091846.51333.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
In-Reply-To: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, December 09, 2004 6:01 pm, Russ Anderson wrote:
> Changes from the previous patch:
>
>   * mm/init.c: Add efi_get_pal_addr() call to set pal_base and pal_paddr
>     in cpuinfo later in the init process.
>
>   * efi.c: Add efi_get_pal_addr() to set pal_base and pal_paddr.
>
>   * mca_asm.S: Remove extra stop bits.
>  Added some syntactic sugar macros.
>  Make init stack per cpu, too.
>
>   * minstate.h: Modify MINSTATE_START_SAVE_MIN_PHYS to use ar.k3.
>
>   * Generate patch at correct level.

Tony, do you plan to apply this patch to your post-2.6.10 tree?  If so, can 
you expose it on lia64.bkbits.net along with the other stuff you've applied?  
That would make it a bit easier to work on some of these new MCA features.

Thanks,
Jesse
