From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 28 Aug 2007 08:44:27 +0000
Subject: Re: [RFC PATCH] clean up use of ia64 scripts
Message-Id: <8217.1188290667@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0708280030s850780jbb26b88f639b033e@mail.gmail.com>
In-Reply-To: <3877989d0708280030s850780jbb26b88f639b033e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luming Yu" (on Tue, 28 Aug 2007 15:30:50 +0800) wrote:
>Hello list,
>
>Ia64 seems to be the only one that use arch specific scripts to check
>tool chain bugs that create the dependency on ia64 tool chain which
>make the command:
>make ARCH=ia64 oldconfig  fail if ia64 cross tool chain is __not__
>installed or OBJDUMP and CC is __not__ set with cross tool path on a
>non-ia64 box.  Given the current state of art of tool chain, I don't
>know if these check are still useful. Please consider to remove it.
>
>Thanks,
>Luming
>
>clean up use of ia64 scripts
>
>Signed-off-by: Yu Luming <luming.yu@intel.com>
>
>---
> Makefile |   11 -----------
> 1 file changed, 11 deletions(-)
>
>diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
>index 21033ed..aaabf0e 100644
>--- a/arch/ia64/Makefile
>+++ b/arch/ia64/Makefile
>@@ -28,17 +28,6 @@ cflags-y     := -pipe $(EXTRA) -ffixed-r13 -
>                   -falign-functions2 -frename-registers
>-fno-optimize-sibling-calls
> CFLAGS_KERNEL  := -mconstant-gp

Your patch is text wrapped.

