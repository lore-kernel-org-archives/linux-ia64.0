From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Oct 2004 19:32:45 +0000
Subject: RE: [RFC] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F022BFC3D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
>> Perhaps "zero_cache" isn't as descriptive a name as it might be (not
>> that I have any better suggestions :-(
>
>Maybe pgtable_zero_cache or something?

I thought along those lines at first, but actually this cache would be
useful for any allocation that needed a page that has been pre-zeroed.
So I don't think that the "pgtable" part is helpful.  Some sense of the
fact that the objects are one page big is what I was looking for.

-Tony
