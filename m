From: Randolph Chung <tausq@debian.org>
Date: Tue, 09 Apr 2002 05:23:37 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905403@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905403@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For some reason, I don't see this in my configure.in.  Was this added
> by the Debian patch?  In principle, it's a good idea to check for this
> macro, but I the check needs to be different.  To get it to compile,
> FFI_STATIC_CLOSURE() would have to be declared at the outermost level.
> Alternatively, perhaps you can just grep for this macro in ffi.h (I
> think autoconf has support for doing this).

<sigh> you are right, i will go poke the Debian maintainer about this
now. Sorry for the diversion.

randolph


