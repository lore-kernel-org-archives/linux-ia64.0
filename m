From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Feb 2005 14:45:09 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2C9DF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I am completely dropping the proc_state_dump data area and 90% of the
>code in os_mca_dump/restore.  Instead of saving everything in sight, I
>create a struct pt_regs from the current registers plus some data from
>the min_state_save area.  That has three benefits - it gets rid of the
>special case RSE stack frame, it gives a real pt_regs for unwinding
>through the MCA handler and it guarantees that we save the required set
>of registers.
>
>Work in progress, I should have a patch by Monday.

I should have added that my ugly fp-saving band-aid patch was
just intended for temporary use (small enough to take in this
late stage of 2.6.11-rcN development).  Treating MCA as just
another interrupt sounds to be *much* cleaner.  I look forward
to seeing the patch.

-Tony
