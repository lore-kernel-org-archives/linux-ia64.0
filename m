From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 15 Nov 2004 21:15:25 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02631765@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Here is what I am working on next:
>
>1. Save EFI memory map before it is trimmed.

This code has been "evolving" for a long time now, more layers
get addded to solve each new problem.  If you get time, please
step back about a half-mile and take a look at the big picture
and see you you can see a better way to do the scanning and
trimming and re-scanning.  The overall problem statement (ignore
anything except complete granules, honour the command-line arguments
max_mem/max_addr, allocate a temporary bitmap for bootmem) seems
like it shouldn't require such complex code :-)  You can add your
own new requirement to not modify the original EFI tables so that
they can be re-scanned by a new kernel after kexec (new kernel
might have a different granule size).

-Tony
