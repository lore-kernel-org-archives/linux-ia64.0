From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 27 May 2004 18:33:06 +0000
Subject: Re: a elilo.conf question
Message-Id: <200405271233.06520.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 27 May 2004 12:21 pm, Younggyun Koh wrote:
> VFS:Cannot open root device "sda3" or unknown-block(0,0)
> Please append a currect "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)
> ...
> the itanium 2 machine i'm using is hp zx6000

You probably don't have the right driver built in.  For zx6000, you
need the Fusion MPT driver, i.e.:

	CONFIG_FUSION=y

in your .config file.  Also make sure you have the correct filesystem(s)
built in (ext2 and/or ext3).
