From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Fri, 14 Jun 2002 21:17:10 +0000
Subject: RE: [Linux-ia64] Back to the future: which gcc for kernel 2.4.18
Message-Id: <marc-linux-ia64-105590701905681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905641@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905641@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>Is there a clean way to do that for an unexperimented gcc user, in
>>particular, can we have a gcc3.1 like installation that allows keeping 
>>the gcc2.96 ?

>I'd suggest trying something like
>        ftp://gcc.gnu.org/pub/gcc/releases/gcc-3.1/gcc-3.1.tar.bz2
>It shouldn't be too hard to build and install this. 

In fact, if you just accept the default configure, the gcc built
from this tree will install into /usr/local and not step on
the existing gcc (but watch your paths).  You're also pretty 
much sure to end up needing a late-model binutils (the
current gnu release is 2.12.1, I believe) as gcc3 will,
depending on circumstances, emit some debugging stuff that the 
linker can't handle if it's not recent enough.

