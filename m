From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Nov 2007 16:26:59 +0000
Subject: RE: [PATCH] XPC heartbeat timer function must run on CPU 0
Message-Id: <617E1C2C70743745A92448908E030B2A02E2267E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
In-Reply-To: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Currently, XPC's heartbeat timer function runs on whatever CPU modprobe/insmod
> ran on when XPC was started. To avoid the heartbeat from being delayed for
> long periods the timer function must run on CPU 0.

Does Altix allow hot remove of cpu0?  If so, then you have a problem.

-Tony
