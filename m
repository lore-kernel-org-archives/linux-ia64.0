From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 08 Jul 2016 09:22:28 +0000
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Message-Id: <9920033.q6Ud9av8s4@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <3418914.byvl8Wuxlf@wuerfel> <CAGXu5jLyBfqXJKxohHiZgztRVrFyqwbta1W_Dw6KyyGM3LzshQ@mail.gmail.com>
In-Reply-To: <CAGXu5jLyBfqXJKxohHiZgztRVrFyqwbta1W_Dw6KyyGM3LzshQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, PaX Team <pageexec@freemail.hu>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Thursday, July 7, 2016 1:37:43 PM CEST Kees Cook wrote:
> >
> >> +     /* Allow kernel bss region (if not marked as Reserved). */
> >> +     if (ptr >= (const void *)__bss_start &&
> >> +         end <= (const void *)__bss_stop)
> >> +             return NULL;
> >
> > accesses to .data/.rodata/.bss are probably not performance critical,
> > so we could go further here and check the kallsyms table to ensure
> > that we are not spanning multiple symbols here.
> 
> Oh, interesting! Yeah, would you be willing to put together that patch
> and test it?

Not at the moment, sorry.

I've given it a closer look and unfortunately realized that kallsyms
today only covers .text and .init.text, so it's currently useless because
those sections are already disallowed.

We could extend kallsyms to also cover all other sections, but doing
that right will likely cause a number of problems (most likely
kallsyms size mismatch) that will have to be debugged first.\

I think it's doable but time-consuming. The check function should
actually be trivial:

static bool usercopy_spans_multiple_symbols(void *ptr, size_t len)
{
	unsigned long size, offset;	

	if (kallsyms_lookup_size_offset((unsigned long)ptr, &size, &offset))
		return 0; /* no symbol found or kallsyms disabled */

	if (size - offset <= len)
		return 0; /* range is within one symbol */

	return 1;
}

This part would also be trivial:

diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
index 1f22a186c18c..e0f37212e2a9 100644
--- a/scripts/kallsyms.c
+++ b/scripts/kallsyms.c
@@ -50,6 +50,11 @@ static struct addr_range text_ranges[] = {
 	{ "_sinittext", "_einittext" },
 	{ "_stext_l1",  "_etext_l1"  },	/* Blackfin on-chip L1 inst SRAM */
 	{ "_stext_l2",  "_etext_l2"  },	/* Blackfin on-chip L2 SRAM */
+#ifdef CONFIG_HARDENED_USERCOPY
+	{ "_sdata",	"_edata"     },
+	{ "__bss_start", "__bss_stop" },
+	{ "__start_rodata", "__end_rodata" },
+#endif
 };
 #define text_range_text     (&text_ranges[0])
 #define text_range_inittext (&text_ranges[1])

but I fear that if you actually try that, things start falling apart
in a big way, so I didn't try ;-)

> I wonder if there are any cases where there are
> legitimate usercopys across multiple symbols.

The only possible use case I can think of is for reading out the entire
kernel memory from /dev/kmem, but your other checks in here already
define that as illegitimate. On that subject, we probably want to
make CONFIG_DEVKMEM mutually exclusive with CONFIG_HARDENED_USERCOPY.

	Arnd
