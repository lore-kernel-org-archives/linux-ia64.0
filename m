From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 14 Nov 2011 20:50:10 +0000
Subject: Re: [PATCH 3/5] treewide: Remove useless NORET_TYPE macro and uses
Message-Id: <CAMuHMdXwjFphNNHc-OZXHaC4OP981x48hRuCdi3FjtPKh6YvHA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1320917551.git.joe@perches.com>
	<e69163f6245513b05d5d21c2f57b916931ad5bff.1320917557.git.joe@perches.com>
In-Reply-To: <e69163f6245513b05d5d21c2f57b916931ad5bff.1320917557.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org

On Thu, Nov 10, 2011 at 10:41, Joe Perches <joe@perches.com> wrote:
> It's a very old and now unused prototype marking
> so just delete it.
>
> Neaten panic pointer argument style to keep checkpatch quiet.
>
> Signed-off-by: Joe Perches <joe@perches.com>

For the m68k parts:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
