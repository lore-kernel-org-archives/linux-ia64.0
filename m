From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Aug 2000 21:27:05 +0000
Subject: Re: [Linux-ia64] [PATCH] fix for modules_install
Message-Id: <marc-linux-ia64-105590678205349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205329@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205329@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Aug 2000 09:06:39 -0700, Keith Owens <kaos@ocs.com.au> said:

  Keith> arch/ia64/tools/Makefile should include Rules.make instead of
  Keith> adding its own target and .PHONY rules.  see
  Keith> arch/mips/tools/Makefile.  AFAICT there is no reason not to
  Keith> include Rules.make.

I'd be happy to make the change _if_ it's really safe to do so.  We're
doing some weird build tricks in a cross-build environment and I want
to make sure we don't break that code.

	--david

