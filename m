From: Don Dugger <n0ano@valinux.com>
Date: Mon, 07 May 2001 20:35:15 +0000
Subject: Re: [Linux-ia64] IA32 process segfaults on exit
Message-Id: <marc-linux-ia64-105590693005544@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005442@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005442@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Michael-

Well, unless anyone else can prove different, I'm just going to chalk
this one up as application error and declare the kernel innocent.

PS: Yes, I feel your RPM pain.  It's one of those programs that, when
it works, it's great but, when it doesn't work ...

On Mon, May 07, 2001 at 01:26:17PM -0700, Michael Madore wrote:
> Hi Don,
> 
> I'm not intimately familiar with what the author (not me, really!) was
> trying to accomplish.  I believe that the code belongs to part of the IA32
> installer that is making BIOS calls to get drive geometry.  I guess since it
> didn't outright break on IA32, nobody questioned whether it was actually
> correct or not.
> 
> If you only saw the RPM handling code that we just ported... ugh!  Integer
> -> pointer -> integer conversions all over the place.
> 
> Anyway, as I said, we removed this code and replaced it with something that
> doesn't suck as much. ;-)
> 
> On Mon, May 07, 2001 at 02:00:46PM -0600, Don Dugger wrote:
> > Michael-
> > 
> > Um, I think I found your problem and I'm pretty sure it's program
> > error.  The test case you sent effectively does:
> > 
> > 	fd_zero = open("/dev/zero", O_RDONLY);
> > 	m = mmap(0x10000, 0x10000, ..., fd_zero, 0);
> > 
> > This mapps zeros to loation 0x10000.  What makes you think that
> > the address 0x10000 is free?  On an IA32 machine the Run Time LoaDer
> > is loaded at 0x2aaab000 so this location, strictly by chance, is free.
> > On Trillian the RTLD is loaded at 0x4000 (actually, it's the first
> > page boundary) so you've mapped zero's on top of RTLD.
> > 
> > I'm really curious, why do you think 0x10000 is free?
> > 
> > On Fri, Apr 20, 2001 at 09:46:06AM -0700, Michael Madore wrote:
> > > Hi,
> > > 
> > > The attached 32 bit code will run without error on IA32, but the same binary
> > > will generate the following errors when it returns on IA64.
> > > 
> > > sizeof(elf_gregset_t) (1024) != sizeof(struct pt_regs) (400)
> > > Segmentation fault (core dumped)
> > > 
> > > Is this expected behavior?
> > > 
> > > -- 
> > > Mike Madore
> > > Software Engineer
> > > TurboLinux, Inc.
> > > 
> > > _______________________________________________
> > > Linux-IA64 mailing list
> > > Linux-IA64@linuxia64.org
> > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > 
> > -- 
> > Don Dugger
> > "Censeo Toto nos in Kansa esse decisse." - D. Gale
> > n0ano@valinux.com
> > Ph: 303/938-9838
> 
> -- 
> Mike Madore
> Senior Software Engineer
> TurboLinux, Inc.
> (650)228-5203

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

