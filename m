From: Linus Walleij <linus.walleij@linaro.org>
Date: Wed, 03 May 2023 07:32:30 +0000
Subject: Re: [PATCH 0/7] Expect immutable pointer in virt_to_phys/isa_virt_to_bus prototypes
Message-Id: <CACRpkdYCZ0rya3hE+BRrHwP=fASjkpp_Y=BiC=WY-_z0yyRNEg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
In-Reply-To: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Stanislav Kinsburskii <skinsburskii@linux.microsoft.com>
Cc: Matt Turner <mattst88@gmail.com>, x86@kernel.org, Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>, Borislav Petkov <bp@alien8.de>, linux-ia64@vger.kernel.org, Mark Brown <broonie@kernel.org>, Richard Henderson <richard.henderson@linaro.org>, linux-kernel@vger.kernel.org, Brian Cain <bcain@quicinc.com>, linux-mips@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Omar Sandoval <osandov@fb.com>, Helge Deller <deller@gmx.de>, linuxppc-dev@lists.ozlabs.org, linux-hexagon@vger.kernel.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Florian Fainelli <f.fainelli@gmail.com>, Chris Down <chris@chrisdown.name>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Apr 27, 2023 at 7:41 PM Stanislav Kinsburskii
<skinsburskii@linux.microsoft.com> wrote:

> This series is aimed to address compilation warnings when a constant pointer
> is passed to virt_to_phys and isa_virt_to_bus functions:
>
>   warning: passing argument 1 of ‘virt_to_phys’ discards ‘const’ qualifier from pointer target type
>   warning: passing argument 1 of ‘isa_virt_to_bus’ discards ‘const’ qualifier from pointer target type
>
> The change(s) is the same for all architectures, but it's split into a series on
> per-arch basis to simplify applying and testing on the maintainers side.
>
> The following series implements...

This is nice.
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

I am working with an adjacent task, which is to make virt_to_pfn() and
pfn_to_virt() into static inlines. I might need to rebase my work on top
of this but it should be doable, I am currently stressing the buildbots
with this with the idea to propose it to Arnd once v6.4-rc1 is out:
https://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-integrator.git/log/?h=b4/virt-to-pfn-v6-4-rc1

Yours,
Linus Walleij
