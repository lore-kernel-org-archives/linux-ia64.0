From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Aug 2003 18:21:03 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106002128205017@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 4 Aug 2003 10:53:08 -0700, "H. J. Lu" <hjl@lucon.org> said:

  HJ> Does it work on bigsur?

It should, apart from a qla1280.c glitch (see the latest ia64 diff for
the one-liner to get it to work; Jes Sorensen said he's going to
cleanup qla1280 for real).

  HJ> Does it support kernel modules?

Sure.  Kernel modules have been working for a while.  You do need
module-init-tools, of course (Debian has the necessary package in the
"unstable" tree).

	--david
