From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 21 Feb 2000 19:35:16 +0000
Subject: Re: [Linux-ia64] CD intructions.
Message-Id: <marc-linux-ia64-105590678204948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Now could someone (Mike?) write up a simple procedure for the
	development CD? Also Mike mentioned there were native ia64 toolchain
	binaries around? Anyone know where these are?

There are native IA-64 toolchains available within Trillian, but probably none
of these can be publicly distributed.  The toolchain sources needed some last
minute changes to get approval for public distribution.  This is incidentally
why we initially released sources without binaries; we didn't have time for our
usual release process after making the last minute changes.

It is possible to build a native IA-64 toolchain from the released sources
by building a ia32-linux to ia64-linux cross compiler first, and then using
that to build a native ia64-linux compiler.  I should write up instructions
explaining how to do that.  Today's a holiday here, so I might be able to do
that today.  I'll have to try it first to make sure the instructions work.

Jim


