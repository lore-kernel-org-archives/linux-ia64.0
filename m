From: Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net>
Date: Mon, 12 Jul 2004 14:36:59 +0000
Subject: Re: [netfilter-core] strict rejection of init -> core references
Message-Id: <Pine.LNX.4.44.0407121607000.21599-100000@daphne.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 10 Jul 2004, Harald Welte wrote:

> On Fri, Jul 09, 2004 at 12:19:46PM -0700, Luck, Tony wrote:
> > >So what really happens is: calls from init to 'core' functions 
> > >and calls from 'exit' to core functions.
> > 
> > Hmmm.  Neither of those should have tripped the check in the
> > kernel module loader.  It should only go bang when you have a
> > call from "core" to "init".  Does "exit" end up in a separate
> > section?  Maybe I was mistakenly triggering on the exit->core?
> 
> Apparently yes:
> 
>   0 .text         00003f78  00000000  00000000  00000034  2**2
>                   CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
>   1 .init.text    0000029c  00000000  00000000  00003fac  2**2
>                   CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
>   2 .exit.text    00000008  00000000  00000000  00004248  2**2
>                   CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE

AFAIK, only section with names beginning with ".init" are treated 
differently by the kernel module loader, in:
  kernel/module.c:layout_sections()
  arch/ia64/kernel/module.c:module_frob_arch_sections()

Common code in kernel/module.c:load_module() makes only 2 calls to (arch 
specific) module_alloc(), and uses one area for init code/data/plt/etc. 
and the other for "core" (including .exit sections) code/data/...

So I don't think the patch can cause any problem with exit sections.


-- 
Jean-Marc Saffroy - jean-marc.saffroy@ext.bull.net

