From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Tue, 14 Jun 2016 08:54:44 +0000
Subject: [PATCH] [ACPI] Change structure initialisation to C99 style
Message-Id: <20160614084244.GA28854@amitoj-Inspiron-3542>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: julia.lawall@lip6.fr, michael.leibowitz@intel.com, keescook@chromium.org

Replace the in order struct initialisation style with explicit field
style.

The Coccinelle semantic patch used to make this change is as follows:

@decl@
identifier i1,fld;
type T;
field list[n] fs;
@@

struct i1 {
 fs
 T fld;
 ...};

@@
identifier decl.i1,i2,decl.fld;
expression e;
position bad.p, bad.fix;
@@

struct i1 i2@p = { ...,
+ .fld = e
- e@fix
 ,...};

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 arch/ia64/kernel/acpi-ext.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/acpi-ext.c b/arch/ia64/kernel/acpi-ext.c
index bd09bf7..31e331a 100644
--- a/arch/ia64/kernel/acpi-ext.c
+++ b/arch/ia64/kernel/acpi-ext.c
@@ -80,7 +80,7 @@ static acpi_status find_csr_space(struct acpi_resource *resource, void *data)
 
 static acpi_status hp_crs_locate(acpi_handle obj, u64 *base, u64 *length)
 {
-	struct csr_space space = { 0, 0 };
+	struct csr_space space = { .base = 0, .length = 0 };
 
 	acpi_walk_resources(obj, METHOD_NAME__CRS, find_csr_space, &space);
 	if (!space.length)
-- 
1.9.1

