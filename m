From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Feb 2005 20:38:06 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2C43E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can pgtable_cache_init() be "__init"?

Do you have some before/after numbers from lmbench fork overhead
(I wouldn't expect much impact from this, but it would be nice to
make sure).

-Tony
