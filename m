From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Feb 2005 20:00:20 +0000
Subject: Re: take5: vector sharing (Large I/O system support)
Message-Id: <16898.33492.606251.161178@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4201FC3A.40803@jp.fujitsu.com>
In-Reply-To: <4201FC3A.40803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After a quick glance over the patch:

 - There are several lines introduced with trailing whitespace (some
   of them long).  If you use emacs, you can get rid of them
   with delete-trailing-whitespace.  Please do so.

 - I'm not a fan of coding retry-loops with labels; I'd much rather
   have them be do/while-loops.  In this particular case:

+static struct iosapic_rte_info *iosapic_alloc_rte (void)
+{
+	int index;
+again:
+	/*
+	 * iosapic_alloc_rte might be called before kmalloc is initialized,
+	 * so several number of iosapic_rte_info structures needs to be
+	 * statically allocated.
+	 */
+	index = find_first_zero_bit(iosapic_rte_cache_mask, NR_RTE_CACHE_ENTRIES);
+	if (index < NR_RTE_CACHE_ENTRIES) {
+		if (test_and_set_bit(index, iosapic_rte_cache_mask))
+			goto again;
+		return iosapic_rte_cache + index;
+	}
+
+	return kmalloc(sizeof(struct iosapic_rte_info), GFP_ATOMIC);
+}

How does the kernel fail when we're running out of statically
allocated structures _before_ kmalloc() is initialized?  It better be
an obvious failure so one goes "oh, I better increase
NR_RTE_CACHE_ENTRIES" instead of having to debug a weird crash deep in
the allocator.

	--david
