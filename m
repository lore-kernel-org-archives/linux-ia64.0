From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 03 Jun 2006 18:43:17 +0000
Subject: RE: Montecito processor family
Message-Id: <617E1C2C70743745A92448908E030B2A3981@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That seems like a good reason for family and model to be
> numbers straight from the hardware.  Applications can key
> off the numbers.  Then the text "model name" string could 
> change without breaking applications.
> 
> vendor_id       : GenuineIntel
> cpu family      : 15
> model           : 4
> model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
> stepping        : 1

Using PAL_BRAND_INFO on Montecito I end up with this:

vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 0
model name : Intel(r) Itanium(r) 2 Processor 1.6GHz with 24M L3 Cache for 533MHz Platforms

Which is stylistically pretty similar (though somewhat more verbose
... PAL_BRAND_INFO allows for up to 127 characters + NUL so it could
get even chattier, but at least there is an upper bound).

-Tony
