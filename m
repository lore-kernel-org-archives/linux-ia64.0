From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 15 Apr 2004 04:01:45 +0000
Subject: Re: 32 bit application on IA-64 Linux
Message-Id: <16510.2345.843152.740528@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
In-Reply-To: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Srikanta" = Srikanta R <Srikanta> writes:

Srikanta> Hi Arun, Thanks for the information. Can you please tell me
Srikanta> where I can get it from ?

If you're running debian, there's a prebuilt cross compiler available
from the Gelato Debian repository

See http://www.gelato.unsw.edu.au/IA64wiki/GelatoDebianRepository

or just add this to /etc/apt/sources.list :

   deb http://gelato.unsw.edu.au/debian unstable/$(ARCH)/
   deb http://gelato.unsw.edu.au/debian unstable/all/
   deb-src http://gelato.unsw.edu.au/debian/ unstable/source/

and install gcc-i386-linux and binutils-i386-linux

You'll also need to install the ia32-libs package, and
toolchain-source, then do 
  tpkg-install-libc i386-linux
to get the development libraries and headers.

Disclaimer:  I haven't actually done all this.

Another approach would be to install an IA32 native toolchain under
/emul/ia32-linux/ 

Both dpkg and rpm allow you to specify a root directory; just specify
/emul/ia32-linux 




--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
