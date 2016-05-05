From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 05 May 2016 19:59:28 +0000
Subject: RE: [PATCH 0/5] ia64: Fix compiler warnings
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A0BFAE2@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt@codeblueprint.co.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>  ia64/PCI: Fix incorrect PCI resource end address
>  ia64/PCI: Remove unused 'addr' and fix build warning
>  ia64: Reduce stack usage by iterating over nodemask
>  ia64/traps: Silence GCC warning about uninitialised variable
>  ia64/unaligned: Silence another GCC warning about an uninitialized variable

Applied all 5.  I was a little leery of the two that added "default:" cases
to switches ... but I don't see a cleaner way to unconfuse the compiler
without a more radical restructuring of the code.

Thanks

-Tony
