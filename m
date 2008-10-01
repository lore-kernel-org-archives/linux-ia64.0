From: Fenghua Yu <fenghua.yu@intel.com>
Date: Wed, 01 Oct 2008 16:56:06 +0000
Subject: [PATCH 0/2]Add Variable Page Size and IA64 Support in Intel IOMMU
Message-Id: <20081001165606.GA21279@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org


The following two patches (Intel IOMMU generic patch and ia64 specific patch) together enable Intel IOMMU on IA64 platform. They are applied cleanly on the latest linux-next tree which contains Intel IOMMU interrupt remapping and VT-d driver KVM support code.

If applying only the generic patch on x86-64 kernel, x86-64 IOMMU is working fine, i.e. the generic patch doesn't have compilation and functionality impact on x86-64 IOMMU. If applying only the ia64 specific patch on ia64 kernel, ia64 is working as non-IOMMU/swiotlb case. If applying both of the patches and set CONFIG_DMAR=y, ia64 IOMMU is working.

Thanks.

-Fenghua
