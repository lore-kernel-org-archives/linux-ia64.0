From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 01 Aug 2000 01:48:07 +0000
Subject: Re: [Linux-ia64] Asm error when building cross-compiler
Message-Id: <marc-linux-ia64-105590678205261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205259@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You have a mismatched assembler and compiler.  I'm not sure how you could
have done that if everything you are using is from the toolchain downloaded
from ftp.cygnus.com.  If you have any assembler newer than the one in the
February release then it would fail this way, because this problem was
fixed shortly after the February release.

Do you perhaps already have a new assembler in
/usr/local/ia64/ia64-hp-linux-gnu/bin?  If so, then that could explain the
problem.  The -B options in the makefiles are in the wrong order, so if you
try build on top of an existing toolchain then this problem can happen.

The instruction in question is not valid because the .dc.dc and .few
completers were removed from the architecture.  If you have a new
assembler, and you remove both, then it should work.  Though you may have
other problems if you aren't using the assembler that came with this compiler.
C++ EH for instance won't work, and there might be problems with shared
libraries.

Jim



