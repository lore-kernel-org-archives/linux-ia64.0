From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 24 Jul 2000 19:22:22 +0000
Subject: Re: [Linux-ia64] Internal compiler error in `reload_cse_simplify_operands'
Message-Id: <marc-linux-ia64-105590678205225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	alxxlog.c: In function `AlLogReadBlock':
	alxxlog.c:750: Insn does not satisfy its constraints:

This is a compiler bug.  I would need a testcase so I can reproduce the
problem, and information about what compiler you are using.

The easiest way to create a testcase is to use --save-temps, and then send
the resulting .i file along with the command line used to create it.

Jim


