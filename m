From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 May 2001 05:36:24 +0000
Subject: Re: [Linux-ia64] asm/unaligned.h missing include file
Message-Id: <marc-linux-ia64-105590693005678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005671@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005671@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 27 May 2001 03:17:08 -0400 (EDT), Dori Eldar <doriel@mail.com> said:

  Dori> I've seen that asm-ia64/unaligned.h uses the type __u64, but
  Dori> doesn't include asm{-ia64}/types.h where this type is defined.
  Dori> This forces anyone who includes "unaligned.h" to explicitly
  Dori> include types.h first.

I fixed this now.  Thanks for pointing this out.

	--david

