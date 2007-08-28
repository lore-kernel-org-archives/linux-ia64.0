From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 28 Aug 2007 07:30:50 +0000
Subject: [RFC PATCH] clean up use of ia64 scripts
Message-Id: <3877989d0708280030s850780jbb26b88f639b033e@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_95393_6201657.1188286250559"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_95393_6201657.1188286250559
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list,

Ia64 seems to be the only one that use arch specific scripts to check
tool chain bugs that create the dependency on ia64 tool chain which
make the command:
make ARCH=ia64 oldconfig  fail if ia64 cross tool chain is __not__
installed or OBJDUMP and CC is __not__ set with cross tool path on a
non-ia64 box.  Given the current state of art of tool chain, I don't
know if these check are still useful. Please consider to remove it.

Thanks,
Luming

clean up use of ia64 scripts

Signed-off-by: Yu Luming <luming.yu@intel.com>

---
 Makefile |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 21033ed..aaabf0e 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -28,17 +28,6 @@ cflags-y     := -pipe $(EXTRA) -ffixed-r13 -
                   -falign-functions=32 -frename-registers
-fno-optimize-sibling-calls
 CFLAGS_KERNEL  := -mconstant-gp

-GAS_STATUS     = $(shell $(srctree)/arch/ia64/scripts/check-gas
"$(CC)" "$(OBJDUMP)")
-CPPFLAGS += $(shell $(srctree)/arch/ia64/scripts/toolchain-flags
"$(CC)" "$(OBJDUMP)" "$(READELF)")
-
-ifeq ($(GAS_STATUS),buggy)
-$(error Sorry, you need a newer version of the assember, one that is
built from        \
-       a source-tree that post-dates 18-Dec-2002.  You can find a
pre-compiled \
-       static binary of such an assembler at:
         \
-
         \
-               ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
-endif
-
 ifeq ($(call cc-version),0304)
        cflags-$(CONFIG_ITANIUM)        += -mtune=merced
        cflags-$(CONFIG_MCKINLEY)       += -mtune=mckinley

------=_Part_95393_6201657.1188286250559
Content-Type: application/octet-stream; name=rpmbuild-bp.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f5w2o8sf
Content-Disposition: attachment; filename="rpmbuild-bp.patch"

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9NYWtlZmlsZSBiL2FyY2gvaWE2NC9NYWtlZmlsZQppbmRl
eCAyMTAzM2VkLi5hYWFiZjBlIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQvTWFrZWZpbGUKKysrIGIv
YXJjaC9pYTY0L01ha2VmaWxlCkBAIC0yOCwxNyArMjgsNiBAQCBjZmxhZ3MteQk6PSAtcGlwZSAk
KEVYVFJBKSAtZmZpeGVkLXIxMyAtCiAJCSAgIC1mYWxpZ24tZnVuY3Rpb25zPTMyIC1mcmVuYW1l
LXJlZ2lzdGVycyAtZm5vLW9wdGltaXplLXNpYmxpbmctY2FsbHMKIENGTEFHU19LRVJORUwJOj0g
LW1jb25zdGFudC1ncAogCi1HQVNfU1RBVFVTCT0gJChzaGVsbCAkKHNyY3RyZWUpL2FyY2gvaWE2
NC9zY3JpcHRzL2NoZWNrLWdhcyAiJChDQykiICIkKE9CSkRVTVApIikKLUNQUEZMQUdTICs9ICQo
c2hlbGwgJChzcmN0cmVlKS9hcmNoL2lhNjQvc2NyaXB0cy90b29sY2hhaW4tZmxhZ3MgIiQoQ0Mp
IiAiJChPQkpEVU1QKSIgIiQoUkVBREVMRikiKQotCi1pZmVxICgkKEdBU19TVEFUVVMpLGJ1Z2d5
KQotJChlcnJvciBTb3JyeSwgeW91IG5lZWQgYSBuZXdlciB2ZXJzaW9uIG9mIHRoZSBhc3NlbWJl
ciwgb25lIHRoYXQgaXMgYnVpbHQgZnJvbQlcCi0JYSBzb3VyY2UtdHJlZSB0aGF0IHBvc3QtZGF0
ZXMgMTgtRGVjLTIwMDIuICBZb3UgY2FuIGZpbmQgYSBwcmUtY29tcGlsZWQJXAotCXN0YXRpYyBi
aW5hcnkgb2Ygc3VjaCBhbiBhc3NlbWJsZXIgYXQ6CQkJCQlcCi0JCQkJCQkJCQkJXAotCQlmdHA6
Ly9mdHAuaHBsLmhwLmNvbS9wdWIvbGludXgtaWE2NC9nYXMtMDMwMTI0LnRhci5neikKLWVuZGlm
Ci0KIGlmZXEgKCQoY2FsbCBjYy12ZXJzaW9uKSwwMzA0KQogCWNmbGFncy0kKENPTkZJR19JVEFO
SVVNKQkrPSAtbXR1bmU9bWVyY2VkCiAJY2ZsYWdzLSQoQ09ORklHX01DS0lOTEVZKQkrPSAtbXR1
bmU9bWNraW5sZXkK
------=_Part_95393_6201657.1188286250559--
