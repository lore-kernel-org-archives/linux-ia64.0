From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 16 Jan 2019 13:44:17 +0000
Subject: [PATCH 17/21] init/main: add checks for the return value of memblock_alloc*()
Message-Id: <1547646261-32535-18-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

Add panic() calls if memblock_alloc() returns NULL.

The panic() format duplicates the one used by memblock itself and in order
to avoid explosion with long parameters list replace open coded allocation
size calculations with a local variable.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 init/main.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/init/main.c b/init/main.c
index a56f65a..d58a365 100644
--- a/init/main.c
+++ b/init/main.c
@@ -373,12 +373,20 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
  */
 static void __init setup_command_line(char *command_line)
 {
-	saved_command_line -		memblock_alloc(strlen(boot_command_line) + 1, SMP_CACHE_BYTES);
-	initcall_command_line -		memblock_alloc(strlen(boot_command_line) + 1, SMP_CACHE_BYTES);
-	static_command_line = memblock_alloc(strlen(command_line) + 1,
-					     SMP_CACHE_BYTES);
+	size_t len = strlen(boot_command_line) + 1;
+
+	saved_command_line = memblock_alloc(len, SMP_CACHE_BYTES);
+	if (!saved_command_line)
+		panic("%s: Failed to allocate %zu bytes\n", __func__, len);
+
+	initcall_command_line =	memblock_alloc(len, SMP_CACHE_BYTES);
+	if (!initcall_command_line)
+		panic("%s: Failed to allocate %zu bytes\n", __func__, len);
+
+	static_command_line = memblock_alloc(len, SMP_CACHE_BYTES);
+	if (!static_command_line)
+		panic("%s: Failed to allocate %zu bytes\n", __func__, len);
+
 	strcpy(saved_command_line, boot_command_line);
 	strcpy(static_command_line, command_line);
 }
@@ -773,8 +781,14 @@ static int __init initcall_blacklist(char *str)
 			pr_debug("blacklisting initcall %s\n", str_entry);
 			entry = memblock_alloc(sizeof(*entry),
 					       SMP_CACHE_BYTES);
+			if (!entry)
+				panic("%s: Failed to allocate %zu bytes\n",
+				      __func__, sizeof(*entry));
 			entry->buf = memblock_alloc(strlen(str_entry) + 1,
 						    SMP_CACHE_BYTES);
+			if (!entry->buf)
+				panic("%s: Failed to allocate %zu bytes\n",
+				      __func__, strlen(str_entry) + 1);
 			strcpy(entry->buf, str_entry);
 			list_add(&entry->next, &blacklisted_initcalls);
 		}
-- 
2.7.4
