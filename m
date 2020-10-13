From: Masahiro Yamada <masahiroy@kernel.org>
Date: Tue, 13 Oct 2020 16:02:19 +0000
Subject: Re: [PATCH v2 2/2] kbuild: use interpreters to invoke scripts
Message-Id: <CAK7LNARRDz-+HqXtW6o7nowwprBSgKkhx7-Joe2=hjgLp4o+4A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
 <20201012170631.1241502-3-ujjwalkumar0501@gmail.com> <alpine.DEB.2.21.2010122019410.17866@felia>
 <b4fdc7c5-8edf-3895-69fc-1bcf9efb5d4a@gmail.com> <53b7257e-b192-07da-9dd3-06497ce826f0@petrovitsch.priv.at>
In-Reply-To: <53b7257e-b192-07da-9dd3-06497ce826f0@petrovitsch.priv.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Ujjwal Kumar <ujjwalkumar0501@gmail.com>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, clang-built-linux <clang-built-linux@googlegroups.com>, linux-kernel-mentees@lists.linuxfoundation.org

On Tue, Oct 13, 2020 at 4:03 AM Bernd Petrovitsch
<bernd@petrovitsch.priv.at> wrote:
>
> Hi all!
>
> On 12/10/2020 18:42, Ujjwal Kumar wrote:
> > On 12/10/20 11:50 pm, Lukas Bulwahn wrote:
> >>
> >>
> >> On Mon, 12 Oct 2020, Ujjwal Kumar wrote:
> >>
> >>> We cannot rely on execute bits to be set on files in the repository.
> >>> The build script should use the explicit interpreter when invoking any
> >>> script from the repository.
> >>>
> >>> Link: https://lore.kernel.org/lkml/20200830174409.c24c3f67addcce0cea9=
a9d4c@linux-foundation.org/
> >>> Link: https://lore.kernel.org/lkml/202008271102.FEB906C88@keescook/
> >>>
> >>> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> >>> Suggested-by: Kees Cook <keescook@chromium.org>
> >>> Suggested-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
> >>> Signed-off-by: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
> >>> ---
> >>>  Makefile                          | 4 ++--
> >>>  arch/arm64/kernel/vdso/Makefile   | 2 +-
> >>>  arch/arm64/kernel/vdso32/Makefile | 2 +-
> >>>  arch/ia64/Makefile                | 4 ++--
> >>>  arch/nds32/kernel/vdso/Makefile   | 2 +-
> >>>  scripts/Makefile.build            | 2 +-
> >>>  scripts/Makefile.package          | 4 ++--
> >>>  7 files changed, 10 insertions(+), 10 deletions(-)
> >>>
> >>> diff --git a/Makefile b/Makefile
> >>> index 0af7945caa61..df20e71dd7c8 100644
> >>> --- a/Makefile
> >>> +++ b/Makefile
> >>> @@ -1256,7 +1256,7 @@ include/generated/utsrelease.h: include/config/=
kernel.release FORCE
> >>>  PHONY +=3D headerdep
> >>>  headerdep:
> >>>     $(Q)find $(srctree)/include/ -name '*.h' | xargs --max-args 1 \
> >>> -   $(srctree)/scripts/headerdep.pl -I$(srctree)/include
> >>> +   $(PERL) $(srctree)/scripts/headerdep.pl -I$(srctree)/include
> >>>
> >>>  # ------------------------------------------------------------------=
---------
> >>>  # Kernel headers
> >>> @@ -1312,7 +1312,7 @@ PHONY +=3D kselftest-merge
> >>>  kselftest-merge:
> >>>     $(if $(wildcard $(objtree)/.config),, $(error No .config exists, =
config your kernel first!))
> >>>     $(Q)find $(srctree)/tools/testing/selftests -name config | \
> >>> -           xargs $(srctree)/scripts/kconfig/merge_config.sh -m $(obj=
tree)/.config
> >>> +           xargs $(CONFIG_SHELL) $(srctree)/scripts/kconfig/merge_co=
nfig.sh -m $(objtree)/.config
> >>>     $(Q)$(MAKE) -f $(srctree)/Makefile olddefconfig
> >>>
> >>>  # ------------------------------------------------------------------=
---------
> >>> diff --git a/arch/arm64/kernel/vdso/Makefile b/arch/arm64/kernel/vdso=
/Makefile
> >>> index edccdb77c53e..fb07804b7fc1 100644
> >>> --- a/arch/arm64/kernel/vdso/Makefile
> >>> +++ b/arch/arm64/kernel/vdso/Makefile
> >>> @@ -65,7 +65,7 @@ $(obj)/%.so: $(obj)/%.so.dbg FORCE
> >>>  # Generate VDSO offsets using helper script
> >>>  gen-vdsosym :=3D $(srctree)/$(src)/gen_vdso_offsets.sh
> >>>  quiet_cmd_vdsosym =3D VDSOSYM $@
> >>> -      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > =
$@
> >>> +      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC=
_ALL=3DC sort > $@
> >>>
> >>>  include/generated/vdso-offsets.h: $(obj)/vdso.so.dbg FORCE
> >>>     $(call if_changed,vdsosym)
> >>> diff --git a/arch/arm64/kernel/vdso32/Makefile b/arch/arm64/kernel/vd=
so32/Makefile
> >>> index 7f96a1a9f68c..617c9ac58156 100644
> >>> --- a/arch/arm64/kernel/vdso32/Makefile
> >>> +++ b/arch/arm64/kernel/vdso32/Makefile
> >>> @@ -205,7 +205,7 @@ quiet_cmd_vdsomunge =3D MUNGE   $@
> >>>  gen-vdsosym :=3D $(srctree)/$(src)/../vdso/gen_vdso_offsets.sh
> >>>  quiet_cmd_vdsosym =3D VDSOSYM $@
> >>>  # The AArch64 nm should be able to read an AArch32 binary
> >>> -      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > =
$@
> >>> +      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC=
_ALL=3DC sort > $@
> >>>
> >>>  # Install commands for the unstripped file
> >>>  quiet_cmd_vdso_install =3D INSTALL32 $@
> >>> diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
> >>> index 703b1c4f6d12..86d42a2d09cb 100644
> >>> --- a/arch/ia64/Makefile
> >>> +++ b/arch/ia64/Makefile
> >>> @@ -27,8 +27,8 @@ cflags-y  :=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-r=
ange=F12-f15,f32-f127 \
> >>>                -falign-functions2 -frename-registers -fno-optimize-si=
bling-calls
> >>>  KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp
> >>>
> >>> -GAS_STATUS =3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)=
" "$(OBJDUMP)")
> >>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-=
flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
> >>> +GAS_STATUS =3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/=
check-gas "$(CC)" "$(OBJDUMP)")
> >>> +KBUILD_CPPFLAGS +=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/sc=
ripts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
> >>
> >> Here is an instance of what Masahiro-san pointed out being wrong.
> >>
> >> Ujjwal, will you send a v3?
> >
> > Following is the quoted text from the reply mail from Masahiro
> >
> >>> -GAS_STATUS     =3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$=
(CC)" "$(OBJDUMP)")
> >>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-=
flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
> >>> +GAS_STATUS     =3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/ch=
eck-gas "$(CC)" "$(OBJDUMP)")
> >>> +KBUILD_CPPFLAGS +=3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/=
toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
> >>
> >>
> >>
> >> These changes look wrong to me.
> >>
> >> $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)
> >>
> >
> > From the above text, I understand as follows:
>
> Did you actually *test* that (expecially) these lines work
> afterwards as good as before?
>
> > That my proposed change:
> > $(shell $(src...)    ->  $($(CONFIG_SHELL) $(src...)
> >
> > is WRONG
>
> Yup, as it's in a Makefile and that's a Makefile construct.
>
> > and in the next line he suggested the required correction.
> > That being:
> > $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)
>
> Such stuff should generally not be needed as the to-be-used
> shell can be set in Makefiles via a "SHELL =3D " assignment
> (defaulting to /bin/sh - what else;-).
> Flags for the shell can BTW set with ".SHELLFLAGS =3D ".


You are talking about a different thing.



Take the current code as an example:

$(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)")


Here are two shell invocations.


[1]
The command
$(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)"
is run in /bin/sh because the default value of SHELL is /bin/sh.


[2]
The script, arch/ia64/scripts/check-gas, is run in /bin/sh
because the hash-bang (the first line of check-gas)
specifies #!/bin/sh




Bernd is talking about [1].

In contrast, this patch is addressing [2] because
Andrew Morton suggested to run scripts without relying
on the executable bit.
(and, after this patch, we run scripts without relying
on the hash-bang because we now specify the interpreter.)


Of course, [1] and [2] can be different.


I always want to use /bin/sh for [1],
so please do not use bash-extension inside $(shell  ...)


You have more choices for [2].

If arch/ia64/scripts/check-gas had been written with bash-extension,
the code would have been changed into:

$(shell $(BASH) $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)")


I hope this will be clearer.




> So please
> -) learn basic "Makefile" + "make" before brainlessly patching
>    a Makefile.
> -) actually testy your changes to make sure the patch didn't
>    broke anything
> -) and - last but not least - check if there isn't a shell
>    already set (and which).
>
> MfG,
>         Bernd
> --
> There is no cloud, just other people computers.
> -- https://static.fsf.org/nosvn/stickers/thereisnocloud.svg



--
Best Regards
Masahiro Yamada
