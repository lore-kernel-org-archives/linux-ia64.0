From: miyoshi@hpc.bs1.fc.nec.co.jp
Date: Fri, 16 Nov 2001 06:17:09 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Thank you for your patch!
Hideki tested it and it seems to work fine.

BTW, how about the following optimization?
IA32-glibc's calloc can call sbrk with 4K boundary.
When we do 4k sbrk, we do not need fully zero-ing up to 16K boundary,
but just up to obrk.

(Think about four sbrk(-0x1000) case)

Thanks.

+asmlinkage unsigned long
+sys32_brk(unsigned int brk)
+{
+	unsigned long ret, obrk;
+	struct mm_struct *mm = current->mm;
+
+	obrk = mm->brk;
+	ret = sys_brk(brk);
+	if (ret < obrk){
+		unsigned long to;
+		to = (obrk < PAGE_ALIGN(ret) ? obrk : PAGE_ALIGN(ret));
+		clear_user(ret, to-ret);
+	}
+	return(ret);
+} 





> David-
> 
> OK, here's the patch to fix this.  I guess the only issue is that we
> have to have Yet Another IA32 System call shim but other than that
> the change is pretty minor.
> 
> PS:  Hideki, please note that this is a different, slightly better
> patch than the one I sent you last night.  You should use this one.
> 
> On Tue, Nov 13, 2001 at 11:43:55PM -0700, Dugger's wrote:
> > Never mind, I found the `calloc' code and I'm very depressed because it
> > does indeed assume that `brk' zeros out newly allocated memory which is
> > obviously going to create problems if `calloc' thinks the kernel has 4K
> > pages when it really has bigger ones.
> > 
> > Unfortunately, this means I'll have to make an IA32 specific `brk' call that
> > zero's out the last part of the last page currently allocated to a process.
> > Oh well, patch to follow later.
> > --
> > Don Dugger
> > n0ano@indstorage.com
> > ----- Original Message -----
> > From: "Dugger's" <ddugger@qwest.net>
> > To: <davidm@hpl.hp.com>; <n0ano@indstorage.com>
> > Cc: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>;
> > <linux-ia64@linuxia64.org>
> > Sent: Tuesday, November 13, 2001 11:16 PM
> > Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
> > 
> > 
> > > I'm a little confused.  From Hideki's test program the problem actually
> > > seems
> > > to be using `sbrk' to return memory and then allocating memory again.  The
> > > second
> > > time the re-allocated memory is not zeroed, e.g.:
> > >
> > >     p = sbrk(4096);
> > >     q = sbrk(-4096);
> > >     r = sbrk(4096);
> > >
> > > and the memory pointed to by `r' is not zeroed.  I just got through
> > reading
> > > the
> > > man page for `brk' and `sbrk' and neither one specifies that newly
> > allocated
> > > memory is zeroed and therefore I interpret this issue as undefined
> > behavior.
> > > Any program that depends upon the contents of newly allocated memory is
> > > broken.  In fact, if you compile the test program, `d.c', for IA64 and run
> > > it it
> > > fails.  Also, if you compile the test program for IA32 and use 1K
> > allocation
> > > blocks
> > > the program fails on an IA32 machine also.
> > >
> > > Someone correct me if I'm wrong about this.
> > >
> > > PS:  I know that `calloc' is defined to zero out the allocated memory but
> > > from
> > > what I can tell it does this by explicitly calling `memset'.  I'm trying
> > to
> > > verify this
> > > but I haven't found the `calloc' code in the `glibc' tree yet.  (The
> > `glibc'
> > > tree always
> > > confuses me, if anyone can tell me exactly where to find the `calloc' code
> > > I'd
> > > appreciate it :-)
> > > --
> > > Don Dugger
> > > n0ano@indstorage.com
> > > ----- Original Message -----
> > > From: "David Mosberger" <davidm@hpl.hp.com>
> > > To: <n0ano@indstorage.com>
> > > Cc: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>;
> > > <linux-ia64@linuxia64.org>
> > > Sent: Monday, November 12, 2001 4:58 PM
> > > Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
> > >
> > >
> > > > But I think the page size problem with brk() is real and can be fixed
> > > > quite easily.  If I understood correctly, the problem is that doing
> > > > something along the lines of:
> > > >
> > > > x = ALIGN_TO_4K(sbrk(8192));
> > > > memset(x, 0xff, 4096);
> > > > brk(x);
> > > > brk(x+4096);
> > > >
> > > > might preserve the contents of the page at X on under the ia32
> > > > subsystem of ia64 when in fact it should be cleared to zero.
> > > >
> > > > Would you be able/interested into looking into this?
> > > >
> > > > --david
> > > >
> > >
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> -- 
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@indstorage.com
> Ph: 303/652-0870x117
> 
> diff -aur kernel-bigsur-ref/arch/ia64/ia32/ia32_entry.S kernel-bigsur/arch/ia64/ia32/ia32_entry.S
> --- kernel-bigsur-ref/arch/ia64/ia32/ia32_entry.S	Tue Sep 25 19:40:29 2001
> +++ kernel-bigsur/arch/ia64/ia32/ia32_entry.S	Wed Nov 14 21:07:28 2001
> @@ -209,7 +209,7 @@
>  	data8 sys32_pipe
>  	data8 sys32_times
>  	data8 sys32_ni_syscall	  /* old prof syscall holder */
> -	data8 sys_brk		  /* 45 */
> +	data8 sys32_brk		  /* 45 */
>  	data8 sys_setgid	/* 16-bit version */
>  	data8 sys_getgid	/* 16-bit version */
>  	data8 sys32_signal
> diff -aur kernel-bigsur-ref/arch/ia64/ia32/sys_ia32.c kernel-bigsur/arch/ia64/ia32/sys_ia32.c
> --- kernel-bigsur-ref/arch/ia64/ia32/sys_ia32.c	Tue Sep 25 19:40:29 2001
> +++ kernel-bigsur/arch/ia64/ia32/sys_ia32.c	Thu Nov 15 07:29:24 2001
> @@ -68,6 +68,7 @@
>  
>  /* forward declaration: */
>  asmlinkage long sys32_mprotect (unsigned int, unsigned int, int);
> +asmlinkage unsigned long sys_brk(unsigned long);
>  
>  static int
>  nargs (unsigned int arg, char **ap)
> @@ -2123,6 +2124,7 @@
>  	      default:
>  		return -EINVAL;
>  	}
> +	return -EINVAL;
>  }
>  
>  /*
> @@ -3376,6 +3378,19 @@
>  		ret = PER_LINUX;
>  	return ret;
>  }
> +
> +asmlinkage unsigned long
> +sys32_brk(unsigned int brk)
> +{
> +	unsigned long ret, obrk;
> +	struct mm_struct *mm = current->mm;
> +
> +	obrk = mm->brk;
> +	ret = sys_brk(brk);
> +	if (ret < obrk)
> +		clear_user(ret, PAGE_ALIGN(ret) - ret);
> +	return(ret);
> +} 
>  
>  #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
>  
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

