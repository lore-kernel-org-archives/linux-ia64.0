From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 29 May 2003 21:47:34 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706080@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

So some SAL records are platform related, and some
are tied to a specific CPU.  And different SAL
implementations might fuzz the issue further by
making cpu dependent records visible at the platform
level.

Stepping back from this (a few miles) for a broader
view.  What benefit do we gain at the application
level by making all the mca/init/cmci/cpei files
visible on a per-cpu basis?

For platform level errors, this just causes confusion
as the same record is definitely available on all cpus.
But if your application is "poll"ing all the files, only
one needs to read&clear.

For cpu-level errors (assuming that a SAL implementation
keeps them in separate queues) ... I'm not certain why
the application needs to be able to read from a cpu-spcific
file.  If all the error records were funneled into a
single file, would we lose anything?

-Tony

