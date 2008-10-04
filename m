From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Sat, 04 Oct 2008 14:17:53 +0000
Subject: RE: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8844A644A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com>
	 <200810020951.08408.bjorn.helgaas@hp.com>
	 <A6AD88C3F2289247BE726C37303E1EB88408AA3E@orsmsx505.amr.corp.intel.com>
	 <200810030941.42800.bjorn.helgaas@hp.com>
	 <A6AD88C3F2289247BE726C37303E1EB8844A6398@orsmsx505.amr.corp.intel.com>
 <1223100597.30832.37.camel@macbook.infradead.org>
In-Reply-To: <1223100597.30832.37.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> VT-d hardware supports both non cache coherency and cache coherency by
>> bit Coherency in Extended Capabilities Register.
>
>But is the version without the cache coherency actually going to be
>_seen_ on IA64?
>
Currently there is only one IA64 platform CraterLake supporting VT-d. Its BIOS sets cache coherency bit. But since there is no architecture spec saying cache coherency is required for all ia64 platforms, non cache coherency could be seen in future platforms having VT-d. And one VT-d architect explicitly tell me that ia64 Linux IOMMU needs to deal with non cache coherency case and flush cache line for non cache coherency case (just like x86-64 is doing).

>> Could you please point me to the doc that explicitly says that
>> architecturally ia64 doesn't need cache flush?
>
>For safety, we can always make the driver just refuse to initialise on
>IA64 if the cache coherency bit isn't set.

The current patch set works just fine for both cache coherency and non cache coherency. We don't need to abandon non cache coherency support on ia64 unless there is explicit spec claiming that non cache coherency is a requirement on all ia64 platforms.

Thanks.

-Fenghua
