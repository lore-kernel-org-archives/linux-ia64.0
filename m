From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Sun, 23 Apr 2000 09:02:02 +0000
Subject: Re: [Linux-ia64] ld-linux.so
Message-Id: <marc-linux-ia64-105590678205025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Laurent" = Laurent Morichetti <laurentm@cup.hp.com> writes:

Laurent> In glibc/sysdeps/ia64/dl-machine.h the macro
Laurent> TRAMPOLINE_TEMPLATE saves the input registers but not r8
Laurent> (pointer to value returned in memory). r8 should be preserved
Laurent> across the runtime fixup.

I know very little about the C++ ABI so this may be C++ specific.  I
thought r8 was meant to be a return register and not an input
register and that it's valid to clobber it in any function call,
whether the function returns a value or void?

I am sitting at home right now and all my documents are in the office
so I can't look it up.

Jes


