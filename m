From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 Jan 2006 23:08:03 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0589270D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

But sadly it still says:

arch/ia64/sn/kernel/sn2/sn2_smp.c:110: warning: initialization discards qualifiers from pointer target type
arch/ia64/sn/kernel/sn2/sn2_smp.c:111: warning: ISO C90 forbids mixed declarations and code

The double ;; is responsible for error on 111, need an extra volatile on 110?

-Tony
