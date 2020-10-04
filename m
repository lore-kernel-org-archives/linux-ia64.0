From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Sun, 04 Oct 2020 06:51:36 +0000
Subject: Re: [PATCH RFC 0/2] use interpreters to invoke scripts
Message-Id: <alpine.DEB.2.21.2010040809230.28226@felia>
List-Id: <linux-ia64.vger.kernel.org>
References: <2b00e566-112c-5657-c10f-7f210d3eae93@gmail.com>
In-Reply-To: <2b00e566-112c-5657-c10f-7f210d3eae93@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Cc: Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, clang-built-linux@googlegroups.com, linux-kernel-mentees@lists.linuxfoundation.org



On Sat, 3 Oct 2020, Ujjwal Kumar wrote:

> This patch series aims at removing the dependency on execute=20
> bit of the scripts in the kbuild system.
>

Ujjwal, your setup to send out the patch series created three unrelated=20
emails rather than the default way, i.e., to have one cover letter=20
and the patches in reply to the cover letter.

You can see the difference here:

https://lore.kernel.org/linux-kbuild/

The presentation of your patch series looks different than the other=20
patch series on the list. Use the linux-kernel-mentees list for testing=20
your setup.

For this version of the patch series, I guess it is okay; but this set up=20
right for the next patch series.
=20
> If not working with fresh clone of linux-next, clean the srctree:
> make distclean
> make tools/clean
>

I hit an unrelated issue on next-20201002 that make tools/clean fails.
Other than that, this is all good.
=20
> To test the dependency on execute bits, I tried building the=20
> kernel after removing x-bits for all files in the repository.
> Removing execute bits:
> for i in $(find -executable -type f); do chmod -x $i; done
>

Okay, I did that.
=20
> Any attempts to configure (or build) the kernel fail because of=20
> 'Permission denied' on scripts with the following error:
> $ make allmodconfig
> sh: ./scripts/gcc-version.sh: Permission denied
> init/Kconfig:34: syntax error
> init/Kconfig:33: invalid statement
> init/Kconfig:34: invalid statement
> sh: ./scripts/ld-version.sh: Permission denied
> init/Kconfig:39: syntax error
> init/Kconfig:38: invalid statement
> sh: ./scripts/clang-version.sh: Permission denied
> init/Kconfig:49: syntax error
> init/Kconfig:48: invalid statement
> make[1]: *** [scripts/kconfig/Makefile:71: allmodconfig] Error 1
> make: *** [Makefile:606: allmodconfig] Error 2
>

I can confirm that these errors are reported on next-20201002.
=20
> Changes:
> 1. Adds specific interpreters (in Kconfig) to invoke=20
> scripts.
>=20
> After this patch I could successfully do a kernel build=20
> without any errors.
>

With this first patch, I could then successfully do:

make allmodconfig && make

So far, so good. I did check the first patch.

Lukas

> 2. Again, adds specific interpreters to other parts of=20
> kbuild system.
>=20
> I could successfully perform the following make targets after=20
> applying the PATCH 2/2:
> make headerdep
> make kselftest-merge
> make rpm-pkg
> make perf-tar-src-pkg
> make ARCH=3Dia64 defconfig
> ARCH=3Darm64 CROSS_COMPILE=AArch64-linux-gnu- make prepare
>=20
> Following changes in PATCH 2/2 are not yet tested:
> arch/arm64/kernel/vdso32/Makefile
> arch/nds32/kernel/vdso/Makefile
> scripts/Makefile.build
>=20
> Ujjwal Kumar (2):
>   kconfig: use interpreters to invoke scripts
>   kbuild: use interpreters to invoke scripts
>=20
>  Makefile                          |  4 ++--
>  arch/arm64/kernel/vdso/Makefile   |  2 +-
>  arch/arm64/kernel/vdso32/Makefile |  2 +-
>  arch/ia64/Makefile                |  4 ++--
>  arch/nds32/kernel/vdso/Makefile   |  2 +-
>  init/Kconfig                      | 16 ++++++++--------
>  scripts/Makefile.build            |  2 +-
>  scripts/Makefile.package          |  4 ++--
>  8 files changed, 18 insertions(+), 18 deletions(-)
>=20
> --=20
> 2.26.2
>=20
>=20
