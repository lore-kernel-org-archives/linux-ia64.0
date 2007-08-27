From: Dean Nelson <dcn@sgi.com>
Date: Mon, 27 Aug 2007 16:02:48 +0000
Subject: [PATCH 3/4] add new lock ordering rule to mm/filemap.c
Message-Id: <20070827160247.GD25589@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827155622.GA25589@sgi.com>
In-Reply-To: <20070827155622.GA25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com

This patch adds a lock ordering rule to avoid a potential deadlock when
multiple mmap_sems need to be locked.

Signed-off-by: Dean Nelson <dcn@sgi.com>

Index: linux-2.6/mm/filemap.c
=================================--- linux-2.6.orig/mm/filemap.c	2007-08-09 19:18:15.000000000 -0500
+++ linux-2.6/mm/filemap.c	2007-08-27 09:13:47.435717670 -0500
@@ -78,6 +78,9 @@
  *  ->i_mutex			(generic_file_buffered_write)
  *    ->mmap_sem		(fault_in_pages_readable->do_page_fault)
  *
+ *    When taking multiple mmap_sems, one should lock the lowest-addressed
+ *    one first proceeding on up to the highest-addressed one.
+ *
  *  ->i_mutex
  *    ->i_alloc_sem             (various)
  *
