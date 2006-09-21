From: Horms <horms@verge.net.au>
Date: Thu, 21 Sep 2006 11:15:52 +0000
Subject: Re: [Fastboot] [Patch] Kexec-tools: Fix physcal address value in vmcore ELF	segment header
Message-Id: <20060921111550.GI18110@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 21, 2006 at 01:01:04PM +0800, Zou Nan hai wrote:
> 
> I used fixed 64M as physical offset in vmcore ELF segment header.
> This gives trouble to crash utility to analyze vmcore on platform that
> load kernel to a different address.
> 
> This patch will fix it.
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Thanks, 

I have merged this into kexec-tools-testing

Signed-off-by: Simon Horman <horms@verge.net.au>

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

