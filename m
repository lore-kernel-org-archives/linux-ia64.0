From: Don Dugger <n0ano@valinux.com>
Date: Mon, 16 Apr 2001 22:51:22 +0000
Subject: Re: [Linux-ia64] Page size
Message-Id: <marc-linux-ia64-105590693005413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005409@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005409@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Donny-

The kernel currently supports 4K, 8K and 16K page sizes.  You can select
any of these page sizes from the kernel config menu's, no change to source
files required.  There's a patch out that allows 64K page size but that
hasn't been integrated into the kernel tree yet.  (32K page size is not
supported by the Itanium, in case you were wondering).

We haven't done exhaustive studies to identify what is the `optimal' page
size yet.  The problem is that larger page sizes can result is less paging
but also can result in more memory being wasted.  Larger page sizes can
also result in more paging `work' as you page in more data than you actually
need.  Unfortunately, the true answer will probably depend upon the bencmark
you use.  My intuition right now is that 4K is definitely too small and 64K
is probably too large.  That's why I make all of my kernels with 16K pages.

On Mon, Apr 16, 2001 at 05:24:18PM -0500, Donny Cooper wrote:
> 
> What portion of source would I need to modify to change the memory page
> size?
> 
> I ran across some info stating that a current optimum page size for
> IA64-Linux is 16KB; any validity to this?
> 
> Are there any major side effects of changing the page size?
> 
> ---------------------------
> We are porting and beginning to benchmark a subset of high performance
> applications, are there any other recommendations for optimizing the Linux
> kernel, or is there a better tuned kernel available anywhere?
> 
> Thanks.
> 
> ***************************************************************************
> Donny Cooper                     | Direct Phone : (281) 465-1506
> NEC Systems, Inc.                | Houston Metro: (281) 296-0912 x 1506
> High Performance Computing Center| Fax          : (281) 465-1599
> 4200 Research Forest Dr, #400    | E-mail       : dcooper@atcc.necsyl.com
> The Woodlands, TX 77381          | URL          : http://www.necservers.com
> ***************************************************************************
> 
> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Don Dugger
> Sent: Monday, April 16, 2001 3:16 PM
> To: Michael Madore
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Page size
> 
> 
> Mike-
> 
> You are correct, page size is a compile time constant, you cannot change
> it at run time.
> 
> The `getpagesize' GLIBC function returns the kernel's page size.
> 
> On Mon, Apr 16, 2001 at 12:50:13PM -0700, Michael Madore wrote:
> > Someone asked me the followind two questions, and I wanted to verify
> before
> > I gave an answer:
> >
> > Is page size tunable at run time, and can the page size be determined at
> run
> > time.
> >
> > I was under the impression that page size was a build time parameter.
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

