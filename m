From: Horms <horms@verge.net.au>
Date: Thu, 16 Nov 2006 06:23:41 +0000
Subject: Re: [Fastboot] [PATCH] kexec-tools: bug fix to --noio option
Message-Id: <20061116062340.GC23146@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 15, 2006 at 01:22:55PM -0800, Jay Lan wrote:
> This patch is to fix a "--noio option" patch posted on 9/20/2006 by
> Nanhai that disables I/O in purgatory code.
> 
> The "--noio" option should specify zero argument to avoid eating out
> the next option.
> 
> 
> Signed-off-by: Jay Lan <jlan@sgi.com>

Thanks. 

I have applied this patch to kexec-tools-testing

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

