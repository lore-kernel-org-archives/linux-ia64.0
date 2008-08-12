From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 12 Aug 2008 22:58:06 +0000
Subject: Re: ia64 allmodconfig on current mainline
Message-Id: <20080812155806.4e8554a9.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080812150608.231a948a.akpm@linux-foundation.org>
	<200808130022.50501.rjw@sisk.pl>
In-Reply-To: <200808130022.50501.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 13 Aug 2008 00:22:50 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Wednesday, 13 of August 2008, Andrew Morton wrote:
> > /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/bin/ia64-unknown-linux-gnu-ld: section .data [0000000004ea0000 -> 0000000004f656e7] overlaps section .data.percpu [0000000004e90000 -> 0000000004ea0d17]
> > make: *** [.tmp_vmlinux1] Error 1
> 
> I gather this is a regression from .26?

yes, more recent than that, actually.  2.6.27-rc1-mm1 was OK.
