From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 24 Aug 2001 18:19:23 +0000
Subject: Re: [Linux-ia64] Simple question about pointers address space.
Message-Id: <marc-linux-ia64-105590698805103@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805102@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805102@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Aug 2001 14:10:23 -0400, "Dominic Duchemin" <DDuchemin@Kaydara.com> said:

  Dominic> 	I would simply like to know if the possible address
  Dominic> space (2^64) by a pointer is fulllly or partially used in
  Dominic> the context of a process in the linux ia64 kernel.

All 64 bits are used (there are no ignored bits), though depending on
the OS and CPU, some of the address space may be inaccessible (will
trigger a fault if accessed).

  Dominic> 	In the partial case, which part of the 2^64 is used.

  Dominic> 	The anser to this question is important for
  Dominic> me. Because what i try to do is to mix a reference
  Dominic> counter&pointer for atomic operation on pointers. So if
  Dominic> there is unused bits in the 64 bits pointer, I'll use them.

The only bits you might be able use for this purpose are low order
bits that are zero due to alignment constraints.  E.g., if your
objects are all 16-byte aligned, you could use the least-significant 4
bits.

	--david

