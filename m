From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jan 2006 21:15:25 +0000
Subject: RE: [patch] add syscall entry for *at()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0595CFD0@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601312049.k0VKnsg08813@unix-os.sc.intel.com>
In-Reply-To: <200601312049.k0VKnsg08813@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Wire up the ia64 syscalls.

You should really add some more zeroes at the end
of fsys.S too just to keep things in step.

Also, I was hoping that some sort of sanity test for these
syscalls would appear (perhaps just to check for silly typos).

-Tony
