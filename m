From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 28 Jul 2007 06:03:19 +0000
Subject: [PATCH] flush icache before set_pte() take 5.
Message-Id: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Zoltan.Menyhart@bull.net, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>

Appliled comments on take 4.
patches are against 2.6.23-rc1.

Changes:
  - changes flush_icache_page to be flush_cache_page() in remove_migration_pte().
  - removed sync_icache_dcahe() in page reuse case of do_wp_page(). 

Considerations:
  - I can add CONFIG_MONTECITO if necessary. But it will be confusing, I think.

Thanks,
-Kame

