From: "Eric Gillespie, Jr." <epg@progeny.com>
Date: Wed, 26 Sep 2001 18:14:17 +0000
Subject: [Linux-ia64] umode_t?
Message-Id: <marc-linux-ia64-105590698805255@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Curves, a frontend to CVS (it's a Debian package, the closest i could
find to a web page is this: ftp://ftp.netcom.com/pub/el/elf/curves),
checks for umode_t with AC_CHECK_TYPE(umode_t, int).  Unfortunately,
it can't find umode_t because it's not in sys/types.h, but only in
asm/types.h.  Are programs supposed to know about umode_t?  If so, it
needs to be declared in sys/types.h somehow.

I'm bringing this up here because Mosberger's name is on the header
and it breaks curves on IA-64.

-- 
Eric Gillespie, Jr. <*> epg@progeny.com
Software Developer
Progeny Linux Systems - http://progeny.com
"I don't know what a Sawfish Window Manager is."

