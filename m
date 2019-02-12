From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 12 Feb 2019 09:53:43 +0000
Subject: [PATCH 2/2] mm: be more verbose about zonelist initialization
Message-Id: <20190212095343.23315-3-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
In-Reply-To: <20190212095343.23315-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

We have seen several bugs where zonelists have not been initialized
properly and it is not really straightforward to track those bugs down.
One way to help a bit at least is to dump zonelists of each node when
they are (re)initialized.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e097f336126..c30d59f803fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5259,6 +5259,11 @@ static void build_zonelists(pg_data_t *pgdat)
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
+
+	pr_info("node[%d] zonelist: ", pgdat->node_id);
+	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
+		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
+	pr_cont("\n");
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
2.20.1
