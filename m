From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 19 Mar 2021 14:54:29 +0000
Subject: Re: [PATCH RFC 2/3] mm: remove xlate_dev_kmem_ptr()
Message-Id: <CAMuHMdVP433iVhyaweDd8G6p3ZCgSDq6M_ACko_BTgm+5m0qnA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210319143452.25948-1-david@redhat.com> <20210319143452.25948-3-david@redhat.com>
In-Reply-To: <20210319143452.25948-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Brian Cain <bcain@codeaurora.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <krzk@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Mike Rapoport <rppt@kernel.org>, Palmer Dabbelt <palmerdabbelt@google.com>, Luis Chamberlain <mcgrof@kernel.org>, Greentime Hu <green.hu@gmail.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Gerald Schaefer <gerald.schaefer@linux.ibm.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Pierre Morel <pmorel@linux.ibm.com>, Ingo Molnar <mingo@kernel.org>, Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>

On Fri, Mar 19, 2021 at 3:36 PM David Hildenbrand <david@redhat.com> wrote:
> Since /dev/kmem has been removed, let's remove the xlate_dev_kmem_ptr()
> leftovers.

> Signed-off-by: David Hildenbrand <david@redhat.com>

>  arch/m68k/include/asm/io_mm.h   |  5 -----

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
