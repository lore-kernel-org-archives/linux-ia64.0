From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 01 Dec 2005 02:37:17 +0000
Subject: Re: [PATCH] save parameter registers and restore them for jprobe handling
Message-Id: <6119.1133404637@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 1 Dec 2005 10:28:09 +0800, 
"Zhang, Yanmin" <yanmin.zhang@intel.com> wrote:
>Content-Transfer-Encoding: base64

Why base64 encoding for the patch?

+/*Invalidate stacked registers outside the current frame*/
+#define invalidate_stacked_regs() { 				\
+	unsigned long rsc_save = 0;				\
+	asm volatile("mov %0=ar.rsc;;\n\t"			\
+		"mov ar.rsc=0;;\n\t"				\
+		"{\n\tloadrs;;\n\t\n\t\n\t}\n\t"		\
+		"mov ar.rsc=%1\n\t"				\
+		:"=r" (rsc_save):"r" (rsc_save):"memory");	\
+	}
+

We try to avoid inline asm in the .c files, it makes it harder to
compile the kernel with Intel compilers.

