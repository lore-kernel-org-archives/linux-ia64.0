From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 02 Oct 2000 21:05:22 +0000
Subject: Re: [Linux-ia64] gcc -O2
Message-Id: <marc-linux-ia64-105590678205534@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205531@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205531@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All optimizing compilers have bugs.  You shouldn't panic when you find one.
The -O2 option is definitely usable.  Entire linux distributions have been
built with it.

There are some known problems with the C++ support in the 000216 release.
There was a lot of C++ front end development work happening at the time, and
we ended up with an FSF gcc snapshot that has a few instabilities in the C++
front end.  Otherwise, the release has held up very well.  There haven't been
very many problems with it.

Bug reports sent here are OK.  Bug reports sent to the usual FSF addresses
are OK, if you make it clear that you are using one of the unofficial releases
that the ia64-linux project is using.

There is a new toolchain release that you can try if you are interested.
I expect that the next series of linux distributions will use this new
toolchain.  It is located on ftp.cygnus.com in pub/ia64-linux.

I am not too interested in bug reports against the old toolchain at this point,
but I will help if I can.

Jim

