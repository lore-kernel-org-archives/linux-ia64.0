From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 14 Jun 2002 03:12:53 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


+/*
+ * Note: the MAP_NR_*() macro can't use __pa() because MAP_NR_*(X) MUST
+ * map to something >= max_mapnr if X is outside the identity mapped
+ * kernel space.
+ */
+
+/*
+ * The dense variant can be used as long as the size of memory holes isn't
+ * very big.
+ */
+#define MAP_NR_DENSE(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_SHIFT)
+

Bjorn,
	Given that the only current use of MAP_NR_DENSE is in
machvec.c: map_nr_dense() why not open-code it there, instead of using
the MACRO?  (So
   unsigned long
   map_nr_dense(unsigned long addr) {
	return (addr - PAGE_OFFSET) >> PAGE_SHIFT;
    }
)

And move the comment there too instead of in page.h.
It might make things a little cleaner that way.

Peter C

