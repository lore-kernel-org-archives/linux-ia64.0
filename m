From: Jessica Yu <jeyu@kernel.org>
Date: Sat, 19 Sep 2020 10:26:01 +0000
Subject: Re: [PATCH v2] kbuild: preprocess module linker script
Message-Id: <20200919102601.GA22693@linux-8ccs>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908042708.2511528-1-masahiroy@kernel.org>
In-Reply-To: <20200908042708.2511528-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: linux-kbuild@vger.kernel.org, Will Deacon <will@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Jeff Dike <jdike@addtoit.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Marek <michal.lkml@markovi.net>, Palmer Dabbelt <palmer@dabbelt.com>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-riscv@lists.infradead.org, linux-um@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

+++ Masahiro Yamada [08/09/20 13:27 +0900]:
>There was a request to preprocess the module linker script like we
>do for the vmlinux one. (https://lkml.org/lkml/2020/8/21/512)
>
>The difference between vmlinux.lds and module.lds is that the latter
>is needed for external module builds, thus must be cleaned up by
>'make mrproper' instead of 'make clean'. Also, it must be created
>by 'make modules_prepare'.
>
>You cannot put it in arch/$(SRCARCH)/kernel/, which is cleaned up by
>'make clean'. I moved arch/$(SRCARCH)/kernel/module.lds to
>arch/$(SRCARCH)/include/asm/module.lds.h, which is included from
>scripts/module.lds.S.
>
>scripts/module.lds is fine because 'make clean' keeps all the
>build artifacts under scripts/.
>
>You can add arch-specific sections in <asm/module.lds.h>.
>
>Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
>Tested-by: Jessica Yu <jeyu@kernel.org>
>Acked-by: Will Deacon <will@kernel.org>

Acked-by: Jessica Yu <jeyu@kernel.org>

Thanks for working on this! 
