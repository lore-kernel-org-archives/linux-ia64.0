From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 May 2004 10:25:19 +0000
Subject: RE: Who owns those locks ?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F013CCAED@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org>
In-Reply-To: <40A1F4BE.4A298352@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>The current task pointers are identity mapped memory addresses.
>I shift them to the right by 12 bits (these bits are always 0-s).
>In that way, addresses up to 16 Tbytes can fit into the lock word.

Neat trick.  Will work for most people ... but watch out if you
have an architecture that has sparse physical address space and
can thus potentially allocate a task structure on a 16TB boundary.

At first I thought SGI Altix could be hurt by this, but they are
saved by the fact that bits [37:36] are always set to one.

I know of at least one 1TB machine now, so 16TB machines are only
a few years away.  You could stretch the life of this patch by
using PAGE_SHIFT, rather than 12 (as practically nobody builds
kernels with a 4k pagesize, especially not on monster machines).

Or perhaps just fix the allocation of task structures to skip
around the 16TB aligned ones?

-Tony
