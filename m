From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Jan 2005 22:19:00 +0000
Subject: RE: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <16886.50644.522099.519989@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.59631.914927.689418@napali.hpl.hp.com>
In-Reply-To: <16877.59631.914927.689418@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 14:03:08 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This is using the tool chain on SLES9.  I ran the preprocessor
  Tony> over entry.S, and it does include the ".align 32" ... so the
  Tony> change should have had no effect.  Which means that something
  Tony> else I did today probably dropped the cycles :-(

I believe the exact data-cache layout can affect the basic
syscall-path quite significantly.  Thus, I can certainly see why
apparently unrelated changes could affect the syscall path.  Getting
better control over the data-layout would be nice (Ken's GP-relative
addressing work may a helpful step in that direction).

	--david
