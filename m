From: Horms <horms@verge.net.au>
Date: Thu, 15 Feb 2007 02:28:32 +0000
Subject: Re: [Fastboot] Zero size /proc/vmcore on ia64
Message-Id: <20070215022829.GD18678@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070212185756.GA22524@strauss.suse.de>
In-Reply-To: <20070212185756.GA22524@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 15, 2007 at 11:15:56AM +0900, Magnus Damm wrote:
> On 2/15/07, Bernhard Walle <bwalle@novell.com> wrote:
> >* Horms <horms@verge.net.au> [2007-02-14 02:38]:
> >> On Tue, Feb 13, 2007 at 06:03:20PM +0100, Bernhard Walle wrote:
> >> > > Index: kexec-tools-bw/kexec/arch/ia64/crashdump-ia64.c
> >> > > =================================> >> > > --- kexec-tools-bw.orig/kexec/arch/ia64/crashdump-ia64.c  2007-02-13 
> >17:39:18.000000000 +0900
> >> > > +++ kexec-tools-bw/kexec/arch/ia64/crashdump-ia64.c       2007-02-13 
> >18:09:44.000000000 +0900
> >> > > @@ -232,13 +232,14 @@
> >> > >                   if (crash_create_elf64_headers(info, &elf_info,
> >> > >                                                  crash_memory_range,
> >> > >                                                  nr_ranges,
> >> > > -                                                &tmp, &sz) < 0)
> >> > > +                                                &tmp, &sz,
> >> > > +                                                4096) < 0)
> >> >
> >> > Why not using EFI_PAGE_SIZE here? It would also be good to find a
> >> > suitable constant name for 1024.
> >>
> >> Indeed, I meant to use EFI_PAGE_SIZE instead of 4096.
> >> I'll fix that up and apply.
> >>
> >> As for a good constant name, I'm open to suggestions.
> >
> >Hmmm ..., I don't know why there must be an alignment to 1024 on i386
> >and x86_64, Vivek?
> 
> The following comment explains it pretty well:
> 
> -       /*
> -        * The kernel command line option memmap= requires 1k granularity,
> -        * therefore we align the size to 1024 here.
> -        */
> -
> -       align = 1024;
> 
> The comment was unfortunately removed by one of the patches in this
> thread, and I think your question is a good proof that we need the
> comment. I asked the same thing a few months ago too. =)

If you can work out a good place to put the comment, I'll put it back in :-)

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

