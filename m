From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 21 Jun 2007 18:24:41 +0000
Subject: [IA64] [kdump] machveg=dig on hpzx1 platforms
Message-Id: <20070621182441.GA21840@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Terry Loftin <terry.loftin@hp.com>, Khalid Aziz <khalid_aziz@hp.com>

Hello,

on most HP machines, the 'machveg=dig' parameter is needed for the
kdump kernel to avoid problems with the HP ioc. In the original kdump
patches, a function ioc_iova_disable() was used, which (as I
understand) disabled the IOC before executing the new kernel. However,
that function wasn't added to mainline [2].

However, with a 2.6.22-rc kernel, booting into the kdump kernel works
surprisingly. I haven't found a fix in the git history that could be
responsible. Was there a fix? Or is it just a random result on a
machine I tested that it works?

Are there any plans to bring back ioc_iova_disable(), or would some
automatic kernel code that uses machvec=dig in the kernel without
forcing the user to pass an additional command line work?



Thanks,
   Bernhard

[1] http://article.gmane.org/gmane.linux.ports.ia64/15192
[2] http://article.gmane.org/gmane.linux.ports.ia64/15147

