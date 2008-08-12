From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Tue, 12 Aug 2008 22:22:50 +0000
Subject: Re: ia64 allmodconfig on current mainline
Message-Id: <200808130022.50501.rjw@sisk.pl>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080812150608.231a948a.akpm@linux-foundation.org>
In-Reply-To: <20080812150608.231a948a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wednesday, 13 of August 2008, Andrew Morton wrote:
> /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/bin/ia64-unknown-linux-gnu-ld: section .data [0000000004ea0000 -> 0000000004f656e7] overlaps section .data.percpu [0000000004e90000 -> 0000000004ea0d17]
> make: *** [.tmp_vmlinux1] Error 1

I gather this is a regression from .26?
