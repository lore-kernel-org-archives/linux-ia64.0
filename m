From: Dori Eldar <doriel@mail.com>
Date: Sun, 27 May 2001 07:17:08 +0000
Subject: [Linux-ia64] asm/unaligned.h missing include file
Message-Id: <marc-linux-ia64-105590693005671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've seen that asm-ia64/unaligned.h uses the type __u64, but doesn't include
asm{-ia64}/types.h where this type is defined.
This forces anyone who includes "unaligned.h" to explicitly include types.h
first.

Dori


______________________________________________
FREE Personalized Email at Mail.com
Sign up at http://www.mail.com/?sr=signup

