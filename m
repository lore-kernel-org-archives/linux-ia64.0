From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 03:45:38 +0000
Subject: Re: [Fastboot] IA64: kexec seg fault at xrealloc
Message-Id: <20061213034536.GK22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061204110510.fde8bcdb.akiyama.nobuyuk@jp.fujitsu.com>
In-Reply-To: <20061204110510.fde8bcdb.akiyama.nobuyuk@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 04, 2006 at 02:48:33PM +0800, Zou Nan hai wrote:
> On Mon, 2006-12-04 at 10:05, Akiyama, Nobuyuki wrote:
> > Hi Jay,
> > 
> > The attacked patch fixes the problem.
> > Please try.
> > 
> > diff -Nurp kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c
> > kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c
> > --- kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c     
> > 2006-11-09 19:40:52.000000000 +0900
> > +++ kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c  2006-11-13
> > 19:17:15.000000000 +0900
> > @@ -316,9 +316,13 @@ int load_crashdump_segments(struct kexec
> >         int nr_ranges;
> >         size_t size;
> >         void *tmp;
> > +       long int nr_cpus = 0;
> > +       if ((nr_cpus = sysconf(_SC_NPROCESSORS_CONF)) < 0)
> > +               return -1;
> >         if (info->kexec_flags & KEXEC_ON_CRASH ) {
> >                 if (get_crash_memory_ranges(&mem_range, &nr_ranges) =
> > 0) {
> >                         size =  sizeof(Elf64_Ehdr) +
> > +                               (nr_cpus + 1) * sizeof(Elf64_Phdr) +
> >                                 (nr_ranges + 1) * sizeof(Elf64_Phdr);
> >                         size = (size + EFI_PAGE_SIZE - 1) &
> > ~(EFI_PAGE_SIZE - 1);
> >                         tmp = xmalloc(size);
> > 
> 
>  Hi, 
> 	Thanks for finding the is bug, I missed percpu notes segments in size
> calculation here. However I think we should also include the nr_ranges
> in calculation.
> 
> 	--- a/kexec/arch/ia64/crashdump-ia64.c	2006-12-04 04:19:42.000000000 -0500
> +++ b/kexec/arch/ia64/crashdump-ia64.c	2006-12-04 04:21:23.000000000 -0500
> @@ -313,13 +313,15 @@ int load_crashdump_segments(struct kexec
>  {
>  	//struct memory_range *mem_range, *memmap_p;
>  	struct memory_range *mem_range;
> -	int nr_ranges;
> +	int nr_ranges, nr_cpus;
>  	size_t size;
>  	void *tmp;
> +        if ((nr_cpus = sysconf(_SC_NPROCESSORS_CONF)) < 0)
> +		return -1;
>  	if (info->kexec_flags & KEXEC_ON_CRASH ) {
>  		if (get_crash_memory_ranges(&mem_range, &nr_ranges) = 0) {
>  			size =  sizeof(Elf64_Ehdr) +
> -				(nr_ranges + 1) * sizeof(Elf64_Phdr);
> +				(nr_ranges + nr_cpus + 1) * sizeof(Elf64_Phdr);
>  			size = (size + EFI_PAGE_SIZE - 1) & ~(EFI_PAGE_SIZE - 1);
>  			tmp = xmalloc(size);
>  			memset(tmp, 0, size);

Hi,

that patch looks correct to me. However, I believe that the problem is
already resolved in kexec-tools-testing by using the generic /proc/iomem
handling code that was introduced in changesets
c80198e78ce26783e092645b9ac8587e1374f22f and
f038d30bff8510a1df1e72af08db1766581d1f2c.

Could someone please test this?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

