From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Mon, 06 Oct 2008 19:44:29 +0000
Subject: RE: [PATCH 0/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8844A6B45@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165606.GA21279@linux-os.sc.intel.com>
 <200810030950.19359.bjorn.helgaas@hp.com>
In-Reply-To: <200810030950.19359.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> The following two patches (Intel IOMMU generic patch and ia64 specific

>the fact that the DMAR table is static precludes any sort of hot-plug
>to add or remove IOMMUs.

The latest VT-d spec v1.1 does not support hot plug. If the feature is available in newer spec, we will support it.

Thanks.

-Fenghua
