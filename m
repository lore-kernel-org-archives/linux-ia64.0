From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 08 Jan 2011 00:32:02 +0000
Subject: RE: 2.6.37 compile failure on IA64: NODE_DATA
Message-Id: <987664A83D2D224EAE907B061CE93D530194010771@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.SOC.1.00.1101071731100.21434@math.ut.ee>
In-Reply-To: <alpine.SOC.1.00.1101071731100.21434@math.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Meelis Roos <mroos@linux.ee>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>

> This is my first try at compiling my own machine-specific kernels for 
> IA64 and I stepped on a bug at once (but I have no ide if this 
> configuration worked before). It seems that since NEED_MULTIPLE_NODES is 
> set to y, NODE_DATA should be defined in asm/mmzone.h but isn't.

There may be many corner cases where you can create .config
files that do not build on ia64 (on x86 people regularly
generate random config files and then fix Kconfig dependencies
that allow impossible permutations - but nobody is doing that
for ia64).

Unless you have a particular attachment to the config
file you used, you might be better off starting from
arch/ia64/configs/generic_defconfig ... which is known
to build, and should boot on most machines.

-Tony
