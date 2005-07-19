From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:20:27 +0000
Subject: [PATCH] Type qualifiers in __ia64_get_io_port_base
Message-Id: <20050719012027.GA10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

include/asm/io.h:125: warning: type qualifiers ignored on function return type

produced by gcc 4

According to http://gcc.gnu.org/ml/gcc-patches/2000-10/msg00814.html
the type qualifier is superfluous.

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/include/asm-ia64/io.h b/include/asm-ia64/io.h
--- a/include/asm-ia64/io.h
+++ b/include/asm-ia64/io.h
@@ -120,7 +120,7 @@ static inline void ___ia64_mmiowb(void)
 	ia64_mfa();
 }
 
-static inline const unsigned long
+static inline unsigned long
 __ia64_get_io_port_base (void)
 {
 	extern unsigned long ia64_iobase;
