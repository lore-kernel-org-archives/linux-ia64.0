From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 May 2003 23:51:21 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705661@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Great summary!

  Tony> 3) David's suggestion of boot-time relocation.  Probably
  Tony> simplest to implement this in elilo, but if you are really
  Tony> good at PIC asm code it could be done in the kernel startup
  Tony> sequence.

Agreed.  Anyone who's ever debugged the ld.so startup code will agree
that it's much better to do the relocation in elilo.

  Tony>  pros) Just like linking kernel at a new address.  Avoids the
  Tony> __tpa() issue.  Doesn't invalidate any assumptions about how
  Tony> to get from virtual to physical addresses and back again.

  Tony>  cons) Nobody has implemented it.

I think:

	- kernel text addresses vary depending on physical memory conf.

is potentially a bigger issue.  Implementing the relocator in elilo
should be really easy (just take the kernel loader and massage it a
bit).

How many tools are out there that depend on System.map or similar?  I
suppose you could just generate a fresh System.map at boot time (or
have something like /proc/System.map).

	--david

