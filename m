From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 08 Feb 2001 00:20:54 +0000
Subject: Re: [Linux-ia64] The 1117 snapshot cpp problem
Message-Id: <marc-linux-ia64-105590693005121@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It is ok if you use "make bootstrap" since $(includedir) passed down
>is ignored during "make bootstrap" in gcc. But the toolchain may not
>be built with "make bootstrap". I believe
>"includedir=$(includedir)" \
>should not be passed to gcc during any build.

I don't like that idea.  It defeats the purpose of having the top level
Makefile, which is to ensure that all tools are compatible with each other.
Binutils for instance uses includedir.  It will install bfd.h there.  So
if binutils uses includedir and gcc does not, then they are no longer
compatible with each other.  binutils will install a header file someplace
where gcc can't find it.

I think this also explains part of the reason why the "Cygnus" tree sets
includedir to $prefix/include.  If you configure a tree setting $prefix, and
then install it, it is wrong to install files into /usr/local/include.
Everything has to be installed underneath $prefix.  This required creating
a new include directory underneath prefix, and making gcc look in it.
Unfortunately, our mistake here was that we replaced /usr/local/include
which other people are using.

This mistake has already been institutionalized by the gcc-2.95 release.
gcc-2.9 supports /usr/local/include.  gcc-2.95 supports $prefix/include.
There are people that want both, so I think we need to support both now.

This requires a bigger change though.  We have to document the new directory,
add support for the new directory to cpp and anyplace else that cares
(protoize?), and fix up the Makefile to pass both directory names on the
compile line for cpp.  This is a big enough change that I was not able to
have it done by yesterday.

Jim

