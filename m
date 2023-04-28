From: "Arnd Bergmann" <arnd@arndb.de>
Date: Fri, 28 Apr 2023 07:40:51 +0000
Subject: Re: [PATCH 0/7] Expect immutable pointer in virt_to_phys/isa_virt_to_bus prototypes
Message-Id: <52dd950a-e714-4ebe-a663-4e0ec6463d03@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
In-Reply-To: <168155718437.13678.714141668943813263.stgit@skinsburskii.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Stanislav Kinsburskii <skinsburskii@linux.microsoft.com>
Cc: linux-ia64@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jiaxun Yang <jiaxun.yang@flygoat.com>, linux-mips@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-hexagon@vger.kernel.org, Omar Sandoval <osandov@fb.com>, Linux-Arch <linux-arch@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Helge Deller <deller@gmx.de>, x86@kernel.org, Stanislav Kinsburskii <stanislav.kinsburskii@gmail.com>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Matt Turner <mattst88@gmail.com>, Richard Henderson <richard.henderson@linaro.org>, Nicholas Piggin <npiggin@gmail.com>, Mark Brown <broonie@kernel.org>, Borislav Petkov <bp@alien8.de>, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Brian Cain <bcain@quicinc.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Chris Down <chris@chrisdown.name>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Sat, Apr 15, 2023, at 12:17, Stanislav Kinsburskii wrote:
> This series is aimed to address compilation warnings when a constant pointer
> is passed to virt_to_phys and isa_virt_to_bus functions:
>
>   warning: passing argument 1 of ‘virt_to_phys’ discards ‘const’ 
> qualifier from pointer target type
>   warning: passing argument 1 of ‘isa_virt_to_bus’ discards ‘const’ 
> qualifier from pointer target type
>
> The change(s) is the same for all architectures, but it's split into a series on
> per-arch basis to simplify applying and testing on the maintainers side.
>

Looks all good to me. If everyone is happy with it, I'll queue it up
after in the asm-generic tree for 6.5, once rc1 is out.

 Arnd
