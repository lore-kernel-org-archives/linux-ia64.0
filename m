From: Jim Wilson <wilson@redhat.com>
Date: Fri, 14 Jun 2002 17:04:53 +0000
Subject: Re: [Linux-ia64] Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905641@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905641@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>We are using a RedHat 7.2 distibution. gcc3-3.0.1-3 RPM is part of the
>distibution and provides a /usr/bin/gcc3 binary distinct from the
>/usr/bin/gcc binary provided by gcc-2.96-101 RPM.

Seems to be some inconsistencies in the packaging then.  A 3.0.1 RPM shouldn't
comtain a 3.0.2 compiler.  The RHL 7.2/IA-64 system I am using has a gcc3
compiler that identifies itself as 3.0.4-1.  I don't know what RPM that came
from as rpm isn't being cooperative.  In any case, gcc 3.0 really isn't
very interesting.

>http://ftp.dulug.duke.edu/pub/redhat/linux/rawhide/ia64/RedHat/RPMS/gcc-3.1-6.ia64.rpm 
>and tried to install with rpm command. I had to remove a lot of RPMs
>and got stuck with the message:
>        rpmlib(PartialHardlinkSets) <= 4.0.4-1 is needed by gcc-3.1-6

No idea.  I've never used anything from Rawhide.  I know that they sometimes
change rpm in non-backwards compatible ways which make it difficult to use
stuff from rawhide, but that doesn't really help you.

>Is there a clean way to do that for an unexperimented gcc user, in
>particular, can we have a gcc3.1 like installation that allows keeping 
>the gcc2.96 ?

I don't know much about how the RPM stuff works.  That is the OS side of
Red Hat, not the tools side of Red Hat.  I'd suggest trying something like
        ftp://gcc.gnu.org/pub/gcc/releases/gcc-3.1/gcc-3.1.tar.bz2
It shouldn't be too hard to build and install this.  If this doesn't build
the kernel OK, it will be fixed.

Jim

