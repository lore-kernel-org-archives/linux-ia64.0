From: Andrew Morton <akpm@osdl.org>
Date: Mon, 20 Feb 2006 21:37:36 +0000
Subject: Re: [PATCH -mm HOT-FIX] fix build on ia64 (modpost.c)
Message-Id: <20060220133736.2df448c8.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060220042615.5af1bddc.akpm@osdl.org>
	<20060220192500.GA17003@mars.ravnborg.org>
In-Reply-To: <20060220192500.GA17003@mars.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

Sam Ravnborg <sam@ravnborg.org> wrote:
>
> > 
> > - This kernel won't compile on ia64 (and possibly other architectures)
> >   because the kbuild tree is using Elf_Rela in scripts/mod/modpost.c.  Is OK
> >   on x86, x86_64 and powerpc.  Sam might send a hotfix?
> 
> Attached is a real hot-fix. It disables the new check entirely.

Well that bit compiles.

> I like to learn:
> 1) Why IA64 is missing Elf64_Rela. Can someone drop me a copy of elf.h -
> and include gcc + binutils version in the mail - thanks.

This thing's running RHAS2.1 which I think dates from before the invention
of the transistor.  Running home-made gcc-3.3.2 and binutils-2.14.90.0.6-1.

I'll send along the three elf.h's under /usr/include.

> 2) I also like to know if other architectures broke - so I can figure
> out how to fix this.

Dunno yet - I didn't do the normal batch of cross-compiles due to spending
six hours chasing down new bugs.

> I have tested this on X86_64/amd64 (gentoo based) only.

That fixes the modpost.c compile, but the new futex stuff fails because
ia64 doesn't implement ptr_to_compat().  In fact only three architectures
appear to do so.

