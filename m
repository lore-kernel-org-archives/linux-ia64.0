From: Richard Henderson <rth@twiddle.net>
Date: Fri, 08 Jan 2016 15:42:49 +0000
Subject: Re: [PATCH v2 2/6] alpha/extable: use generic search and sort routines
Message-Id: <568FD8F9.4050602@twiddle.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452007180-27411-1-git-send-email-ard.biesheuvel@linaro.org>
 <1452007180-27411-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1452007180-27411-3-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, akpm@linux-foundation.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, mingo@redhat.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de
Cc: deller@gmx.de, mark.rutland@arm.com

On 01/05/2016 07:19 AM, Ard Biesheuvel wrote:
> Replace the arch specific versions of search_extable() and sort_extable()
> with calls to the generic ones, which now support relative exception
> tables as well.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/alpha/include/asm/uaccess.h | 10 ++-
>  arch/alpha/mm/Makefile           |  2 +-
>  arch/alpha/mm/extable.c          | 92 --------------------
>  3 files changed, 9 insertions(+), 95 deletions(-)

Acked-by: Richard Henderson <rth@twiddle.net>


r~
