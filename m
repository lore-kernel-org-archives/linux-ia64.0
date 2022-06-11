From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 11 Jun 2022 18:49:09 +0000
Subject: Re: [PATCH 4/7] ia64,export.h: replace EXPORT_DATA_SYMBOL* with EXPORT_SYMBOL*
Message-Id: <CAK7LNATb0QsqkY3CZqrBcg3eLTc1pWuKK+M6WbadzuTvdK6GeQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610183236.1272216-1-masahiroy@kernel.org> <20220610183236.1272216-5-masahiroy@kernel.org>
In-Reply-To: <20220610183236.1272216-5-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Nicolas Pitre <npitre@baylibre.com>, Luis Chamberlain <mcgrof@kernel.org>, linux-modules <linux-modules@vger.kernel.org>, Ard Biesheuvel <ardb@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Jun 11, 2022 at 3:33 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> With the previous refactoring, you no longer need to know whether the
> exported symbol is a function or a data.
>
> Replace two instances in ia64, then remove EXPORT_DATA_SYMBOL*.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Please ignore this patch.

The previous refactoring is not working correctly.





-- 
Best Regards
Masahiro Yamada
