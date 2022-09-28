From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 21:04:09 +0000
Subject: Re: [PATCH v3 0/8] Unify <linux/export.h> and <asm/export.h>, remove EXPORT_DATA_SYMBOL(), faster TR
Message-Id: <CAK7LNATcD6k+R66YFVg_mhe7-FGNc0nYaTPuORCcd34Qw3ra2g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-1-masahiroy@kernel.org>
In-Reply-To: <20220928063947.299333-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Arnd Bergmann <arnd@arndb.de>, Luis Chamberlain <mcgrof@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, linux-modules@vger.kernel.org, llvm@lists.linux.dev

On Wed, Sep 28, 2022 at 3:41 PM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
>
> This patch set refactors EXPORT_SYMBOL, <linux/export.h> and <asm/export.h>.
> Also, re-implement TRIM_UNUSED_KSYMS in one-pass.
>
> You can still put EXPORT_SYMBOL() in *.S file, very close to the definition,
> but you do not need to care about whether it is a function or a data.
> Remove EXPORT_DATA_SYMBOL().
>
> In v1, I broke ia64 because of missing distinction between functions and data.
>
> V2 handles it correctly.
> If the exported symbols is a function, KSYMTAB_FUNC is output.
> Otherwise, KSYMTAB_DATA is output.
>



I noticed this patch set is broken in multiple ways.
No test is needed.
(0day may send various reports, but please ignore them)

I will fix the code when I have time.







Best Regards

Masahiro Yamada
