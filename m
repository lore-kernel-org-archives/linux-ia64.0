From: holt@sgi.com
Date: Thu, 21 Feb 2008 21:08:43 +0000
Subject: [Patch 1/3] Correct pernodesize calculation.
Message-Id: <20080221210842.883925564@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.242474093@attica.americas.sgi.com>
In-Reply-To: <20080213175520.242474093@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


A simple fix.  The existing pernodesize reservation is not taking into
account a second array of pg_data_t structures.  This is normally not
important because the PAGE_ALIGN macro reserves adequate space.

I made the compute_pernodesize steps in the same order as the fill_pernode
steps to make the correlation more clear.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: per_cpu_mca_v1/arch/ia64/mm/discontig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/discontig.c	2008-02-13 06:56:45.000000000 -0600
+++ per_cpu_mca_v1/arch/ia64/mm/discontig.c	2008-02-13 07:12:44.847819507 -0600
@@ -124,6 +124,7 @@ static unsigned long __meminit compute_p
 	pernodesize += node * L1_CACHE_BYTES;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize = PAGE_ALIGN(pernodesize);
 	return pernodesize;
 }

-- 
