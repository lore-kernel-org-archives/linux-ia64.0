From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 21 Dec 2005 19:40:41 +0000
Subject: Re: [PATCH 1/4] msi archetecture init hook
Message-Id: <20051221194041.GG2361@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184342.5003.74247.39285@attica.americas.sgi.com>
In-Reply-To: <20051221184342.5003.74247.39285@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, Dec 21, 2005 at 12:42:36PM -0600, Mark Maule wrote:
> Index: msi/include/asm-sparc/msi.h
> =================================> --- msi.orig/include/asm-sparc/msi.h	2005-12-13 12:22:42.785246074 -0600
> +++ msi/include/asm-sparc/msi.h	2005-12-13 16:09:49.194541334 -0600
> @@ -28,4 +28,6 @@
>  			      "i" (ASI_M_CTL), "r" (MSI_ASYNC_MODE) : "g3");
>  }
>  
> +static inline int msi_arch_init(void)	{ return 0; }
> +
>  #endif /* !(_SPARC_MSI_H) */

Ah, look at the header for asm-sparc/msi.h:

 * msi.h:  Defines specific to the MBus - Sbus - Interface.

Not Message Signalled Interrupts at all ;-)
