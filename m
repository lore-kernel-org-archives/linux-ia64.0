From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 09 Aug 2000 00:30:10 +0000
Subject: Re: [Linux-ia64] Problem report: gas breaks on fclass mnemonics
Message-Id: <marc-linux-ia64-105590678205288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205284@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205284@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	The problem is that the Linux assembler (2.9-ia64-000216) apparently does
	not support the mnemonics
	used with the fclass instructions (@inf, @pos, @neg, @zero, @qnan, @snan,
	@norm, @unorm).  

This is fixed in the current assembler development sources, and will be fixed
in the next toolchain release.

I did have one problem with your testcase.  You have ".restore", but the
Assembler Reference Guide says that .restore must have an argument of sp,
and the current assembler gives an error for this.  After fixing this, I
was able to compile and run both the good and bad testcases with the current
toolchain, and they both report success.

Jim

