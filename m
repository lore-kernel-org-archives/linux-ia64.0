From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Fri, 14 Jun 2002 11:41:52 +0000
Subject: Re: [Linux-ia64] Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905641@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905641@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Dave and Jim,

Thanks for your answers.

Unfortunately, I did not success in installing gcc 3.1 on the system.

We are using a RedHat 7.2 distibution. gcc3-3.0.1-3 RPM is part of the
distibution and provides a /usr/bin/gcc3 binary distinct from the
/usr/bin/gcc binary provided by gcc-2.96-101 RPM.

I downloaded:

http://ftp.dulug.duke.edu/pub/redhat/linux/rawhide/ia64/RedHat/RPMS/gcc-3.1-6.ia64.rpm 
and tried to install with rpm command. I had to remove a lot of RPMs
and got stuck with the message:
        rpmlib(PartialHardlinkSets) <= 4.0.4-1 is needed by gcc-3.1-6

Is there a clean way to do that for an unexperimented gcc user, in
particular, can we have a gcc3.1 like installation that allows keeping 
the gcc2.96 ?

Thanks again for your help.
Xavier

Jim Wilson writes:
 > >Building kernel 2.4.18 for ia64 with gcc version 2.96 20000731 , it
 > >seems that there is some problem with code generation in the 
 > >ia64_log_rec_header_print() routine that prints MCA informations:
 > >year appears to be 18002 :-)
 > >Looking at the code with gdb, it seems that the generated code uses
 > >the f6 register without ininitializing:
 > 
 > I've tracked this down to a reload (register allocator) problem.  It looks
 > to be very rare, and it looks like it is still present in current gcc sources.
 > However, I'm not sure about that at the moment, as there are many possible
 > solutions, and it is possible someone implemented a non-obvious one.  I'm
 > continuing to look at this.  I want to try to reproduce it with current gcc
 > sources before I try to fix it.
 > 
 > >I tried using gcc3 (gcc version 3.0.2 20010905), but I get an internal 
 > >compiler error when I build the kernel.
 > 
 > I don't know what compiler you are refering to.  That doesn't look like an FSF
 > version number, and I don't know of any Red Hat compiler release with that
 > version number.
 > 
 > In any case, gcc 3.0 for IA-64 is not very interesting.  It wasn't adopted by
 > anybody that I know of for various reasons, so it never got stress tested and
 > is unlikely to be reliable.  Use gcc 3.1 instead.
 > 
 > Jim

