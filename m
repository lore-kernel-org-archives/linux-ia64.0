From: Evan Felix <evan.felix@pnl.gov>
Date: Sun, 17 Aug 2003 00:40:53 +0000
Subject: Re: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106108049004738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106098668517415@msgid-missing>
In-Reply-To: <marc-linux-ia64-106098668517415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I compiled the kernel with the debian unstable gcc 3.2:

Reading specs from /usr/lib/gcc-lib/ia64-linux/3.2.3/specs
Configured with: ../src/configure -v
--enable-languages=c,c++,f77,objc,ada --prefix=/usr
--mandir=/usr/share/man --infodir=/usr/share/info
--with-gxx-include-dir=/usr/include/c++/3.2 --enable-shared
--with-system-zlib --enable-nls --without-included-gettext
--enable-__cxa_atexit --enable-clocale=gnu --enable-objc-gc ia64-linux
Thread model: posix
gcc version 3.2.3 (Debian)

if it matters this was a bk pull from linus's tree that claimed to be
2.6.0-test3...

also is there any reason i did not get more of the stack trace from the
kernel?

Evan

On Fri, 2003-08-15 at 21:52, David Mosberger wrote:
> >>>>> On Fri, 15 Aug 2003 15:37:39 -0700, Evan Felix <evan.felix@pnl.gov> said:
> 
>   Evan> Recently i've been trying to run linux 2.6.0-test3 on a HP
>   Evan> zx2000, I've run IOZone twice on the system and both times it
>   Evan> has crashed with:
> 
>   Evan> pdflush[546]: General Exception: IA-64 Reserved Register/Field
>   Evan> fault (data acce]
> 
> I can't reproduce that (2.6.0-test3 + ia64 patch).  I also ran it
> twice with the same arguments and it ran to completion both times.
> 
> What compiler do you use?
> 
> 	--david
