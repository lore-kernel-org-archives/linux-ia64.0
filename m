From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 17:32:14 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 15:16:49 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Wed, May 14, 2003 at 03:31:08PM +0200, Eric Piel wrote:
  >> Hello, There is a compile error if not compiling for SMP:

  >> +#ifdef CONFIG_SMP if (!tasklist_lock.write_lock) +#endif
  >> read_lock(&tasklist_lock);

  Matthew> Yuck.  The right way to do this is
  Matthew> read_trylock(&tasklist_lock); The observant will have
  Matthew> noted:

  Matthew> /* Where's read_trylock? */

  Matthew> in include/linux/spinlock.h but that doen't justify _not
  Matthew> writing it_ when you need it.

You want to send me a patch? ;-)

	--david

