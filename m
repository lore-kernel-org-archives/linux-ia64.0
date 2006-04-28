From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Apr 2006 17:16:25 +0000
Subject: RE: [rfc] dynamic 3-level / 4-level page table
Message-Id: <4t153d$rpjna@azsmga001.ch.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4sur0l$s99mf@fmsmga001.fm.intel.com>
In-Reply-To: <4sur0l$s99mf@fmsmga001.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, April 28, 2006 1:58 AM
> Could you please describe how e.g. the VHPT miss handler works
> with the modification?
> Especially the "LOAD_PGD()" related operations.

LOAD_PGD() is a clone of pud_offset():

+#define pud_offset(dir,addr)	((pud_t *) (pgtbl3 ? (u64) (dir) : pgd_page(*(dir))) + \
+				(((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))

Except pgtbl3 condition is evaluated only once at boot time.
