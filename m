From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 13 Nov 2000 21:23:37 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test1 0 and upper?
Message-Id: <marc-linux-ia64-105590678205699@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The new one is gcc 2.95 and it is terrible for compiling kernels. ( ia32 )

To be more precise, it is terrible for compiling old (2.2 based) linux kernels,
because these old linux kernels don't have any of the bug fixes needed to work
with new gcc releases.  It should be fine for compiling 2.4 based kernels.
In fact, nearly everybody uses a gcc-2.95 based compiler for their ia64 kernel
compiles.

Jim

