From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Jun 2005 17:51:13 +0000
Subject: RE: gate page oops
Message-Id: <17064.33169.696364.968567@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Jun 2005 10:48:56 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Why do we need the holes?

  >> Because ia64 linux ELF images can only alias at a 64KB boundary (the
  >> max. supported kernel page size).

  Tony> This means that PERCPU_PAGE_SIZE is the wrong define for this.

That is true.  Lazy bastards, those programmers --- oh, wait, it was me! ;-)

	--david
