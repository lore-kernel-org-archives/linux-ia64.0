From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 05 Aug 2004 06:42:36 +0000
Subject: [PATCH] adjust the alignment in struct sal_processor_static_info
Message-Id: <4111D6DC.5080006@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090205030702060401070402"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090205030702060401070402
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi all,

Struct ia64_fpreg(asm-ia64/fpu.h) is forced to align 16-byte.
An array of this struct is in struct sal_processor_static_info
(asm-ia64/sal.h), however, we can't touch the array correctly
because of the forced alignment.

Usually, SAL log record contains:
  Record Header
    - sizeof(sal_log_record_header_t) = 40
  Section Header
    - sizeof(sal_log_sec_hdr_t) = 24
  Section Body(Processor Error Section)
    - sizeof(before mod_error_info) = 32
    - sizeof(sal_log_mod_error_info_t) = 48
    - sizeof(sal_cpuid_info) = 48
    - sizeof(sal_log_mod_error_info_t) = 48
    - sizeof(sal_processor_static_info_t) = 5256
      (offset of struct ia64_fpreg fr[0]
        in sal_processor_static_info_t) = 3208

So, the total offset of fr[0] from beginning of the record is:
    40 + 24 + 32 + 48*n + 48 + 3208
This number can't be divided by 16. fr[0] never fit to the
16-byte boundary because of the remainder.

This trivial patch will fix this issue.

Thanks,

H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

--------------090205030702060401070402
Content-Type: text/plain;
 name="patch-268rc3-sal"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch-268rc3-sal"

ZGlmZiAtTnVyIGxpbnV4LTIuNi44LXJjMy9pbmNsdWRlL2FzbS1pYTY0L3NhbC5oIGxpbnV4
LTIuNi44LXJjMy1zYWwvaW5jbHVkZS9hc20taWE2NC9zYWwuaAotLS0gbGludXgtMi42Ljgt
cmMzL2luY2x1ZGUvYXNtLWlhNjQvc2FsLmgJMjAwNC0wOC0wNCAwNjoyODo0OC4wMDAwMDAw
MDAgKzA5MDAKKysrIGxpbnV4LTIuNi44LXJjMy1zYWwvaW5jbHVkZS9hc20taWE2NC9zYWwu
aAkyMDA0LTA4LTA0IDE4OjA1OjU4LjM2NTUxNjM5NSArMDkwMApAQCAtMzY0LDcgKzM2NCw3
IEBACiAJdTY0IGNyWzEyOF07CiAJdTY0IGFyWzEyOF07CiAJdTY0IHJyWzhdOwotCXN0cnVj
dCBpYTY0X2ZwcmVnIGZyWzEyOF07CisJc3RydWN0IGlhNjRfZnByZWcgX19hdHRyaWJ1dGVf
XyAoKHBhY2tlZCkpIGZyWzEyOF07CiB9IHNhbF9wcm9jZXNzb3Jfc3RhdGljX2luZm9fdDsK
IAogc3RydWN0IHNhbF9jcHVpZF9pbmZvIHsK
--------------090205030702060401070402--
