From: Bill Nottingham <notting@redhat.com>
Date: Thu, 24 Jan 2002 02:23:32 +0000
Subject: [Linux-ia64] patch for vmlinux.lds.S
MIME-Version: 1
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Message-Id: <marc-linux-ia64-105590698805920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This fixes building the kernel for me; possibly a recent binutils
thing? (Otherwise, I'm getting dangling references to the
text.exit code in .IA_64.unwind.text.exit sections.)

Bill

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-ia64.patch"

--- linux/arch/ia64/vmlinux.lds.S.foo	Wed Jan 23 17:40:23 2002
+++ linux/arch/ia64/vmlinux.lds.S	Wed Jan 23 17:39:26 2002
@@ -12,6 +12,8 @@
   /DISCARD/ : {
 	*(.text.exit)
 	*(.data.exit)
+	*(*.text.exit)
+	*(*.data.exit)
 	*(.exitcall.exit)
 	}
 

--+HP7ph2BbKc20aGI--

