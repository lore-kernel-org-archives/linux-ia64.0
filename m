From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 May 2023 22:22:28 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAHk-=whuaCqh0RJk1F+SKqdEHPzANoVVP5OU=c9wgogVLCQTVQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, May 26, 2023 at 2:59=E2=80=AFPM Luis Chamberlain <mcgrof@kernel.org=
> wrote:
>
> Not saying that debugging commit ac3b4328392344 ("module: replace
> module_layout with module_memory") is going to be impossible, quite
> the contrary I think it would be good to root cause it, if possible,
> as perhaps it may also be similar to some other future oddball arch
> bug later that may come up.

I don't have any context - the mailing lists in question that
apparently this came in on aren't in lore.

That said, that commit looks odd for the ia64 part.

In particular, this part:

  -               if (mod->core_layout.size > MAX_LTOFF)
  +               struct module_memory *mod_mem;
  +
  +               mod_mem =3D &mod->mem[MOD_DATA];

in apply_relocate_add() (file: arch/ia64/kernel/module.c) seems suspect.

The previous place that used to look at "mod->core_layout.base"
converted that to "mod->mem[MOD_TEXT].base". As do other changes in
other architectures.

So that "MOD_DATA" looks *very* wrong.  Shouldn't core_layout. be
translated to use "MOD_TEXT" instead?

Nothing else in the ia64 parts strike me as odd, but that one looks wrong t=
o me.

But this is my "monkey see, monkey do" pattern matching reaction, not
from any deeper understanding of the problem (I can't even see the
report) or really even the code.

                   Linus
