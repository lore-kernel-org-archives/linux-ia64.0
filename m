From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 13 Jan 2017 10:46:42 +0000
Subject: [PATCH v3 4/8] x86: stop exporting msr-index.h to userland
Message-Id: <1484304406-10820-5-git-send-email-nicolas.dichtel@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: mmarek@suse.com, linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.

Suggested-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/x86/include/uapi/asm/Kbuild | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/x86/include/uapi/asm/Kbuild b/arch/x86/include/uapi/asm/Kbuild
index 3dec769cadf7..1c532b3f18ea 100644
--- a/arch/x86/include/uapi/asm/Kbuild
+++ b/arch/x86/include/uapi/asm/Kbuild
@@ -27,7 +27,6 @@ header-y += ldt.h
 header-y += mce.h
 header-y += mman.h
 header-y += msgbuf.h
-header-y += msr-index.h
 header-y += msr.h
 header-y += mtrr.h
 header-y += param.h
-- 
2.8.1

