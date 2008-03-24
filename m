From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 24 Mar 2008 21:25:11 +0000
Subject: RE: larger default page sizes...
Message-Id: <1FE6DD409037234FAB833C420AA843ECE5B88C@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com><20080321.145712.198736315.davem@davemloft.net><Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com> <20080324.133722.38645342.davem@davemloft.net>
In-Reply-To: <20080324.133722.38645342.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

> The memory wastage is just rediculious.

In an ideal world we'd have variable sized pages ... but
since most arcthitectures have no h/w support for these
it may be a long time before that comes to Linux.

In a fixed page size world the right page size to use
depends on the workload and the capacity of the system.

When memory capacity is measured in hundreds of GB, then
a larger page size doesn't look so ridiculous.

-Tony
