From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 16 Sep 2004 23:16:38 +0000
Subject: Unaligned kernel access in crypto/sha1.c
Message-Id: <20040916231638.GA32514@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux kernel <linux-kernel@vger.kernel.org>, linux ia64 kernel <linux-ia64@vger.kernel.org>

I got

Sep 16 15:45:32 gnu-2 kernel: kernel unaligned access to
0xa0000002001c008e, ip=0xa0000001002135e0
Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
0xa0000002002d005e, ip=0xa0000001002135e0
Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
0xa0000002002d006e, ip=0xa0000001002135e0
Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
0xa0000002002d007e, ip=0xa0000001002135e0
Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
0xa0000002002d008e, ip=0xa0000001002135e0

on ia64 from sha1_transform in crypto/sha1.c:

/* Hash a single 512-bit block. This is the core of the algorithm. */
static void sha1_transform(u32 *state, const u8 *in)
{
        u32 a, b, c, d, e;
        u32 block32[16];
                                                                                
        /* convert/copy data to workspace */
        for (a = 0; a < sizeof(block32)/sizeof(u32); a++)
          block32[a] = be32_to_cpu (((const u32 *)in)[a]);
				     ^^^^^^^^^^^^^^^^
				 This may not be aligned for u32 on ia64.


H.J.

