From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 20:27:09 +0000
Subject: RE: [Linux-ia64] mprotect problem
Message-Id: <marc-linux-ia64-105590698805650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805634@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805634@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 7 Dec 2001 12:13:26 -0800, "Boehm, Hans" <hans_boehm@hp.com> said:

  Hans> What's the instruction that's faulting and what are the
  Hans> contents of the register used for addressing?  You should
  Hans> easily be able to get that out of gdb.

Also, what's the address of the faulting instruction.  I assume it's
in normal (not shared) memory, right?

	--david

