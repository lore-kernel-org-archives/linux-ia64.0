From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri, 06 Mar 2020 17:08:43 +0000
Subject: [PATCH v4 4/7] x86/mm: Introduce __set_memory_prot()
Message-Id: <20200306170846.9333-5-logang@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200306170846.9333-1-logang@deltatee.com>
In-Reply-To: <20200306170846.9333-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>

For use in the 32bit arch_add_memory() to set the pgprot type of the
memory to add.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/set_memory.h |  1 +
 arch/x86/mm/pat/set_memory.c      | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index 64c3dce374e5..034358da4837 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -34,6 +34,7 @@
  * The caller is required to take care of these.
  */
 
+int __set_memory_prot(unsigned long addr, int numpages, pgprot_t prot);
 int _set_memory_uc(unsigned long addr, int numpages);
 int _set_memory_wc(unsigned long addr, int numpages);
 int _set_memory_wt(unsigned long addr, int numpages);
diff --git a/arch/x86/mm/pat/set_memory.c b/arch/x86/mm/pat/set_memory.c
index c4aedd00c1ba..a7b14dffeb0b 100644
--- a/arch/x86/mm/pat/set_memory.c
+++ b/arch/x86/mm/pat/set_memory.c
@@ -1792,6 +1792,19 @@ static inline int cpa_clear_pages_array(struct page **pages, int numpages,
 		CPA_PAGES_ARRAY, pages);
 }
 
+/*
+ * _set_memory_prot is an internal helper for callers that have been passed
+ * a pgprot_t value from upper layers and a reservation has already been taken.
+ * If you want to set the pgprot to a specific page protocol, use the
+ * set_memory_xx() functions.
+ */
+int __set_memory_prot(unsigned long addr, int numpages, pgprot_t prot)
+{
+	return change_page_attr_set_clr(&addr, numpages, prot,
+					__pgprot(~pgprot_val(prot)), 0, 0,
+					NULL);
+}
+
 int _set_memory_uc(unsigned long addr, int numpages)
 {
 	/*
-- 
2.20.1
