From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 11 Jun 2022 18:51:08 +0000
Subject: Re: [PATCH 0/7] Unify <linux/export.h> and <asm/export.h>, remove EXPORT_DATA_SYMBOL()
Message-Id: <CAK7LNARDLgNDtneabZezc3GAcQ4tZJPyK5+yKqsSuXDb6f+jXA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610183236.1272216-1-masahiroy@kernel.org>
In-Reply-To: <20220610183236.1272216-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Nicolas Pitre <npitre@baylibre.com>, Luis Chamberlain <mcgrof@kernel.org>, linux-modules <linux-modules@vger.kernel.org>, Ard Biesheuvel <ardb@kernel.org>, Alessio Igor Bogani <abogani@kernel.org>, Andy Whitcroft <apw@canonical.com>, Arnd Bergmann <arnd@arndb.de>, Dwaipayan Ray <dwaipayanray1@gmail.com>, Joe Perches <joe@perches.com>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Jun 11, 2022 at 3:34 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
>
> This patch set refactors EXPORT_SYMBOL, <linux/export.h> and <asm/export.h>.
>
> You can still put EXPORT_SYMBOL() in *.S file, very close to the definition,
> but you do not need to care about whether it is a function or a data.
> Remove EXPORT_DATA_SYMBOL().
>


Sorry, please ignore this patch set.

With further testing for ia64,
I realized it was not working.





>
> Masahiro Yamada (7):
>   modpost: fix section mismatch check for exported init/exit sections
>   modpost: put get_secindex() call inside sec_name()
>   kbuild: generate struct kernel_symbol by modpost
>   ia64,export.h: replace EXPORT_DATA_SYMBOL* with EXPORT_SYMBOL*
>   checkpatch: warn if <asm/export.h> is included
>   modpost: merge sym_update_namespace() into sym_add_exported()
>   modpost: use null string instead of NULL pointer for default namespace
>
>  arch/ia64/include/asm/Kbuild    |   1 +
>  arch/ia64/include/asm/export.h  |   3 -
>  arch/ia64/kernel/head.S         |   2 +-
>  arch/ia64/kernel/ivt.S          |   2 +-
>  include/asm-generic/export.h    |  83 +------------------
>  include/linux/export-internal.h |  44 ++++++++++
>  include/linux/export.h          |  97 ++++++++--------------
>  kernel/module/internal.h        |  12 +++
>  kernel/module/main.c            |   1 -
>  scripts/Makefile.build          |   8 +-
>  scripts/check-local-export      |   4 +-
>  scripts/checkpatch.pl           |   7 ++
>  scripts/mod/modpost.c           | 139 +++++++++++++++++---------------
>  scripts/mod/modpost.h           |   1 +
>  14 files changed, 182 insertions(+), 222 deletions(-)
>  delete mode 100644 arch/ia64/include/asm/export.h
>
> --
> 2.32.0
>


-- 
Best Regards
Masahiro Yamada
