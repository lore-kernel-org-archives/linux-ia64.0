From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 24 Jun 2017 09:41:42 +0000
Subject: Re: [PATCH 2/3] pci: Add a generic, weakly-linked pcibios_align_resource
Message-Id: <CAMuHMdWrn4C5nwRSrA8i_8sFtpRbuQH9vtNWjq5rM5_Si15kbw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170624015044.16746-1-palmer@dabbelt.com> <20170624015044.16746-3-palmer@dabbelt.com>
In-Reply-To: <20170624015044.16746-3-palmer@dabbelt.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>
Cc: linux-pci <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>, arcml <linux-snps-arc@lists.infradead.org>, Cris <linux-cris-kernel@axis.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>

Hi Palmer,

On Sat, Jun 24, 2017 at 3:50 AM, Palmer Dabbelt <palmer@dabbelt.com> wrote:
> Multiple architectures define this as trivial function, and I'm adding
> another one as part of the RISC-V port.  This adds a __weak version of
> pcibios_align_resource and deletes the now obselete ones in a handful of
> ports.
>
> The only functional change should be that a handful of ports used to
> export pcibios_fixup_bus.  Only some architectures export this, so I
> just dropped it.
>
> Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>

This function is only ever used as a pointer passed to
pci_bus_alloc_resource()?

What about having

    #ifndef pcibios_fixup_bus
    #define pcibios_fixup_bus NULL
    #endif

in asm-generic/pci.h, letting the architecture with a non-trivial
implementation predefine the preprocessor symbol, and teaching
pci_bus_alloc_resource() to handle NULL?

[...]

Oh, the latter eventually calls into allocate_resource(), which already falls
back to simple_align_resource() if the alignment function is NULL, which
does the same thing.
So NULL should already work.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
