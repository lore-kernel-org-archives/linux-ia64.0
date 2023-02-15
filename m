From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 15 Feb 2023 15:15:47 +0000
Subject: Re: [RFC PATCH] MAINTAINERS: Mark Itanium/IA64 as 'dead'
Message-Id: <20230215151547.GA3766362@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230128122904.1345120-1-ardb@kernel.org>
In-Reply-To: <20230128122904.1345120-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Sat, Jan 28, 2023 at 01:29:04PM +0100, Ard Biesheuvel wrote:
> Create a new status 'dead' which conveys that a subsystem is
> unmaintained and scheduled for removal, and developers are free to
> behave as if it's already gone. Also, automated build tests should
> ignore such subsystems, or at least notify only those who are known to
> have an interest in the subsystem in particular.
> 
> Given that Itanium/IA64 has no maintainer, is no longer supported in
> QEMU (for boot testing under emulation) and does not seem to have a user
> base beyond a couple of machines used by distros to churn out packages,
> let's mark it as dead. This shall mean that any treewide changes (such
> as changes to the EFI subsystem, which I maintain) can be made even if
> they might cause build or boot time regressions on IA64 machines. Also,
> mark the port as scheduled for removal after the next LTS release.
> 

Since this just came up, I very much prefer complete removal. I don't
see the point of keeping dead code in the tree. That is still hidden
maintenance effort.

If this proliferates, we'll end up having to parse the MAINTAINERS file
for code marked "Dead" to ensure that we don't accidentally send e-mails
to the wrong people, or we risk getting complaints about sending reports
for such code. That puts extra burden on maintainers of automated test
beds, which I think is not really appropriate. If the code is dead,
remove it, period.

For my part, I'll drop my test bed support immediately after this patch
made it in, following the guidance above.

Guenter

> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Jessica Clarke <jrtc27@jrtc27.com>
> Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Marc Zyngier <maz@kernel.org>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: linux-ia64@vger.kernel.org
> Link: https://lore.kernel.org/all/CAMj1kXEqbMEcrKYzz2-huLPMnotPoxFY8adyH=Xb4Ex8o98x-w@mail.gmail.com/
> Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
> ---
>  MAINTAINERS | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5b74014994f5c1cc..5481967c2112e8ce 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -94,6 +94,14 @@ Descriptions of section entries and preferred order
>  	   Obsolete:	Old code. Something tagged obsolete generally means
>  			it has been replaced by a better system and you
>  			should be using that.
> +	   Dead:	Code has no maintainer and no significant user base,
> +			and is scheduled for removal. Developers are free to
> +			ignore it when it comes to testing bug fixes or other
> +			code changes, and automated build test systems must not
> +			report any detected issues, except possibly to mailing
> +			lists or other recipients that have opted in
> +			specifically to receiving reports about the state of
> +			this code.
>  	W: *Web-page* with status/info
>  	Q: *Patchwork* web based patch tracking system site
>  	B: URI for where to file *bugs*. A web-page with detailed bug
> @@ -9833,7 +9841,7 @@ F:	include/linux/i3c/
>  
>  IA64 (Itanium) PLATFORM
>  L:	linux-ia64@vger.kernel.org
> -S:	Orphan
> +S:	Dead # to be removed after the 2023 LTS release
>  F:	Documentation/ia64/
>  F:	arch/ia64/
>  
> -- 
> 2.39.0
> 
