From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 04 Jan 2022 15:48:00 +0000
Subject: [PATCH] ia64: topology: use default_groups in kobj_type
Message-Id: <20220104154800.1287947-1-gregkh@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, David Hildenbrand <david@redhat.com>, linux-ia64@vger.kernel.org

There are currently 2 ways to create a set of sysfs files for a
kobj_type, through the default_attrs field, and the default_groups
field.  Move the ia64 topology sysfs code to use default_groups field
which has been the preferred way since aa30f47cf666 ("kobject: Add
support for default attribute groups to kobj_type") so that we can soon
get rid of the obsolete default_attrs field.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/ia64/kernel/topology.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 3639e0a7cb3b..e4992917a24b 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -264,6 +264,7 @@ static struct attribute * cache_default_attrs[] = {
 	&shared_cpu_map.attr,
 	NULL
 };
+ATTRIBUTE_GROUPS(cache_default);
 
 #define to_object(k) container_of(k, struct cache_info, kobj)
 #define to_attr(a) container_of(a, struct cache_attr, attr)
@@ -284,7 +285,7 @@ static const struct sysfs_ops cache_sysfs_ops = {
 
 static struct kobj_type cache_ktype = {
 	.sysfs_ops	= &cache_sysfs_ops,
-	.default_attrs	= cache_default_attrs,
+	.default_groups	= cache_default_groups,
 };
 
 static struct kobj_type cache_ktype_percpu_entry = {
-- 
2.34.1
