From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Mar 2004 19:29:30 +0000
Subject: RE: Issues regarding memory hole.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FB1E0@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CC7A2BA2F1CA9E43B2B62C4783B42C7BE2E7D7@blr-ec-msg05.wipro.com>
In-Reply-To: <CC7A2BA2F1CA9E43B2B62C4783B42C7BE2E7D7@blr-ec-msg05.wipro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I am booting with the 2.6.1 kernel on Itanium2 machine.
>The page granularity is set to 16MB for the kernel. 
>
>After normal boot of the kernel, I observe a memory hole 
>from 1-16MB. Why is this usable memory region discarded 
>as a memory hole? 

1-16MB is discarded on many machines because of the PC
compatible VGA memory mapped in the bottom 1MB.  The Linux
ia64 kernel requires that *all* of a granule be real memory,
all of the granule must be cacheable too.

-Tony
