From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Jun 2004 18:30:33 +0000
Subject: Re: sys_ioctl export
Message-Id: <16593.58185.61928.622406@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Jun 2004 10:52:27 -0700, Mark Haverkamp <markh@osdl.org> said:

  Mark> The ia64 arch doesn't export sys_ioctl like some other 64 bit
  Mark> architectures like ppc64, sparc64 and x86_64.  Was this
  Mark> intentional?

It's intentional in the sense that Linux doesn't export symbols
without good reason.  AFAICT, the following arches export sys_ioctl:

 ppc64
 s390
 sparc64
 x86-64

AFAIK, there is no ia64-specific reason to export the symbol.  If
there is a platform-independent reason for doing so, then it should be
exported for all platform, by putting an EXPORT_SYMBOL() after
fs/ioctl.c:sys_ioctl().

	--david
