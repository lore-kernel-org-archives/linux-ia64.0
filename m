From: Grant Grundler <iod00d@hp.com>
Date: Thu, 27 May 2004 18:53:23 +0000
Subject: Re: a elilo.conf question
Message-Id: <20040527185323.GD25564@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 27, 2004 at 02:21:52PM -0400, Younggyun Koh wrote:
> VFS:Cannot open root device "sda3" or unknown-block(0,0)
> Please append a currect "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)
> 
> (/dev/sda3 is mounted to / in the kernel 2.4)

While bjorn, stephane, and david could be right,
arch/ia64/defconfig and arch/ia64/configs/zx1_defconfig
has FUSION enabled by default as a built-in driver.
My advice is to start with zx1_defconfig and customize
that for your useage.

One parisc, I get bitten by /dev/sda getting renamed to something
else (eg /dev/sdi) everytime I switch between 2.4/2.6 kernels.
My solution of course is to only use 2.6 kernels. :^)

If no disks show up, then the Fusion driver is missing.
If you can find the disk with the "right" partition
layout in your 2.6 console boot output (before the panic),
then this is likely the problem. If that's the case,
don't forget to update /etc/fstab entries if they aren't
"mount by label" or are not using mdadm.

grant
