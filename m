From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Aug 2004 16:43:23 +0000
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01C61FFE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
>On Tuesday, August 3, 2004 6:45 am, Sourav Sen wrote:
>> Sorry to dig thigs up from the past, but when I apply
>> this against 2.6.6 and pass the nomca flag, I get MCA in
>> the boot path on sx1000 based systems of HP.
>
>Yeah, I think Ken pointed this out shortly after I posted the 
>patch.  I thought a fixed version made its way into the tree?  Tony?

I don't see any traces of it in the tree.

I think that the old version of the patch doesn't work with
the current tree because just skipping ia64_mca_init() won't
work now.  You'd still call mca_late_init() which would do
a few bad things not realizing that ia64_mca_init() hadn't
been called to prepare stuff.

-Tony 
