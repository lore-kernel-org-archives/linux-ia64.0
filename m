From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2012 00:24:49 +0000
Subject: RE: [PATCH] [IA64] disable interrupts when exiting from ia64_mca_cmc_int_handler()
Message-Id: <3908561D78D1C84285E8C5FCA982C28F0398CE@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LNX.2.00.1202081530510.24127@pobox.suse.cz>
In-Reply-To: <alpine.LNX.2.00.1202081530510.24127@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Raymund Will <rw@suse.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Disable the interrupts again before exiting. This is analogous to 
> a3967685745 ("[IA64] disable interrupts at end of 
> ia64_mca_cpe_int_handler()").

Thanks. Applied. Should show up in linux-next in a day or two, and
I'll send to Linus in next merge window.

-Tony
