From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Mar 2006 17:01:57 +0000
Subject: RE: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05DDC6FE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-	for_each_node(cnode) {
+	for (cnode = 0; cnode < num_cnodes; cnode++) {

Do we really need to fix "for_each_node()" ... having a macro
named this way that doesn't actually loop over all nodes looks
like an invitation to get things wrong in the future.

-Tony
