From: Jes Sorensen <jes@linuxcare.com>
Date: Sun, 15 Apr 2001 05:05:28 +0000
Subject: Re: [Linux-ia64] Linuxconf patch
Message-Id: <marc-linux-ia64-105590693005402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005401@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005401@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Gustavo" = Gustavo Niemeyer <niemeyer@conectiva.com> writes:

Gustavo> I'd also like to introduce myself, since I haven't had time
Gustavo> to do so before. I've been working in the last two weeks to
Gustavo> port Conectiva Linux to ia64. If you know about any way I can
Gustavo> help you, or just want to exchange ideas (well, maybe this
Gustavo> list is the best place to do this), please, let me know.

Very nice

However, I noticed the following:

diff -u -r linuxconf-1.25/fstab/quota.cc linuxconf-1.25.ia64/fstab/quota.cc
--- linuxconf-1.25/fstab/quota.cc	Thu Nov  2 02:32:58 2000
+++ linuxconf-1.25.ia64/fstab/quota.cc	Thu Apr 12 12:03:21 2001
@@ -366,6 +366,18 @@
 	{
 		return syscall(__NR_quotactl, cmd, special, id, addr);
 	}
+#elif defined(__ia64__)
+	#include <asm/unistd.h>
+	int quotactl(int cmd, const char * special, int id, caddr_t addr)
+	{
+		register long r8 asm ("r8");
+		asm volatile ("mov r15=%1\n\t"
+			      "break %2"
+			      : "=r"(r8)
+			      : "g"(__NR_quotactl), "g"(__BREAK_SYSCALL),
+				"r"(cmd), "r"(special), "r"(id), "r"(addr));
+		return r8;
+	}

Please don't inline the syscall like that. We do support syscall() in
glibc and it would be nicer (and future compatible) if you use that
instead.

Cheers
Jes

