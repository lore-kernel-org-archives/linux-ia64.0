From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Jan 2005 21:56:03 +0000
Subject: RE: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <16886.49267.295673.732007@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.59631.914927.689418@napali.hpl.hp.com>
In-Reply-To: <16877.59631.914927.689418@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Jan 2005 13:52:09 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> So I switched over to TEXT_ALIGN(32) instead of ".align", but the
  Tony> speedup seems to have gone away (using TEXT_ALIGN is 6 cycles slower
  Tony> than ".align").

Probably a sign that your assembler needs to be upgraded?
Or are you saying the speedup goes away even though HAVE_WORKING_TEXT_ALIGN
is defined?

	--david
