From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Aug 2008 00:21:09 +0000
Subject: RE: ia64 allmodconfig on current mainline
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30844B247@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080812150608.231a948a.akpm@linux-foundation.org>
	<200808130022.50501.rjw@sisk.pl>
 <20080812155806.4e8554a9.akpm@linux-foundation.org>
In-Reply-To: <20080812155806.4e8554a9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/bin/ia64-unknown-linux-gnu-ld: section .data [0000000004ea0000 -> 0000000004f656e7] overlaps section .data.percpu [0000000004e90000 -> 0000000004ea0d17]

This means there is too much DEFINE_PER_CPU() going on.  Current
ia64 limit for the sum of all per cpu objects is 64K.  For a
build using defconfig we seem to be close (56K/64K ... look for
the address of __per_cpu_end and see how close it is to the top
of the address space: 0xffffffffffffffff).

-Tony
