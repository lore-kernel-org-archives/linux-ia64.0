From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jul 2007 17:40:47 +0000
Subject: RE: [PATCH take3 0/12] Support vector domain on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A01F27E30@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <469CB3FA.7010301@jp.fujitsu.com>
In-Reply-To: <469CB3FA.7010301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Getting close now.  New (I think it's new, I didn't notice it last time, but I may have
missed it in the other build noise)  concern while compiling this version was the warning:

  arch/ia64/kernel/iosapic.c:597: warning: 'iosapic_free_rte' defined but not used

This isn't spurious, the only call to iosapic_free_rte() has been removed, but there
is still a call to iosapic_alloc_rte() ... which means we must have a memory leak.

-Tony
