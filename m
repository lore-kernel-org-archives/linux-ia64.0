From: Jeffrey William Lake <lakes@lakes.plus.com>
Date: Fri, 17 Oct 2003 15:26:13 +0000
Subject: Re: load-store emulation with SIGSEGV (gate.S bug?)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=_e53c01ce37d9ae5da19f02a0a7f1ecc4"
Message-Id: <marc-linux-ia64-106640456919155@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


This is a MIME encoded message.

--=_e53c01ce37d9ae5da19f02a0a7f1ecc4
Content-Type: text/plain;
Content-Transfer-Encoding: 7bit

After some investigation I discovered that a "flushrs" at the start of my
signal handler cured the problem.

Looking at "arch/ia64/kernel/gate.S" revealed that a "cover" is used to
get the registers onto the backing store (commented as such several
times), but by my understanding there is enough scope from the instruction
description that they may be cached. Therefore, should gate.S include a
"flushrs" as well or, for performance reasons be left for the user to
decide?


--=_e53c01ce37d9ae5da19f02a0a7f1ecc4--

