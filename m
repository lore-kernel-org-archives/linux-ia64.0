From: xb <xavier.bru@bull.net>
Date: Mon, 12 Dec 2005 10:02:54 +0000
Subject: sal record header concern
Message-Id: <439D4ACE.9020701@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040306040709010208040006"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040306040709010208040006
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Hello Keith and all

It seems there is a concern around the SAL record header:
     SEVERITY item is defined as a 8 bits item in SAL documentation 
($B.2.1 rev december 2003), but as an u16 in sal.h.
This has the side effect that current code in mca.c does not call 
ia64_sal_clear_state_info() upon receiving corrected platform errors 
(priority is reported as 258 instead of 2).


--- linux-2.6.12.6/include/asm-ia64/sal.h~    2005-08-29 
18:55:27.000000000 +0200
+++ linux-2.6.12.6/include/asm-ia64/sal.h    2005-12-12 
10:19:17.000000000 +0100
@@ -320,7 +320,8 @@
 typedef struct sal_log_record_header {
     u64 id;                /* Unique monotonically increasing ID */
     sal_log_revision_t revision;    /* Major and Minor revision of 
header */
-    u16 severity;            /* Error Severity */
+    u8 severity;            /* Error Severity */
+    u8 validation_bits;        /* Validation Bits */
     u32 len;            /* Length of this error log in bytes */
     sal_log_timestamp_t timestamp;    /* Timestamp */
     efi_guid_t platform_guid;    /* Unique OEM Platform ID */


--------------040306040709010208040006
Content-Transfer-Encoding: 7bit
Content-Type: text/x-vcard; charset=utf-8;
 name="xavier.bru.vcf"
Content-Disposition: attachment;
 filename="xavier.bru.vcf"

begin:vcard
fn:Xavier Bru
n:Bru;Xavier
adr:;;1 rue de Provence, BP 208;38432 Echirolles Cedex;;;France
email;internet:Xavier.Bru@bull.net
title:BULL/DT/Open Software/linux/ia64
tel;work:+33 (0)4 76 29 77 45
tel;fax:+33 (0)4 76 29 77 70 
x-mozilla-html:TRUE
url:http://www.bull.com
version:2.1
end:vcard


--------------040306040709010208040006--
