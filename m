From: Kirill Korotaev <dev@openvz.org>
Date: Mon, 18 Dec 2006 12:04:31 +0000
Subject: [PATCH] IA64: alignment bug in ldscript
Message-Id: <458683CF.8030606@openvz.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Alexey Kuznetsov <alexey@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org

[IA64] bug in ldscript (mainstream)

Occasionally, in mainstream number of fsys entries is even.
In OpenVZ it is odd and we get misaligned kernel image,
which does not boot.

Signed-Off-By: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-Off-By: Kirill Korotaev <dev@openvz.org>

diff -urp ../linux-2.6.18-vz/arch/ia64/kernel/vmlinux.lds.S linux-2.6.18-vz/arch/ia64/kernel/vmlinux.lds.S
--- ../linux-2.6.18-vz/arch/ia64/kernel/vmlinux.lds.S	2006-12-08 13:34:19.000000000 +0300
+++ linux-2.6.18-vz/arch/ia64/kernel/vmlinux.lds.S	2006-12-13 02:51:03.000000000 +0300
@@ -163,6 +163,7 @@ SECTIONS
 	}
 #endif
 
+  . = ALIGN(8);
    __con_initcall_start = .;
   .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
 	{ *(.con_initcall.init) }

