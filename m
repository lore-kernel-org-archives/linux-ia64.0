From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 25 Jul 2000 23:16:52 +0000
Subject: Re: [Linux-ia64] 2.4.0-test5-pre4 patch for IA64 make
Message-Id: <marc-linux-ia64-105590678205230@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205229@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205229@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	The IA64 port needs a compile option (-mconstant-gp) turned on for the
	kernel but turned off for modules.  gcc only supports the option, not
	its negation, -mno-constant-gp is not valid.

That would be trivial for me to fix, if you wanted a compiler fix for this.
Getting the compiler patch to everyone that needs it might be a little
harder, but shouldn't be a problem.

Jim


