From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Jul 2002 15:05:16 +0000
Subject: Re: [Linux-ia64] [PATCH] arch/ia64/kernel/efi.c
Message-Id: <marc-linux-ia64-105590701905835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905832@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905832@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Jul 2002 15:13:22 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Fri, Jul 26, 2002 at 03:50:03PM +0200, Andreas Schwab
  Matthew> wrote:
  >> IMHO the current behaviour is still useful.  For example to make
  >> sure you have only memory below 4G you can say "mem=4G".

  Matthew> maybe it's useful, but it's not what the option is
  Matthew> specified to do:

  Matthew>         mem=nn[KMG] [KNL,BOOT] force use of a specific
  Matthew> amount of memory; to be used when the kernel is not able to
  Matthew> see the whole system memory or for test.

I definitely want the old behavior.  But we can rename the old
behavior to "memlimit" or something like that.  I'd be happy to apply
such a patch.

	--david

