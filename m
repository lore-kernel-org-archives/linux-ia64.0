From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 27 Jan 2003 18:47:43 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 25 Jan 2003 21:19:57 +0100, Sam Ravnborg <sam@ravnborg.org> said:

  Sam> On Fri, Jan 24, 2003 at 09:02:32PM -0800, David Mosberger
  Sam> wrote:
  >> diff -Nru a/Makefile b/Makefile --- a/Makefile Fri Jan 24
  >> 20:41:05 2003 +++ b/Makefile Fri Jan 24 20:41:05 2003 @@ -170,7
  >> +170,7 @@ NOSTDINC_FLAGS = -nostdinc -iwithprefix include

  >> CPPFLAGS := -D__KERNEL__ -Iinclude -CFLAGS := $(CPPFLAGS) -Wall
  >> -Wstrict-prototypes -Wno-trigraphs -O2 \ +CFLAGS := $(CPPFLAGS)
  >> -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 \

  Sam> Hi David.

  Sam> I do not think "-g" was included on purpose...

It certainly is.  Debugging info is very useful, even without kgdb,
and is very easy to get rid of, via strip.

	--david

