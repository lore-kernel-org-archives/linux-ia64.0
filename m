From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Wed, 18 Aug 2004 01:22:03 +0000
Subject: Kernel 2.6.8 fails to boot on Tiger-4 when commandline parameter mem=8GB
Message-Id: <8126E4F969BA254AB43EA03C59F44E842B6A7A@pdsmsx404>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C484C1.C5092C5C"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C484C1.C5092C5C
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

My tiger-4 machine has 16GB memory. Kernel 2.6.8 fails to boot on it
when command line parameter mem=3D8G, and it also fails when mem being =
set
to other value, such as 7G, 10G.

Basically, in function efi_memmap_walk, md->num_pages might be decreased
if mem_limit is set, and then at the next time when efi_memmap_walk is
called, trim_top might trim the md again because of IA64_GRANULE_SIZE
alignment, then another md which is beyond mem_limit at the beginning
will be chosen, and its physical page number is larger than max_pfn.
Then, a BUG check is triggered.

Below is the patch to fix it.

Signed-off-by: Zhang Yanmin		<yanmin.zhang@intel.com>
Signed-off-by: Yao Jun			<junx.yao@intel.com>

diff -Nraup linux-2.6.8/arch/ia64/kernel/efi.c
linux-2.6.8_fix/arch/ia64/kernel/efi.c
--- linux-2.6.8/arch/ia64/kernel/efi.c	2004-08-16 07:59:53.151655436
+0800
+++ linux-2.6.8_fix/arch/ia64/kernel/efi.c	2004-08-16
08:01:43.348919711 +0800
@@ -357,8 +357,10 @@ efi_memmap_walk (efi_freemem_callback_t=20
 			if (total_mem >=3D mem_limit)
 				continue;
 			total_mem +=3D (md->num_pages << EFI_PAGE_SHIFT);
-			if (total_mem > mem_limit)
+			if (total_mem > mem_limit) {
 				md->num_pages -=3D ((total_mem -
mem_limit) >> EFI_PAGE_SHIFT);
+				max_addr =3D md->phys_addr +
(md->num_pages << EFI_PAGE_SHIFT);
+			}
=20
 			if (md->num_pages =3D=3D 0)
 				continue;




 <<mem_boot_err.patch.diff>>=20

------_=_NextPart_001_01C484C1.C5092C5C
Content-Type: application/octet-stream;
	name="mem_boot_err.patch.diff"
Content-Transfer-Encoding: base64
Content-Description: mem_boot_err.patch.diff
Content-Disposition: attachment;
	filename="mem_boot_err.patch.diff"

ZGlmZiAtTnJhdXAgbGludXgtMi42LjgvYXJjaC9pYTY0L2tlcm5lbC9lZmkuYyBsaW51eC0yLjYu
OF9maXgvYXJjaC9pYTY0L2tlcm5lbC9lZmkuYwotLS0gbGludXgtMi42LjgvYXJjaC9pYTY0L2tl
cm5lbC9lZmkuYwkyMDA0LTA4LTE2IDA3OjU5OjUzLjE1MTY1NTQzNiArMDgwMAorKysgbGludXgt
Mi42LjhfZml4L2FyY2gvaWE2NC9rZXJuZWwvZWZpLmMJMjAwNC0wOC0xNiAwODowMTo0My4zNDg5
MTk3MTEgKzA4MDAKQEAgLTM1Nyw4ICszNTcsMTAgQEAgZWZpX21lbW1hcF93YWxrIChlZmlfZnJl
ZW1lbV9jYWxsYmFja190IAogCQkJaWYgKHRvdGFsX21lbSA+PSBtZW1fbGltaXQpCiAJCQkJY29u
dGludWU7CiAJCQl0b3RhbF9tZW0gKz0gKG1kLT5udW1fcGFnZXMgPDwgRUZJX1BBR0VfU0hJRlQp
OwotCQkJaWYgKHRvdGFsX21lbSA+IG1lbV9saW1pdCkKKwkJCWlmICh0b3RhbF9tZW0gPiBtZW1f
bGltaXQpIHsKIAkJCQltZC0+bnVtX3BhZ2VzIC09ICgodG90YWxfbWVtIC0gbWVtX2xpbWl0KSA+
PiBFRklfUEFHRV9TSElGVCk7CisJCQkJbWF4X2FkZHIgPSBtZC0+cGh5c19hZGRyICsgKG1kLT5u
dW1fcGFnZXMgPDwgRUZJX1BBR0VfU0hJRlQpOworCQkJfQogCiAJCQlpZiAobWQtPm51bV9wYWdl
cyA9PSAwKQogCQkJCWNvbnRpbnVlOwo=

------_=_NextPart_001_01C484C1.C5092C5C--
