From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Oct 2007 16:07:16 +0000
Subject: RE: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <617E1C2C70743745A92448908E030B2A02A2394E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You should have seen this printk:
>
>	printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);
>
> Can you verify that you saw that in your dmesg? I think the
> status should be -1, due to not-implemented.

Yes.  I see this message, and the status is indeed -1.

-Tony
