From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 28 Jul 2008 22:47:41 +0000
Subject: Re: [PATCH 1/5] Move elfcorehdr_addr out of vmcore.c (Was: Re: [patch] crashdump: fix undefined refe
Message-Id: <m1vdypfwxe.fsf@frodo.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au>
	<20080728015117.GA12055@verge.net.au>
	<20080728024526.GB3334@verge.net.au>
	<20080728034007.GA30450@verge.net.au>
	<20080728211025.GA9985@redhat.com>
In-Reply-To: <20080728211025.GA9985@redhat.com> (Vivek Goyal's message of
	"Mon, 28 Jul 2008 17:10:25 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org

Vivek Goyal <vgoyal@redhat.com> writes:

> Hi All,
>
> How does following series of patches look like. I have moved
> elfcorehdr_addr out of vmcore.c and pushed it to arch dependent section 
> of crash dump to make sure that it can be worked with even when
> CONFIG_PROC_VMCORE is disabled and CONFIG_CRASH_DUMP is enabled.
>
> I tested it on x86_64. Compile tested it on i386 and ppc64. ia64 and
> sh versions are completely untested.

Given the current state of the code:
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

To process a kernel crash dump we pass the kernel elfcorehdr option, so testing
to see if it was passed seems reasonable.

In general I think this method of handling the problems with kdump is
too brittle to live, but in the case of iommus we certainly need to do something
different, and unfortunately iommus were not common on x86 when the original code
was merged so we have not handled them well.

Eric
