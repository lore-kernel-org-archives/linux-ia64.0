From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Dec 2005 20:12:06 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200512132012.jBDKC6rb029761@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Another "last" ia64 pull for 2.6.15.  Please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the file shown below.

Thanks!

-Tony

 include/asm-ia64/sal.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

Tony Luck:
      [IA64] Split 16-bit severity field in sal_log_record_header

diff-tree eed66cfcbbea851c97e287440d940286fce3f829 (from 90ac8f7741be4ff66de1f52904f4f67f272f74ce)
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Dec 13 10:41:49 2005 -0800

    [IA64] Split 16-bit severity field in sal_log_record_header
    
    ERR_SEVERITY item is defined as a 8 bits item in SAL documentation
    ($B.2.1 rev december 2003), but as an u16 in sal.h.
    This has the side effect that current code in mca.c may not call
    ia64_sal_clear_state_info() upon receiving corrected platform errors
    if there are bits set in the validation byte.  Reported by Xavier Bru.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 29df88b..313cad0 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -320,7 +320,8 @@ typedef struct sal_log_timestamp {
 typedef struct sal_log_record_header {
 	u64 id;				/* Unique monotonically increasing ID */
 	sal_log_revision_t revision;	/* Major and Minor revision of header */
-	u16 severity;			/* Error Severity */
+	u8 severity;			/* Error Severity */
+	u8 validation_bits;		/* 0: platform_guid, 1: !timestamp */
 	u32 len;			/* Length of this error log in bytes */
 	sal_log_timestamp_t timestamp;	/* Timestamp */
 	efi_guid_t platform_guid;	/* Unique OEM Platform ID */
