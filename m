From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 08 Dec 2003 23:50:14 +0000
Subject: Re: q-tools OOPS
Message-Id: <marc-linux-ia64-107092780401500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092374429612@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092374429612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

Peter> Hi David, Dunno what's going on here.  I've built q-tools
Peter> against libpfm3.0 and libc 2.3.2.ds1-10.0.1 from Debian using
Peter> gcc 3.2.3.

This *does* appear to be a preemption problem.  Build the kernel
without CONFIG_PREEMPT, and q-syscollect works correctly.

Peter C
