From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 21 May 2001 20:02:41 +0000
Subject: Re: [Linux-ia64] make cross-gcc error about GNUPro ToolKit
Message-Id: <marc-linux-ia64-105590693005635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005631@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like there is some compatibility problem with the headers, libraries,
and gcc sources.  Building a cross this way will work only if the libraries
were compiled by this gcc version.

If you want to do a build from scratch using a new gcc version, then you
need to build glibc and gcc at the same time.  This is so complicated that
it is best left to the experts.

>/usr/local/lib/gcc-lib/ia64-pc-linux/2.9-ia64-000216-final/../../../../ia64-pc-linux/bin/ld:

The 000216 release is long obsolete.  It is pointless to even try to use it.

You will have much better luck if you try the gcc sources that came with the
OS release that you have.

Jim

