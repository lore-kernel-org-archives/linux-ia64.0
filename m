From: Eric Gillespie <epg@progeny.com>
Date: Wed, 26 Sep 2001 23:58:42 +0000
Subject: [Linux-ia64] Re: umode_t?
Message-Id: <marc-linux-ia64-105590698805261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger writes:

> Isn't the poinit of AC_CHECK_TYP(umode_t, int) that if umode_t isn't
> defined already, it will get defined as an "int"?

Yes, but then there are all kinds of casting problems.  That needs to
be fixed too, for systems without umode_t at all, but it led me to the
question about umode_t not being in sys/types.h.

> You'll need to talk to glibc maintainers as to whether umode_t should
> or should not be defined.  I don't keep track of the latest name space
> rules.

OK, glibc people:  Why don't you get umode_t by including sys/types.h?
As far as i can tell, you have to include asm/types.h to get it;
clearly not an option for an autoconf macro.

-- 
Eric Gillespie, Jr. <*> epg@progeny.com
Software Developer
Progeny Linux Systems - http://progeny.com
"I don't know what a Sawfish Window Manager is."

