From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 26 Sep 2001 22:38:49 +0000
Subject: Re: [Linux-ia64] umode_t?
Message-Id: <marc-linux-ia64-105590698805258@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805255@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805255@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Sep 2001 13:14:17 -0500, "Eric Gillespie, Jr." <epg@progeny.com> said:

  Eric> Curves, a frontend to CVS (it's a Debian package, the closest
  Eric> i could find to a web page is this:
  Eric> ftp://ftp.netcom.com/pub/el/elf/curves), checks for umode_t
  Eric> with AC_CHECK_TYPE(umode_t, int).  Unfortunately, it can't
  Eric> find umode_t because it's not in sys/types.h, but only in
  Eric> asm/types.h.  Are programs supposed to know about umode_t?  If
  Eric> so, it needs to be declared in sys/types.h somehow.

  Eric> I'm bringing this up here because Mosberger's name is on the
  Eric> header and it breaks curves on IA-64.

Isn't the poinit of AC_CHECK_TYP(umode_t, int) that if umode_t isn't
defined already, it will get defined as an "int"?

You'll need to talk to glibc maintainers as to whether umode_t should
or should not be defined.  I don't keep track of the latest name space
rules.

	--david

