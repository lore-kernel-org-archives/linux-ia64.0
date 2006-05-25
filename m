From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 May 2006 17:22:42 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0694084C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Has the br.ia completer been removed from the architecture? Or will
> it generate a trap which can be caught and the translator invoked?

Linux on Montecito will set the psr.di bit which will cause br.ia's and
jmpe's to create the disabled instruction set transition fault.

-Tony
