From: Ingo Molnar <mingo@kernel.org>
Date: Thu, 18 Feb 2016 10:15:37 +0000
Subject: Re: [PATCH] signals, ia64, mips: update arch-specific siginfos with pkeys field
Message-Id: <20160218101537.GA5540@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160217181703.E99B6656@viggo.jf.intel.com>
In-Reply-To: <20160217181703.E99B6656@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org


* Dave Hansen <dave@sr71.net> wrote:

> 
> This fixes a compile error that Ingo was hitting with MIPS when the
> x86 pkeys patch set is applied.
> 
> ia64 and mips have separate definitions for siginfo from the
> generic one.  Patch them to have the pkey fields.
> 
> Note that this is exactly what we did for MPX as well.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: linux-mips@linux-mips.org
> Cc: linux-ia64@vger.kernel.org
> ---
> 
>  b/arch/ia64/include/uapi/asm/siginfo.h |   13 +++++++++----
>  b/arch/mips/include/uapi/asm/siginfo.h |   13 +++++++++----
>  2 files changed, 18 insertions(+), 8 deletions(-)

This solved the MIPS and IA64 build problems, but there's still one bug left: UML 
does not build:

 /home/mingo/tip/mm/gup.c: In function ‘check_vma_flags’:
 /home/mingo/tip/mm/gup.c:456:2: error: implicit declaration of function ‘arch_vma_access_permitted’ [-Werror=implicit-function-declaration]
   if (!arch_vma_access_permitted(vma, write, false, foreign))
 [...]

Please send a delta patch for this too.

Thanks,

	Ingo
