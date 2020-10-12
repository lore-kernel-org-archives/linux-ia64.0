From: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Date: Mon, 12 Oct 2020 18:54:41 +0000
Subject: Re: [PATCH v2 2/2] kbuild: use interpreters to invoke scripts
Message-Id: <b4fdc7c5-8edf-3895-69fc-1bcf9efb5d4a@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
 <20201012170631.1241502-3-ujjwalkumar0501@gmail.com>
 <alpine.DEB.2.21.2010122019410.17866@felia>
In-Reply-To: <alpine.DEB.2.21.2010122019410.17866@felia>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Cc: Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, clang-built-linux@googlegroups.com, linux-kernel-mentees@lists.linuxfoundation.org

On 12/10/20 11:50 pm, Lukas Bulwahn wrote:
>=20
>=20
> On Mon, 12 Oct 2020, Ujjwal Kumar wrote:
>=20
>> We cannot rely on execute bits to be set on files in the repository.
>> The build script should use the explicit interpreter when invoking any
>> script from the repository.
>>
>> Link: https://lore.kernel.org/lkml/20200830174409.c24c3f67addcce0cea9a9d=
4c@linux-foundation.org/
>> Link: https://lore.kernel.org/lkml/202008271102.FEB906C88@keescook/
>>
>> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
>> Suggested-by: Kees Cook <keescook@chromium.org>
>> Suggested-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
>> Signed-off-by: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
>> ---
>>  Makefile                          | 4 ++--
>>  arch/arm64/kernel/vdso/Makefile   | 2 +-
>>  arch/arm64/kernel/vdso32/Makefile | 2 +-
>>  arch/ia64/Makefile                | 4 ++--
>>  arch/nds32/kernel/vdso/Makefile   | 2 +-
>>  scripts/Makefile.build            | 2 +-
>>  scripts/Makefile.package          | 4 ++--
>>  7 files changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/Makefile b/Makefile
>> index 0af7945caa61..df20e71dd7c8 100644
>> --- a/Makefile
>> +++ b/Makefile
>> @@ -1256,7 +1256,7 @@ include/generated/utsrelease.h: include/config/ker=
nel.release FORCE
>>  PHONY +=3D headerdep
>>  headerdep:
>>  	$(Q)find $(srctree)/include/ -name '*.h' | xargs --max-args 1 \
>> -	$(srctree)/scripts/headerdep.pl -I$(srctree)/include
>> +	$(PERL) $(srctree)/scripts/headerdep.pl -I$(srctree)/include
>>
>>  # ---------------------------------------------------------------------=
------
>>  # Kernel headers
>> @@ -1312,7 +1312,7 @@ PHONY +=3D kselftest-merge
>>  kselftest-merge:
>>  	$(if $(wildcard $(objtree)/.config),, $(error No .config exists, confi=
g your kernel first!))
>>  	$(Q)find $(srctree)/tools/testing/selftests -name config | \
>> -		xargs $(srctree)/scripts/kconfig/merge_config.sh -m $(objtree)/.config
>> +		xargs $(CONFIG_SHELL) $(srctree)/scripts/kconfig/merge_config.sh -m $=
(objtree)/.config
>>  	$(Q)$(MAKE) -f $(srctree)/Makefile olddefconfig
>>
>>  # ---------------------------------------------------------------------=
------
>> diff --git a/arch/arm64/kernel/vdso/Makefile b/arch/arm64/kernel/vdso/Ma=
kefile
>> index edccdb77c53e..fb07804b7fc1 100644
>> --- a/arch/arm64/kernel/vdso/Makefile
>> +++ b/arch/arm64/kernel/vdso/Makefile
>> @@ -65,7 +65,7 @@ $(obj)/%.so: $(obj)/%.so.dbg FORCE
>>  # Generate VDSO offsets using helper script
>>  gen-vdsosym :=3D $(srctree)/$(src)/gen_vdso_offsets.sh
>>  quiet_cmd_vdsosym =3D VDSOSYM $@
>> -      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > $@
>> +      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC_AL=
L=3DC sort > $@
>>
>>  include/generated/vdso-offsets.h: $(obj)/vdso.so.dbg FORCE
>>  	$(call if_changed,vdsosym)
>> diff --git a/arch/arm64/kernel/vdso32/Makefile b/arch/arm64/kernel/vdso3=
2/Makefile
>> index 7f96a1a9f68c..617c9ac58156 100644
>> --- a/arch/arm64/kernel/vdso32/Makefile
>> +++ b/arch/arm64/kernel/vdso32/Makefile
>> @@ -205,7 +205,7 @@ quiet_cmd_vdsomunge =3D MUNGE   $@
>>  gen-vdsosym :=3D $(srctree)/$(src)/../vdso/gen_vdso_offsets.sh
>>  quiet_cmd_vdsosym =3D VDSOSYM $@
>>  # The AArch64 nm should be able to read an AArch32 binary
>> -      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > $@
>> +      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC_AL=
L=3DC sort > $@
>>
>>  # Install commands for the unstripped file
>>  quiet_cmd_vdso_install =3D INSTALL32 $@
>> diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
>> index 703b1c4f6d12..86d42a2d09cb 100644
>> --- a/arch/ia64/Makefile
>> +++ b/arch/ia64/Makefile
>> @@ -27,8 +27,8 @@ cflags-y	:=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-range=
=F12-f15,f32-f127 \
>>  		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
>>  KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp
>>
>> -GAS_STATUS	=3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "=
$(OBJDUMP)")
>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-fla=
gs "$(CC)" "$(OBJDUMP)" "$(READELF)")
>> +GAS_STATUS	=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/che=
ck-gas "$(CC)" "$(OBJDUMP)")
>> +KBUILD_CPPFLAGS +=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scrip=
ts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>=20
> Here is an instance of what Masahiro-san pointed out being wrong.
>=20
> Ujjwal, will you send a v3?

Following is the quoted text from the reply mail from Masahiro

>> -GAS_STATUS     =3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC=
)" "$(OBJDUMP)")
>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-fla=
gs "$(CC)" "$(OBJDUMP)" "$(READELF)")
>> +GAS_STATUS     =3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/check=
-gas "$(CC)" "$(OBJDUMP)")
>> +KBUILD_CPPFLAGS +=3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/too=
lchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>=20
>=20
>=20
> These changes look wrong to me.
>=20
> $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)
>=20

From the above text, I understand as follows:

That my proposed change:
$(shell $(src...)    ->  $($(CONFIG_SHELL) $(src...)

is WRONG

and in the next line he suggested the required correction.
That being:
$($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)

Which is in v2 of the patch series.

Lukas, please correct me if I'm wrong so that I can work on v3
if required.

Also, Nathan reviewed both the patches in v1 of this series. So,
should I be the one who adds his tag in next iterations?


Thanks
Ujjwal Kumar
