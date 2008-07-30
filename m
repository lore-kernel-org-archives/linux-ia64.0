From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Jul 2008 17:53:12 +0000
Subject: RE: Anyone tested 2.6.27-rc1?
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30823A093@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080730063731.GA31304@parisc-linux.org>
In-Reply-To: <20080730063731.GA31304@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Just to confirm ... 2.6.26 with the zx1_defconfig boots fine ... so it's
> something in the 8111 2.6.27 commits that breaks it.

I have 2.6.27-rc1 [with 1 patch from linux-next to fix cpumask_of_cpu()
so that my ancient compiler won't bomb out with build errors] running
on Intel tiger (using tiger_defconfig) and HP rx2620 (using zx1_defconfig).

-Tony
