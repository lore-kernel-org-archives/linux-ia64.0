From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Jan 2005 22:03:08 +0000
Subject: RE: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CA9FD1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.59631.914927.689418@napali.hpl.hp.com>
In-Reply-To: <16877.59631.914927.689418@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Probably a sign that your assembler needs to be upgraded?
>Or are you saying the speedup goes away even though 
>HAVE_WORKING_TEXT_ALIGN is defined?

This is using the tool chain on SLES9.  I ran the preprocessor
over entry.S, and it does include the ".align 32" ... so the
change should have had no effect.  Which means that something
else I did today probably dropped the cycles :-(

-Tony
