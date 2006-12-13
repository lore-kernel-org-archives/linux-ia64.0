From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 01:28:15 +0000
Subject: Re: [Fastboot] [PATCH] Do not call SN_SAL_SET_CPU_NUMBER twice on cpu 0
Message-Id: <20061213012812.GA22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 03:39:23PM -0800, Jay Lan wrote:
> This is an SN specific patch.
> 
> Architectually, cpu_init is always called twice on cpu 0
> and thus resulted in two SN_SAL_SET_CPU_NUMBER calls.
> 
> This was harmless in production kernel; however, it can
> cause problem on booting up a crashdump kernel at Altix.
> 
> Here is the patch that detects the second sn_cpu_init
> call and skips the second call to SN_SAL_SET_CPU_NUMBER.
> 
> Signed-Off-By: Jay Lan <jlan@sgi.com>

That looks fine to me.

Acked: Simon Horman <horms@verge.net.au>

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

