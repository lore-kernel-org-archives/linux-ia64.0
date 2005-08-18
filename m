From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 18 Aug 2005 13:25:30 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <1124371530.17751.54.camel@uluru.grenoble.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian,

On Thu, 2005-08-18 at 10:53 +1000, Ian Wienand wrote:
> On Tue, Aug 16, 2005 at 03:46:47PM -0700, Luck, Tony wrote:
> > And behind door number 3 is to fix the compiler ... but that also
> > seems to be contentious (and doesn't help people who are already
> > using gcc4).
> 
> I really wouldn't know where to start making the changes James
> suggested, but if someone wants some help with running some benchmarks
> or some hardware, I can help there.
>  
> > Is the simulator in error by only half loading when the structure
> > is on a 4-byte boundary ... if so, then my 2nd choice would be to
> > fix it there.
> 
> <squeaky wheel> HP, please give us the source for SKI </squeaky
> wheel>. :)
> 
Unfortunately, this is not just my decision. 

Anyway, I looked quickly at the simulator code. I don't see anything
wrong on that side. On SSC_COMPLETION, you end up doing a byte by byte
memcpy for copyin for disk_stat and a byte by byte for copyout. Not much
could go wrong there. The definition for disk_stat is identical (w/o the
aligned attribute).

> > But ... since the fix is small, I could put it into the kernel
> > as a last resort to get things working again.  Do you really need
> > to align(16)? Or would (8) do?  A comment mentioning that this
> > is a workaround for a compiler and/or simulator issue would be
> > good.
> 
> It seems to want 16, 8 causes the same problem.  Below includes a
> small comment.
> 

If the small patch below fixes the problem, this should be the way
to solve this. It does not hurt people not using gcc4.


> diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/bootloader.c
> --- a/arch/ia64/hp/sim/boot/bootloader.c
> +++ b/arch/ia64/hp/sim/boot/bootloader.c
> @@ -30,10 +30,14 @@ struct disk_req {
>  	unsigned len;
>  };
>  
> +/* SSC_WAIT_COMPLETION appears to want this large alignment.  gcc < 4
> + * seems to give it by default, however gcc > 4 is smarter and may
> + * not.
> + */
>  struct disk_stat {
>  	int fd;
>  	unsigned count;
> -};
> +} __attribute__ ((aligned (16)));
>  
>  extern void jmp_to_kernel (unsigned long bp, unsigned long e_entry);
>  extern struct ia64_boot_param *sys_fw_init (const char *args, int arglen);
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

