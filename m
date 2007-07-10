From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 10 Jul 2007 23:36:50 +0000
Subject: RE: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A01E2D9BC@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46779036.5050602@jp.fujitsu.com>
In-Reply-To: <46779036.5050602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This seems to be an intermittent problem.

One more note on that ... my test system often kicks out some

"Unexpected irq vector 0x13 on CPU xx!"

messages as it boots.  Looking at the logs of previous boots, I see between
zero and two such messages in the last few dozen boots,  When the
kernel with the vector-domain patch applied successfully booted this
morning, this was one of the times where there were no unexpected
interrupts.

Since the crash looks like it occurred while dereferencing the "desc = irq_desq + irq"
in generic_handle_irq(), I think this is most likely related.

-Tony
