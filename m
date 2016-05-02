From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 02 May 2016 20:28:34 +0000
Subject: RE: [PATCH] ia64: Remove superfluous SMP function call
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A0BB160@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462189754-66482-1-git-send-email-anna-maria@linutronix.de>
In-Reply-To: <1462189754-66482-1-git-send-email-anna-maria@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anna-Maria Gleixner <anna-maria@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "rt@linutronix.de" <rt@linutronix.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Replace smp_call_function_single() with a direct call to
> ia64_mca_cmc_vector_adjust(). The function itselfs handles disable and
> enable interrupts, therefore the smp_call_function_single() calling
> convention is not preserved.

Applied. Thanks.

-Tony
