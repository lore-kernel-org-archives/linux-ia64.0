From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 17:22:46 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Sep 2001 18:57:15 +0200, Christoph Hellwig <hch@ns.caldera.de> said:

  Christoph> It does.  On Linux-ABI I use e.g. /emul/osr5, /emul/uw7
  Christoph> and /emul/svr4.  Id suggest using /emul/<opsys> for
  Christoph> emulations of another operating system for the same
  Christoph> architecture, /emul/<arch>-<opsys> for non-native.

  Christoph> Windows should go into /emul/win64 and /emul/ia32-win32.

Sounds reasonable.  /emul/ia32-linux should be it, then.

	--david

