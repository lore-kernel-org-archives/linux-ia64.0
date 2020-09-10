From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Sep 2020 19:45:44 +0000
Subject: Re: [PATCH] kbuild: preprocess module linker script
Message-Id: <202009101245.493610D05@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200904133122.133071-1-masahiroy@kernel.org>
In-Reply-To: <20200904133122.133071-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: linux-kbuild@vger.kernel.org, linux-ia64@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Paul Mackerras <paulus@samba.org>, linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>, Ard Biesheuvel <ardb@kernel.org>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, linux-arch@vger.kernel.org, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fenghua Yu <fenghua.yu@intel.com>, Albert Ou <aou@eecs.berkeley.edu>, Arnd Bergmann <arnd@arndb.de>, Jeff Dike <jdike@addtoit.com>, Jessica Yu <jeyu@kernel.org>, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Tony Luck <tony.luck@intel.com>, Paul Walmsley <paul.walmsley@sifive.com>, linux-arm-kernel@lists.infradead.org, Michal Marek <michal.lkml@markovi.net>, linux-kernel@vger.kernel.org, Palmer Dabbelt <palmer@dabbelt.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org

On Fri, Sep 04, 2020 at 10:31:21PM +0900, Masahiro Yamada wrote:
> There was a request to preprocess the module linker script like we do
> for the vmlinux one (https://lkml.org/lkml/2020/8/21/512).
> 
> The difference between vmlinux.lds and module.lds is that the latter
> is needed for external module builds, thus must be cleaned up by
> 'make mrproper' instead of 'make clean' (also, it must be created by
> 'make modules_prepare').
> 
> You cannot put it in arch/*/kernel/ because 'make clean' descends into
> it. I moved arch/*/kernel/module.lds to arch/*/include/asm/module.lds.h,
> which is included from scripts/module.lds.S.
> 
> scripts/module.lds is fine because 'make clean' keeps all the build
> artifacts under scripts/.
> 
> You can add arch-specific sections in <asm/module.lds.h>.
> 
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
