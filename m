From: Horms <horms@verge.net.au>
Date: Thu, 01 Mar 2007 04:22:27 +0000
Subject: Re: [Fastboot] [PATCH 1/1] - platform_kernel_launch_event is noop on generic kernel
Message-Id: <20070301042227.GO6479@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070228194517.25635.98535.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20070228194517.25635.98535.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: fastboot@lists.osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 28, 2007 at 01:45:17PM -0600, John Keller wrote:
> Add a missing #define for the platform_kernel_launch_event.
> Without this fix, a call to platform_kernel_launch_event()
> becomes a noop on generic kernels. SN systems require this
> fix to successfully kdump/kexec from certain hardware errors.
>
> Signed-off-by: John Keller <jpk@sgi.com>

I made a similar change when porting to xen, but I hadn't thought
to see if mainline linux needs it to.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

