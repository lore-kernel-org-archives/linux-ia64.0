From: richard offer <offer@sgi.com>
Date: Thu, 16 May 2002 00:17:33 +0000
Subject: [Linux-ia64] Add reserved number for security syscall
MIME-Version: 1
Content-Type: multipart/mixed; boundary="==========2796690887=========="
Message-Id: <marc-linux-ia64-105590701905580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--==========2796690887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



Please apply the attached patch (against 2.4.18) to reserve a syscall
number for the security interface.


A number has already been reserved and accepted by Linus for the i386,
alpha and cris architectures, at the time the reservation was requested,
none of the LSM developers had IA64 machines so it slipped through the
cracks.


Thanks,

richard.

-- 
-----------------------------------------------------------------------
Richard Offer                     Technical Lead, Trust Technology, SGI
"Specialization is for insects"
_______________________________________________________________________

--==========2796690887==========
Content-Type: text/plain; charset=iso-8859-1; name="sys_security.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="sys_security.txt"; size=408

--- =
/usr/tmp/TmpDir.3267-0/2.4.18-ia64/linux/include/asm-ia64/unistd.h_1.9	Wed =
May 15 16:53:12 2002
+++ 2.4.18-ia64/linux/include/asm-ia64/unistd.h	Wed May 15 16:47:44 2002
@@ -206,6 +206,7 @@
 #define __NR_getdents64			1214
 #define __NR_getunwind			1215
 #define __NR_readahead			1216
+#define __NR_security			1217  /* syscall for security modules */
=20
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
=20

--==========2796690887==========--


