From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Oct 2007 18:27:41 +0000
Subject: RE: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <617E1C2C70743745A92448908E030B2A029DBA6E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>	- expose "physical id" field, even on CPUs that are not
>	  multi-core / multi-threaded. Now we know what sockets
>	  Madisons live in too.

This sounds like a good idea.  But this patch didn't work for me
to achieve that on my HP 2620.  /proc/cpuinfo with this patch looks
like this:

processor  : 0
 ...
physical id: 4294967295

processor  : 1
 ...
physical id: 4294967295


So both my Madison cpus are apparently sharing the same socket!  That
big decimal number is just "-1" printed as an unsigned.


-Tony
