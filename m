From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Dec 2015 16:41:22 +0000
Subject: RE: [PATCH 04/34] ia64: reuse asm-generic/barrier.h
Message-Id: <3908561D78D1C84285E8C5FCA982C28F39F9D044@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451473761-30019-1-git-send-email-mst@redhat.com>
 <1451473761-30019-5-git-send-email-mst@redhat.com>
In-Reply-To: <1451473761-30019-5-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andrew Cooper <andrew.cooper3@citrix.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Ingo Molnar <mingo@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrey Konovalov <andreyknvl@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> On ia64 smp_rmb, smp_wmb, read_barrier_depends, smp_read_barrier_depends
> and smp_store_mb() match the asm-generic variants exactly. Drop the
> local definitions and pull in asm-generic/barrier.h instead.
>
> This is in preparation to refactoring this code area.

Acked-by: Tony Luck <tony.luck@intel.com>

