From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Dec 2005 21:08:15 +0000
Subject: RE: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F053928F5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I do recognize that this doesn't cover all the current uses of
>> ia64_platform_is(), but it covers a pretty big chunk of them.
>> 
>
>Which prolly means that I should continue with the solution that was 
>previously put forward.

Not necessarily.  If all the device uses can be fixed with a fake
ACPI table, and if the remaining cases all fall into just a couple
of the six other init levels, then it might be sufficent to just make
sn_init functions for the two levels that are used.

You may need this as a backup plan anyway, the "tuples in the init
table" only has a limited chance of success of getting accepted into
mainline.  Depends on how pretty it comes out, and whether anyone
other than ia64 will actually use it.

-Tony 
