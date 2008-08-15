From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Aug 2008 17:20:03 +0000
Subject: Pondering machvec ... was: [Patch] Remove sn2_defconfig.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    Not really a patch as much as a remove this file request.  Now that
>    generic_defconfig supports all the configurations SGI currently supports
>    and has NR_CPUS and NR_NODES at our largest configurations, we have no
>    reason to maintain the extra defconfig file.

I'm wondering whether we really want to do this ... and in turn wondering
about the value of the "generic" vs. system specific config files and the
whole machvec mechanism.

If the config files is removed, then the occasional breakage that it
finds will go unseen.  How much does this matter?  Not having it would
speed by regression build sequence (sn2 takes the longest of all the
builds I do).

I primarily test tiger_defconfig kernels on Intel systems and zx1_defconfig
kernels on HP systems ... with just the occasional boot test of a
generic_defconfig kernel to make sure it hasn't been severely broken.

Most end users are using distribution kernels ... which are based on
generic kernels because distributors don't want to maintain a slew of
separate binaries.

Now there are possibly some performance benefits from using a platform
specific kernel (reduced cpu usage because the indirection through
machvec is eliminated, plus reduced memory footprint for the kernel).
Has anyone ever tried to measure these?  Are they worth the extra
maintenance and testing needed to keep machvec alive?

-Tony
