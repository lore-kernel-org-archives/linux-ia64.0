From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Aug 2005 23:00:11 +0000
Subject: RE: efi_memmapwalk re-write
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F040F741A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F040F73E2@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>addresses up to granule boundaries and the tops down.  All that scanning
>around looking for holes or non-WB sections of memory looks pointless to
>me ... perhaps I'm missing some incredible subtlety in the original?

Duh.

Ok ... it is a bit more complex than I make it appear because there
are regions of WB memory that aren't usable by Linux ... they shouldn't
stop Linux from using granules that contain such blocks.

-Tony
