From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jul 2007 22:38:39 +0000
Subject: RE: "Add support for vector domain" breaks boot on x355
Message-Id: <617E1C2C70743745A92448908E030B2A020E40A6@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070731221356.GA31324@us.ibm.com>
References: <20070731221356.GA31324@us.ibm.com>
In-Reply-To: <20070731221356.GA31324@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>, isimatu.yasuaki@jp.fujitsu.com
Cc: kaneshige.kenji@jp.fujitsu.com, torvalds@linux-foundation.org, ryhodges@us.ibm.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

> The following commit (4994be1b3fe9120c88022ff5c0c33f6312b17adb) broke
> Linus' Tree between 2.6.22-git15 and 2.6.22-git16 on a 2-node 8-way x455
> (Madison procs). Thanks to Ryan Hodges for bisecting down to this
> commit.

Thanks for taking the time to do the git bisect to identify the problem commit.

Can you give some more details on the breakage please?  Does the system
hang or panic?  How far does it get through the boot process?  Are there
any suspicious looking differences in the console output before getting
to the failure point?

-Tony
