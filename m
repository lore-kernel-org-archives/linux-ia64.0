From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Aug 2003 14:43:39 +0000
Subject: Re: build problems/questions (2.6.0-test3)
Message-Id: <marc-linux-ia64-106156348322179@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106151574613417@msgid-missing>
In-Reply-To: <marc-linux-ia64-106151574613417@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 21 Aug 2003 18:28:50 -0700 (PDT), "Randy.Dunlap" <rddunlap@osdl.org> said:

  Randy> Hi, I'm seeing some build problems and want to see if they
  Randy> are just my problems.  Shoule these build OK on ia64 or are
  Randy> they all just dont-cares for ia64?

  Randy> 1.  driver/block/floppy.c

No (there are no ia64 machines if AT-style floppy controllers.).

  Randy> 2.  drivers/char/nvram.c ?? (x86-ism)

Nope.

  Randy> 3.  drivers/char/hangcheck.c ?

Don't know.

  Randy> 4.  ISA PNP support?

Nope (there is no ISA on ia64 machines).

	--david
