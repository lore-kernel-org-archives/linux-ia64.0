From: Don Dugger <n0ano@valinux.com>
Date: Fri, 19 May 2000 00:17:32 +0000
Subject: Re: [Linux-ia64] Can't find libncurses.so.4 in ia32
Message-Id: <marc-linux-ia64-105590678205099@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205098@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Vadim-

This appears to be some issue with version 4 versus version 5 that
I don't understand how `ldconfig' deals with it.  You can get around
the problem by setting `LD_LIBRARY_PATH=/usr/ia32/usr/lib' when
running the IA32 version of `telnet'.  That's what I did and it
worked fine.

On Thu, May 18, 2000 at 04:09:42PM -0700, Vadim Furman wrote:
> Hi,
> When I try to run an ia32 "telnet" , I get an error "Can't find shared
> library libncurses.so.4".
> The libncurses.so.4 library is there in my /usr/ia32/usr/lib directory,
> together with other versions of the ncurses libraries.
> But for some reasons ldconfig doesn't put it in the ld.so.cache, so when I
> do "ldconfig -p | grep ncurses" I see only libncurses.so.5 .
> I am using freshly installed TurboLinux Alpha 2000-05-05, my
> /etc/ld.so.config has /lib,/usr/lib, /usr/X11R6/lib, and
> /usr/ia32/lib,/usr/ia32/usr/lib,/usr/ia32/X11R6/lib
> 
> 
> Vadim Furman           Mainsoft Corporation
> vadimf@mainsoft.com    Phone: (408)544-1430
> Fax: (408)544-1444
> 3850 N. First St.
> San Jose CA. 95134-1702
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


