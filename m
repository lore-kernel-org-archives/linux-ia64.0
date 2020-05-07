From: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Date: Thu, 07 May 2020 18:53:34 +0000
Subject: [PATCH] treewide: Replace zero-length array with flexible-array
Message-Id: <20200507185334.GA14456@embeddedor>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The current codebase makes use of the zero-length array language
extension to the C90 standard, but the preferred mechanism to declare
variable-length types such as these ones is a flexible array member[1][2],
introduced in C99:

struct foo {
        int stuff;
        struct boo array[];
};

By making use of the mechanism above, we will get a compiler warning
in case the flexible array does not occur last in the structure, which
will help us prevent some kind of undefined behavior bugs from being
inadvertently introduced[3] to the codebase from now on.

Also, notice that, dynamic memory allocations won't be affected by
this change:

"Flexible array members have incomplete type, and so the sizeof operator
may not be applied. As a quirk of the original implementation of
zero-length arrays, sizeof evaluates to zero."[1]

sizeof(flexible-array-member) triggers a warning because flexible array
members have incomplete type[1]. There are some instances of code in
which the sizeof operator is being incorrectly/erroneously applied to
zero-length arrays and the result is zero. Such instances may be hiding
some bugs. So, this work (flexible-array member conversions) will also
help to get completely rid of those sorts of issues.

This issue was found with the help of Coccinelle.

[1] https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
[2] https://github.com/KSPP/linux/issues/21
[3] commit 76497732932f ("cxgb3/l2t: Fix undefined behaviour")

Signed-off-by: Gustavo A. R. Silva <gustavoars@kernel.org>
---
 arch/ia64/kernel/unwind_i.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/unwind_i.h b/arch/ia64/kernel/unwind_i.h
index 67994a7e5816..1dd57ba44327 100644
--- a/arch/ia64/kernel/unwind_i.h
+++ b/arch/ia64/kernel/unwind_i.h
@@ -42,7 +42,7 @@ enum unw_register_index {
 
 struct unw_info_block {
 	u64 header;
-	u64 desc[0];		/* unwind descriptors */
+	u64 desc[];		/* unwind descriptors */
 	/* personality routine and language-specific data follow behind descriptors */
 };
 
