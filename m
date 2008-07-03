From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 03 Jul 2008 21:53:28 +0000
Subject: Re: [PATCH] xen: portability clean up and some minor clean up for
Message-Id: <486D4A58.60003@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080703071209.GD15683%yamahata@valinux.co.jp>
In-Reply-To: <20080703071209.GD15683%yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-ia64@vger.kernel.org, xen-devel@lists.xensource.com, xen-ia64-devel@lists.xensource.com, "Luck, Tony" <tony.luck@intel.com>

Isaku Yamahata wrote:
> clean up of xencomm.c. is_phys_contiguous() is arch dependent
> function that depends on how virtual memory are laid out.
> So split out the function into arch specific code.
>   

I suppose.  But given that ia64 is the only user of xencomm, I'm not too 
concerned about it.  And unless Arm uses it, I suspect it may always be 
the only user...

    J
