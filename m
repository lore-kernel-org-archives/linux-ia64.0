From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Thu, 09 Jul 2009 00:01:06 +0000
Subject: RE: ftrace and lockdep on ia64?
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B06227F0@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0907072251w202d4ba6vbf0ece63d2d88a8f@mail.gmail.com>
In-Reply-To: <3877989d0907072251w202d4ba6vbf0ece63d2d88a8f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Does anyone have boot problem with upstream kernel on ia64 box?

Without IOMMU, upstream kernel boots fine on ia64 box. Upstream kernel has some regression issue on ia64 if IOMMU is enabled.

Thanks.

-Fenghua
