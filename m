From: Song Liu <song@kernel.org>
Date: Fri, 26 May 2023 22:39:43 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAPhsuW484GVC9PD-cJu5fxX5E1y6XWHgyv3FvJuyOPbpZQx9cw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Fri, May 26, 2023 at 3:22 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, May 26, 2023 at 2:59 PM Luis Chamberlain <mcgrof@kernel.org> wrote:
> >
> > Not saying that debugging commit ac3b4328392344 ("module: replace
> > module_layout with module_memory") is going to be impossible, quite
> > the contrary I think it would be good to root cause it, if possible,
> > as perhaps it may also be similar to some other future oddball arch
> > bug later that may come up.
>
> I don't have any context - the mailing lists in question that
> apparently this came in on aren't in lore.
>
> That said, that commit looks odd for the ia64 part.
>
> In particular, this part:
>
>   -               if (mod->core_layout.size > MAX_LTOFF)
>   +               struct module_memory *mod_mem;
>   +
>   +               mod_mem = &mod->mem[MOD_DATA];
>
> in apply_relocate_add() (file: arch/ia64/kernel/module.c) seems suspect.
>
> The previous place that used to look at "mod->core_layout.base"
> converted that to "mod->mem[MOD_TEXT].base". As do other changes in
> other architectures.
>
> So that "MOD_DATA" looks *very* wrong.  Shouldn't core_layout. be
> translated to use "MOD_TEXT" instead?

MOD_DATA is likely wrong here. But as Frank tested, changing it to MOD_TEXT
didn't fix the issue. I suspect we missed some special cases when we updated
layout_sections().

Thanks,
Song
