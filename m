From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 03 Jul 2008 21:51:03 +0000
Subject: Re: [PATCH] xen: compilation fix for ia64 support.
Message-Id: <486D49C7.5070702@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080703070952.GB15683%yamahata@valinux.co.jp>
In-Reply-To: <20080703070952.GB15683%yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com, linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> don't include asm/pvclock-abi.h directly, but asm/xen/pvclock-abi.h
> At this moment linux ia64 won't accept asm/pvclock-abi.h because
> there's no user of it.

Huh?  Is this a ia64 maintainer policy?  Aren't you about to start using it?

>  Instead make it include asm/xen/pvclock-abi.h
> and create asm-x86/xen/pvclock-abi.h which includes asm-x86/pvclock-abi.h.
>   

I'm not very keen on crufting up asm-x86/xen/ for the ia64 code.  
Couldn't you have an asm-ia64/xen/pvclock-abi.h which includes 
<asm-x86/pvclock-abi.h>?

    J
