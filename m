From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 Nov 2003 06:34:19 +0000
Subject: Incorrect definition of pal cache_check info
Message-Id: <marc-linux-ia64-106801411302949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Both 2.4 and 2.6 kernels define struct pal_cache_check_info_s as

typedef struct pal_cache_check_info_s {
   u64	reserved1       : 16,
	way             : 5,    /* Way in which the
				 * error occurred
				 */
	reserved2       : 1,
	mc              : 1,    /* Machine check corrected */
	tv              : 1,    /* Target address
				 * structure is valid
				 */

	wv              : 1,    /* Way field valid */
	op              : 3,    /* Type of cache
				 * operation that
				 * caused the machine
				 * check.
				 */

	dl              : 1,    /* Failure in data part
				 * of cache line
				 */
	tl              : 1,    /* Failure in tag part
				 * of cache line
				 */
	dc              : 1,    /* Failure in dcache */
	ic              : 1,    /* Failure in icache */
	index           : 24,   /* Cache line index */
	mv              : 1,    /* mesi valid */
	mesi            : 3,    /* Cache line state */
	level           : 4;    /* Cache level */
} pal_cache_check_info_t;

which bears very little resemblance to the Cache_Check layout described
in Intel Itanium Architecture Software Developer's Manual Volume 2:
System Architecture, under PAL_MC_ERROR_INFO.  It looks like struct
pal_tlb_check_info_s is wrong as well.  What gives?

