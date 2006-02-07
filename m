From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 07 Feb 2006 22:43:44 +0000
Subject: Re: [2.6 patch] IA64_GENERIC shouldn't select other stuff
Message-Id: <20060207224344.GF1601@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207221157.GA3524@stusta.de> <9883.1139351831@ocs3>
In-Reply-To: <9883.1139351831@ocs3>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Adrian Bunk <bunk@stusta.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 08, 2006 at 09:37:11AM +1100, Keith Owens wrote:
> A generic IA64 kernel requires (at least) the ACPI and NUMA options in
> order to run on all the IA64 platforms out there.  Omitting those
> options and relying on the user to set them by hand is going to cause
> more problems.

I'm not sure about that.  If the user selects a specific type of machine,
ACPI doesn't get selected for them -- even when it's needed to boot.
It's certainly inconsistent and should be fixed one way or the other.
