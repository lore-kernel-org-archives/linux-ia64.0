From: "Dominic Duchemin" <DDuchemin@Kaydara.com>
Date: Fri, 24 Aug 2001 18:10:23 +0000
Subject: [Linux-ia64] Simple question about pointers address space.
Message-Id: <marc-linux-ia64-105590698805102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I would simply like to know if the possible address space (2^64)
by a pointer is fulllly or partially used in the context of a process in
the linux ia64 kernel.

	In the partial case, which part of the 2^64 is used.


	The anser to this question is important for me. Because what i
try to do is to mix a reference counter&pointer for atomic operation on
pointers. So if there is unused bits in the 64 bits pointer, I'll use
them.

	thanks.

------------------------
Si_Brain - Noise from void.
Kaydara, dduchemin@kaydara.com

	

