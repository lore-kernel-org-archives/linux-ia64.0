From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 22 Aug 2002 21:01:58 +0000
Subject: [Linux-ia64] syscall number for 2.5 AIO interface
Message-Id: <marc-linux-ia64-105590701905976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

I'm working with redhat on porting the kernel AIO code to ia64.  Can we have
the following syscall number reserved on ia64 for AIO related interface?
Thanks.

- Ken


+#define __NR_io_setup                  1240
+#define __NR_io_destroy                1241
+#define __NR_io_submit                 1242
+#define __NR_io_cancel                 1243
+#define __NR_io_wait                     1244
+#define __NR_io_getevents              1245

