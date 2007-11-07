From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Nov 2007 06:59:10 +0000
Subject: RE: [PATCH 1/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <617E1C2C70743745A92448908E030B2A02E22560@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BDC7.1070702@jp.fujitsu.com>
In-Reply-To: <4714BDC7.1070702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Now I'm preparing benchmarks...
> I suppose there is still room for improvement(i.e. Peter's hint).

We definitely need to reduce the overhead of this patch. David
Mosberger, Ken chen and others battled for every cycle to make
ia64 system calls fast ... so I'm not willing to add back 20
cycles in a single patch.

I did run the kernel some more today and noticed some odd "hangs".
Some processes seemed to get stuck for many seconds and then
continued again.  Didn't have time to try and track what was
happening.  Have you seem snything like this?

-Tony
