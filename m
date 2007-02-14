From: Horms <horms@verge.net.au>
Date: Wed, 14 Feb 2007 01:38:37 +0000
Subject: Re: [Fastboot] Zero size /proc/vmcore on ia64
Message-Id: <20070214013835.GA24549@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070212185756.GA22524@strauss.suse.de>
In-Reply-To: <20070212185756.GA22524@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 13, 2007 at 06:03:20PM +0100, Bernhard Walle wrote:
> > Index: kexec-tools-bw/kexec/arch/ia64/crashdump-ia64.c
> > =================================> > --- kexec-tools-bw.orig/kexec/arch/ia64/crashdump-ia64.c	2007-02-13 17:39:18.000000000 +0900
> > +++ kexec-tools-bw/kexec/arch/ia64/crashdump-ia64.c	2007-02-13 18:09:44.000000000 +0900
> > @@ -232,13 +232,14 @@
> >  			if (crash_create_elf64_headers(info, &elf_info,
> >  						       crash_memory_range,
> >  						       nr_ranges,
> > -						       &tmp, &sz) < 0)
> > +						       &tmp, &sz,
> > +						       4096) < 0)
> 
> Why not using EFI_PAGE_SIZE here? It would also be good to find a
> suitable constant name for 1024.

Indeed, I meant to use EFI_PAGE_SIZE instead of 4096.
I'll fix that up and apply.

As for a good constant name, I'm open to suggestions.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

