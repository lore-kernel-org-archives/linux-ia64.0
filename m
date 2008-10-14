From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Tue, 14 Oct 2008 22:42:46 +0000
Subject: Re: [PATCH 09/32] ia64/xen: add a necessary header file to compile
Message-Id: <48F52066.5040604@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> +++ b/arch/ia64/include/asm/pvclock-abi.h
> @@ -0,0 +1,5 @@
> +/*
> + * use same structure to x86's
> + * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
> + */
> +#include <asm-x86/pvclock-abi.h>
>
>
> I will trade out this patch for one that just makes
> a copy of the x86 include file.  This #include will
> break if/when x86 moves their include files to
> arch/x86/include/asm
>   

I think Ingo is planning it fairly soon.

    J
