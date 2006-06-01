From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 Jun 2006 16:32:39 +0000
Subject: RE: Montecito processor family
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06A38223@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Why not have "model name" with the text name, like on ia32?
> 
> vendor_id       : GenuineIntel
> cpu family      : 15
> model           : 4
> model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
> stepping        : 1

This sounds like an excellent plan.  We can even use the new
(in SDM2.2 p. 2:345) PAL_BRAND_INFO call to get the right
(Intel marketting/legal approved) string.  For older systems
that don't implement PAL_BRAND_INFO we could have some fallback
code that decodes family/model to Merced/McKinley/Madison.

-Tony
