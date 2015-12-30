From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Dec 2015 16:39:48 +0000
Subject: RE: [PATCH 03/34] ia64: rename nop->iosapic_nop
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39F9CFDF@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451473761-30019-1-git-send-email-mst@redhat.com>
 <1451473761-30019-4-git-send-email-mst@redhat.com>
In-Reply-To: <1451473761-30019-4-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andrew Cooper <andrew.cooper3@citrix.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Rusty Russell <rusty@rustcorp.com.au>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> asm-generic/barrier.h defines a nop() macro.
> To be able to use this header on ia64, we shouldn't
> call local functions/variables nop().
>
> There's one instance where this breaks on ia64:
> rename the function to iosapic_nop to avoid the conflict.

Acked-by: Tony Luck <tony.luck@intel.com>

