From: Don Dugger <n0ano@valinux.com>
Date: Fri, 20 Apr 2001 19:37:04 +0000
Subject: Re: [Linux-ia64] IA32 process segfaults on exit
Message-Id: <marc-linux-ia64-105590693005445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005442@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005442@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike-

Curious.  I used `gdb' to clear out the registers and you program
is still getting a segv.  I'll look into it.

On Fri, Apr 20, 2001 at 01:24:12PM -0600, Don Dugger wrote:
> Mike-
> 
> How very serendipitous :-)
> 
> This is not supposed to happen but I think I'm working on the solution.
> Some code to initialize EDX on process startup (EDX points to a potential
> atexit routine) got deleted.  I put the code back but it's not working
> properly so there's something else wrong.  Stay tuned.
> 
> On Fri, Apr 20, 2001 at 09:46:06AM -0700, Michael Madore wrote:
> > Hi,
> > 
> > The attached 32 bit code will run without error on IA32, but the same binary
> > will generate the following errors when it returns on IA64.
> > 
> > sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
> > Segmentation fault (core dumped)
> > 
> > Is this expected behavior?
> > 
> > -- 
> > Mike Madore
> > Software Engineer
> > TurboLinux, Inc.
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> -- 
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@valinux.com
> Ph: 303/938-9838
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

