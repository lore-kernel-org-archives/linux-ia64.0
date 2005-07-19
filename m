From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 02:36:54 +0000
Subject: Re: [PATCH] Type qualifiers in __ia64_get_io_port_base
Message-Id: <20050719023654.GH10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050719012027.GA10518@cse.unsw.EDU.AU>
In-Reply-To: <20050719012027.GA10518@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 18, 2005 at 07:06:55PM -0700, david mosberger wrote:
> This one is wrong.  It should use __attribute_const__ instead.  If you
> just drop the "const", it will result in worse code.

Ok, I see why reading about attribute const.  Thanks!

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/include/asm-ia64/io.h b/include/asm-ia64/io.h
--- a/include/asm-ia64/io.h
+++ b/include/asm-ia64/io.h
@@ -120,7 +120,7 @@ static inline void ___ia64_mmiowb(void)
 	ia64_mfa();
 }
 
-static inline const unsigned long
+static inline __attribute_const__ unsigned long
 __ia64_get_io_port_base (void)
 {
 	extern unsigned long ia64_iobase;

