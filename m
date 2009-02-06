From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Date: Fri, 06 Feb 2009 08:53:56 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0016364c716be025b504623c2806"
List-Id: <linux-ia64.vger.kernel.org>
References: <1233385816.17794.16.camel@localhost.localdomain>
	 <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

--0016364c716be025b504623c2806
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On Fri, Feb 6, 2009 at 1:49 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-next <linux-next@vger.kernel.org>
> Cc: linux-ia64 <linux-ia64@vger.kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> ---
>  arch/ia64/include/asm/fpu.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: b/arch/ia64/include/asm/fpu.h
> ===================================================================
> --- a/arch/ia64/include/asm/fpu.h
> +++ b/arch/ia64/include/asm/fpu.h
> @@ -6,7 +6,7 @@
>  *     David Mosberger-Tang <davidm@hpl.hp.com>
>  */
>
> -#include <linux/types.h>
> +#include <asm/types.h>
>

No , we do not even need asm/types.h

Subject: [PATCH] Neither asm/types.h nor linux/types.h is not required
for arch/ia64/include/asm/fpu.h

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 arch/ia64/include/asm/fpu.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/fpu.h b/arch/ia64/include/asm/fpu.h
index b6395ad..0c26157 100644
--- a/arch/ia64/include/asm/fpu.h
+++ b/arch/ia64/include/asm/fpu.h
@@ -6,8 +6,6 @@
  *     David Mosberger-Tang <davidm@hpl.hp.com>
  */

-#include <linux/types.h>
-
 /* floating point status register: */
 #define FPSR_TRAP_VD   (1 << 0)        /* invalid op trap disabled */
 #define FPSR_TRAP_DD   (1 << 1)        /* denormal trap disabled */
-- 
1.6.1.1

--0016364c716be025b504623c2806
Content-Type: text/x-patch; charset=US-ASCII; 
	name="0001-Neither-asm-types.h-nor-linux-types.h-is-not-require.patch"
Content-Disposition: attachment; 
	filename="0001-Neither-asm-types.h-nor-linux-types.h-is-not-require.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fqw1smqb0

RnJvbSA2NGUxOWRjYzYwY2Y5Y2QxNDU1YWY1YjBhOWFhZjQ1ZTdmMDBkZGU4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKYXN3aW5kZXIgU2luZ2ggUmFqcHV0IDxqYXN3aW5kZXJyYWpw
dXRAZ21haWwuY29tPgpEYXRlOiBGcmksIDYgRmViIDIwMDkgMDg6NDM6MjkgKzAwMDAKU3ViamVj
dDogW1BBVENIXSBOZWl0aGVyIGFzbS90eXBlcy5oIG5vciBsaW51eC90eXBlcy5oIGlzIG5vdCBy
ZXF1aXJlZCBmb3IgYXJjaC9pYTY0L2luY2x1ZGUvYXNtL2ZwdS5oCgpTaWduZWQtb2ZmLWJ5OiBK
YXN3aW5kZXIgU2luZ2ggUmFqcHV0IDxqYXN3aW5kZXJyYWpwdXRAZ21haWwuY29tPgotLS0KIGFy
Y2gvaWE2NC9pbmNsdWRlL2FzbS9mcHUuaCB8ICAgIDIgLS0KIDEgZmlsZXMgY2hhbmdlZCwgMCBp
bnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9pbmNs
dWRlL2FzbS9mcHUuaCBiL2FyY2gvaWE2NC9pbmNsdWRlL2FzbS9mcHUuaAppbmRleCBiNjM5NWFk
Li4wYzI2MTU3IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQvaW5jbHVkZS9hc20vZnB1LmgKKysrIGIv
YXJjaC9pYTY0L2luY2x1ZGUvYXNtL2ZwdS5oCkBAIC02LDggKzYsNiBAQAogICoJRGF2aWQgTW9z
YmVyZ2VyLVRhbmcgPGRhdmlkbUBocGwuaHAuY29tPgogICovCiAKLSNpbmNsdWRlIDxsaW51eC90
eXBlcy5oPgotCiAvKiBmbG9hdGluZyBwb2ludCBzdGF0dXMgcmVnaXN0ZXI6ICovCiAjZGVmaW5l
IEZQU1JfVFJBUF9WRAkoMSA8PCAwKQkvKiBpbnZhbGlkIG9wIHRyYXAgZGlzYWJsZWQgKi8KICNk
ZWZpbmUgRlBTUl9UUkFQX0RECSgxIDw8IDEpCS8qIGRlbm9ybWFsIHRyYXAgZGlzYWJsZWQgKi8K
LS0gCjEuNi4xLjEKCg==
--0016364c716be025b504623c2806--
