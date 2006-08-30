From: David Howells <dhowells@redhat.com>
Date: Wed, 30 Aug 2006 09:09:54 +0000
Subject: Re: [CFT:PATCH] Removing possible wrong asm/serial.h inclusions
Message-Id: <20539.1156928994@warthog.cambridge.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060828085244.GA13544@flint.arm.linux.org.uk> 
In-Reply-To: <20060828085244.GA13544@flint.arm.linux.org.uk> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-embedded@ozlabs.org, paulkf@microgate.com, takata@linux-m32r.org, linux-kernel@vger.kernel.org

Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> --- a/arch/frv/kernel/setup.c
> +++ b/arch/frv/kernel/setup.c
> @@ -31,7 +31,6 @@
>  #include <linux/serial_reg.h>
>  
>  #include <asm/setup.h>
> -#include <asm/serial.h>
>  #include <asm/irq.h>
>  #include <asm/sections.h>
>  #include <asm/pgalloc.h>

Acked-By: David Howells <dhowells@redhat.com>
