From: Horms <horms@verge.net.au>
Date: Tue, 06 Mar 2007 01:56:55 +0000
Subject: Crash Dump Region
Message-Id: <20070306015655.GA27129@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am currently looking over the code that places the crashdump
region into /proc/iomem, and the code that determines its base
address if it is not passed on the kernel comamnd. It seems to me that 
the current code allows the crashkernel to be placed incide a
/proc/iomem region of any type. Is this behaviour correct?
If not, should it be restricted to "System RAM" regions?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

