From: "Vadim Furman" <vadimf@mainsoft.com>
Date: Thu, 18 May 2000 23:09:42 +0000
Subject: [Linux-ia64] Can't find libncurses.so.4 in ia32
Message-Id: <marc-linux-ia64-105590678205098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
When I try to run an ia32 "telnet" , I get an error "Can't find shared
library libncurses.so.4".
The libncurses.so.4 library is there in my /usr/ia32/usr/lib directory,
together with other versions of the ncurses libraries.
But for some reasons ldconfig doesn't put it in the ld.so.cache, so when I
do "ldconfig -p | grep ncurses" I see only libncurses.so.5 .
I am using freshly installed TurboLinux Alpha 2000-05-05, my
/etc/ld.so.config has /lib,/usr/lib, /usr/X11R6/lib, and
/usr/ia32/lib,/usr/ia32/usr/lib,/usr/ia32/X11R6/lib


Vadim Furman           Mainsoft Corporation
vadimf@mainsoft.com    Phone: (408)544-1430
Fax: (408)544-1444
3850 N. First St.
San Jose CA. 95134-1702



