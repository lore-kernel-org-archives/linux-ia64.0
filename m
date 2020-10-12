From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 12 Oct 2020 16:18:34 +0000
Subject: Re: [PATCH RFC 0/2] use interpreters to invoke scripts
Message-Id: <CAK7LNAQwib66YwnMuN9qGQBs8dqqVaufOr9BqYMKfYUqiXu6jg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2b00e566-112c-5657-c10f-7f210d3eae93@gmail.com>
In-Reply-To: <2b00e566-112c-5657-c10f-7f210d3eae93@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Cc: Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, clang-built-linux <clang-built-linux@googlegroups.com>, linux-kernel-mentees@lists.linuxfoundation.org

On Sun, Oct 4, 2020 at 12:19 AM Ujjwal Kumar <ujjwalkumar0501@gmail.com> wr=
ote:
>
> This patch series aims at removing the dependency on execute
> bit of the scripts in the kbuild system.
>
> If not working with fresh clone of linux-next, clean the srctree:
> make distclean
> make tools/clean
>
> To test the dependency on execute bits, I tried building the
> kernel after removing x-bits for all files in the repository.
> Removing execute bits:
> for i in $(find -executable -type f); do chmod -x $i; done
>
> Any attempts to configure (or build) the kernel fail because of
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
> Changes:
> 1. Adds specific interpreters (in Kconfig) to invoke
> scripts.
>
> After this patch I could successfully do a kernel build
> without any errors.
>
> 2. Again, adds specific interpreters to other parts of
> kbuild system.
>
> I could successfully perform the following make targets after
> applying the PATCH 2/2:
> make headerdep
> make kselftest-merge
> make rpm-pkg
> make perf-tar-src-pkg
> make ARCH=3Dia64 defconfig
> ARCH=3Darm64 CROSS_COMPILE=AArch64-linux-gnu- make prepare
>
> Following changes in PATCH 2/2 are not yet tested:
> arch/arm64/kernel/vdso32/Makefile
> arch/nds32/kernel/vdso/Makefile
> scripts/Makefile.build
>
> Ujjwal Kumar (2):
>   kconfig: use interpreters to invoke scripts
>   kbuild: use interpreters to invoke scripts
>
>  Makefile                          |  4 ++--
>  arch/arm64/kernel/vdso/Makefile   |  2 +-
>  arch/arm64/kernel/vdso32/Makefile |  2 +-
>  arch/ia64/Makefile                |  4 ++--
>  arch/nds32/kernel/vdso/Makefile   |  2 +-
>  init/Kconfig                      | 16 ++++++++--------
>  scripts/Makefile.build            |  2 +-
>  scripts/Makefile.package          |  4 ++--
>  8 files changed, 18 insertions(+), 18 deletions(-)
>
> --
> 2.26.2
>


Andrew Morton suggested and applied the doc patch
(commit e9aae7af4601688386 in linux-next),
but did not pick up this series.

It is difficult to predict which patch he would
pick up, and which he would not.


I can apply this series
together with Lukas' base patch.


I pointed out possible mistakes in 2/2.
I can locally fix them up if you agree.


BTW, Kees Cook suggested dropping the x bit
from all scripts, but I did not agree with that part.


In the doc change, Lukas mentioned
"further clean-up patches", but I hope
it does not mean dropping the x bits.


--
Best Regards

Masahiro Yamada
