From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Jun 2004 21:25:16 +0000
Subject: Re: sys_ioctl export
Message-Id: <16594.3132.438145.268277@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Jun 2004 12:36:54 -0700, Mark Haverkamp <markh@osdl.org> said:

  Mark> Wouldn't there be some reluctance to export a symbol to
  Mark> everyone when it is only used for a special purpose?

It seems rather silly to try to limit the exporting of a symbol that's
exported for all 64-bit platforms.  But I don't really care.  If you
want to submit a tested patch to add the symbol to ia64_ksyms.c, I can
certainly live with that.

	--david
