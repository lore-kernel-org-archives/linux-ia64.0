From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 10 Mar 2000 18:59:21 +0000
Subject: Re: [Linux-ia64] crosscompiler ?
Message-Id: <marc-linux-ia64-105590678204979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204978@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204978@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Is a crosscompiler for linuix-ia32 available somewhere or is it really
	necessary to build it by myself ?

I don't know of anyone publicly distributing native or cross compiler binaries
at this time.  Most free software groups tend to just distribute sources, not
binaries.

Unfortunately, at the present time, there is no easy way to build a cross
compiler, because not all of the stuff you need is readily available to the
public.  It is possible, it is just a lot of work, because you need to build
the compiler and the libraries (glibc) at the same time, which requires a more
complicated build process than is normal.

This will all get easier when the linux vendors start releasing alpha quality
ia64 linux distributions.  Unless you have an immediate need for an ia64
compiler, you are probably better off waiting, and let the linux vendors do
the hard work for you.

Jim


