From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Tue, 07 Jul 2020 18:34:59 +0000
Subject: Re: [RFT PATCH] ia64: Fix build error with !COREDUMP
Message-Id: <20200707183459.GB3442@kozik-lap>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200604201842.29482-1-krzk@kernel.org>
In-Reply-To: <20200604201842.29482-1-krzk@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tom Vaden <tom.vaden@hpe.com>, Daisuke HATAYAMA <d.hatayama@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: kbuild-all@lists.01.org, Joerg Roedel <jroedel@suse.de>, stable@vger.kernel.org

On Thu, Jun 04, 2020 at 10:18:42PM +0200, Krzysztof Kozlowski wrote:
> Fix linkage error when CONFIG_BINFMT_ELF is selected but CONFIG_COREDUMP
> is not:
> 
>     ia64-linux-ld: arch/ia64/kernel/elfcore.o: in function `elf_core_write_extra_phdrs':
>     elfcore.c:(.text+0x172): undefined reference to `dump_emit'
>     ia64-linux-ld: arch/ia64/kernel/elfcore.o: in function `elf_core_write_extra_data':
>     elfcore.c:(.text+0x2b2): undefined reference to `dump_emit'
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 1fcccbac89f5 ("elf coredump: replace ELF_CORE_EXTRA_* macros by functions")
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>
> 
> ---
> 
> Please let kbuild test it for a while before applying. I built it only
> on few configurations.
> 
> This is similar fix to commit 42d91f612c87 ("um: Fix build error and
> kconfig for i386") although I put different fixes tag - the commit which
> introduced this part of code.

Kernel-test-robot did not complain anymore so I think build tests
passed.

Any comments here?

Best regards,
Krzysztof
