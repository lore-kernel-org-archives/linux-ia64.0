From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 03 Sep 2004 02:19:04 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040903021904.GK21873@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="4LFBTxd4L5NLO6ly"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--4LFBTxd4L5NLO6ly
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 02, 2004 at 11:42:43AM -0700, William Lee Irwin III wrote:
> This usage is valid too, of course. In this case we either need to adjust
> include/asm-ia64/page.h for virtual mem_map

Thanks to all the explanations I think I'm starting to understand all
these options; I'll try to document things a little more fully in our
WiKi soon (http://www.gelato.unsw.edu.au/IA64wiki if you've never seen
it).

I applied the following trivial patch and things seem to work now.
This way, pfn_to_page(0) returns 0xa0007fff... (the virtual mem map)
which I belive to be correct.

===== include/asm-ia64/page.h 1.26 vs edited =====
--- 1.26/include/asm-ia64/page.h        2004-07-27 15:26:50 +10:00
+++ edited/include/asm-ia64/page.h      2004-09-03 12:04:37 +10:00
@@ -84,6 +84,13 @@
 #endif

 #ifndef CONFIG_DISCONTIGMEM
+# ifdef CONFIG_VIRTUAL_MEM_MAP
+extern struct page *vmem_map;
+#  define pfn_valid(pfn)       (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+#  define page_to_pfn(page)    ((unsigned long) (page - vmem_map))
+#  define pfn_to_page(pfn)     (vmem_map + (pfn))
+# endif
+#else /* !CONFIG_VIRTUAL_MEM_MAP */
 #define pfn_valid(pfn)         (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 #define page_to_pfn(page)      ((unsigned long) (page - mem_map))
 #define pfn_to_page(pfn)       (mem_map + (pfn))

-i

--4LFBTxd4L5NLO6ly
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBN9SYWDlSU/gp6ecRAl9QAJ9JsVYcylmSrlZmFL59hbX41Ypc9gCfS5Bn
rdMVv8kSsU5GUwT0eNjReQM=
=oqcy
-----END PGP SIGNATURE-----

--4LFBTxd4L5NLO6ly--
