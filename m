From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 02:35:43 +0000
Subject: [PATCH] flush icache before set_pte take6. [0/4]
Message-Id: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, Christoph Lameter <clameter@sgi.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

flush icache before set_pte() for ia64 patch set.

patches are against 2.6.23-rc1.

Changes:
  - Added "Is Montecito?" check for optimization.

Thanks,
-Kame

