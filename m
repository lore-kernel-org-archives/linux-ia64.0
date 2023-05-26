From: Song Liu <song@kernel.org>
Date: Fri, 26 May 2023 21:01:31 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <CAPhsuW5pwKe-hPKSyrcnF16Z6KTSYk8mSULcQbDBuvzEb6wneQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, May 26, 2023 at 11:36=E2=80=AFAM Frank Scheiner <frank.scheiner@web=
.de> wrote:
>
> Hi Song,
>
> On 26.05.23 18:49, Song Liu wrote:
> > Hi Frank,
> >
> > Thanks for the report.
>
> Sure, thanks for your help in this.
>
> > It seems the error happened during the WARN_ON_ONCE. Could you
> > please try whether something like the following fixes it?
> >
> > diff --git i/kernel/module/main.c w/kernel/module/main.c
> > index 0f9183f1ca9f..ae42dfc1a815 100644
> > --- i/kernel/module/main.c
> > +++ w/kernel/module/main.c
> > @@ -1537,7 +1537,7 @@ static void __layout_sections(struct module
> > *mod, struct load_info *info, bool i
> >                              || is_init !=3D module_init_layout_section=
(sname))
> >                                  continue;
> >
> > -                       if (WARN_ON_ONCE(type =3D=3D MOD_INVALID))
> > +                       if (type =3D=3D MOD_INVALID)
> >                                  continue;
> >
> >                          s->sh_entsize =3D
> > module_get_offset_and_type(mod, type, s, i);
>
> Ok, tried that as -patch1 on top of v6.4-rc3, but didn't help, see [1].
>
> [1]: https://pastebin.com/UK9v30Ae
>
> > If that doesn't work, maybe we need something like this:
> >
> > diff --git i/arch/ia64/kernel/module.c w/arch/ia64/kernel/module.c
> > index 3661135da9d9..4e9a7f0498e2 100644
> > --- i/arch/ia64/kernel/module.c
> > +++ w/arch/ia64/kernel/module.c
> > @@ -815,7 +815,7 @@ apply_relocate_add (Elf64_Shdr *sechdrs, const
> > char *strtab, unsigned int symind
> >                  uint64_t gp;
> >                  struct module_memory *mod_mem;
> >
> > -               mod_mem =3D &mod->mem[MOD_DATA];
> > +               mod_mem =3D &mod->mem[MOD_TEXT];
> >                  if (mod_mem->size > MAX_LTOFF)
> >                          /*
> >                           * This takes advantage of fact that
> > SHF_ARCH_SMALL gets allocated
>
> Tried that one as -patch2 on top of v6.4-rc3, but didn't help, see [2].
>
> [2]: https://pastebin.com/gLupBndU
>
> I also tried both patches as -patch1plus2 on top of v6.4-rc3 with a
> similar result, see [3].
>
> [3]: https://pastebin.com/7pXBG5vx

Thanks for running the test.

I am not very familiar with the code, but I think we shouldn't hit that
WARN_ON_ONCE. Could you please try with the follow patch to see
which section caused this issue?

Thanks,
Song

diff --git i/kernel/module/main.c w/kernel/module/main.c
index 0f9183f1ca9f..caf3d30cd133 100644
--- i/kernel/module/main.c
+++ w/kernel/module/main.c
@@ -1537,8 +1537,11 @@ static void __layout_sections(struct module
*mod, struct load_info *info, bool i
                            || is_init !=3D module_init_layout_section(snam=
e))
                                continue;

-                       if (WARN_ON_ONCE(type =3D=3D MOD_INVALID))
+                       if (WARN_ON_ONCE(type =3D=3D MOD_INVALID)) {
+                               pr_warn("%s: section %s (sh_flags
%llx) matched to MOD_INVALID\n", __func__,
+                                       sname, s->sh_flags);
                                continue;
+                       }

                        s->sh_entsize =3D
module_get_offset_and_type(mod, type, s, i);
                        pr_debug("\t%s\n", sname);
