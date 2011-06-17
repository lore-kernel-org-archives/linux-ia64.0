From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 17 Jun 2011 15:13:12 +0000
Subject: Re: [PATCHv3-resend] atomic: add *_dec_not_zero
Message-Id: <201106171713.12983.arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1306653200-19176-1-git-send-email-sven@narfation.org> <1308307124-15659-1-git-send-email-sven@narfation.org>
In-Reply-To: <1308307124-15659-1-git-send-email-sven@narfation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Eckelmann <sven@narfation.org>
Cc: linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Friday 17 June 2011, Sven Eckelmann wrote:
> 
> Introduce an *_dec_not_zero operation.  Make this a special case of
> *_add_unless because batman-adv uses atomic_dec_not_zero in different
> places like re-broadcast queue or aggregation queue management. There
> are other non-final patches which may also want to use this macro.
> 
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Acked-by: Mike Frysinger <vapier@gentoo.org>
> Acked-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Acked-by: Ingo Molnar <mingo@elte.hu>
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
> Acked-by: David Howells <dhowells@redhat.com>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Matt Turner <mattst88@gmail.com>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Acked-by: Paul Mundt <lethal@linux-sh.org>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Acked-by: Hirokazu Takata <takata@linux-m32r.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-arch@vger.kernel.org
> ---
> Nothing changed - only added the Acked-by from Hirokazu Takata. That
> means that I am still waiting for ia64 and Arnd Bergmann (maybe he wants
> to merge it in his tree?).

Hmm, I didn't look at the first versions unfortunately. Remind me why we don't just
open-code the atomic_add_unless in batman-adv.

Since people apparently think that this patch is a good idea, I'll merge it in
the asm-generic tree once I understand why this is done.

	Arnd
