From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Apr 2002 21:42:28 +0000
Subject: RE: [Linux-ia64] Patch to fix lfetches accessing beyond a page (c
Message-Id: <marc-linux-ia64-105590701905478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905475@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905475@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Apr 2002 13:35:13 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> But I also think that the code should not access memory beyond
  Asit> the page even though it does not affect the functionality as
  Asit> these are hints. These accesses can also cause performance
  Asit> problems.

Ah, now *that's* an argument I can live with. ;-)

I just don't want there to be any confusion about whether or not
lfetch to arbitrary addresses is legal.  It must be, as hardware is
allowed to prefetch on its own.

	--david

