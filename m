From: Jack Steiner <steiner@sgi.com>
Date: Tue, 13 Jul 2004 14:54:13 +0000
Subject: Re: fix memory corruption/crash for physical-mode EFI calls
Message-Id: <20040713145413.GA25989@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16623.29412.381259.793452@napali.hpl.hp.com>
In-Reply-To: <16623.29412.381259.793452@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 09, 2004 at 09:39:00PM -0700, David Mosberger wrote:
> Jesse,
> 
> I think you'll want to try out the patch below.  If my guess is
> correct and the SGI firmware doesn't support switching into virtual
> mode, then this may fix the boot-problem you are seeing on SN2.

FYI, I looked at the SGI boot failures that are occurring on recent 2.6 kernels
that have INIT_TASK in region 5. The boot failures are caused by a bug in our
PROM. It incorrectly assumes that the stack is identity mapped.
(Dont ask... :-)

Moving the stack to region 5 causes an OOPs in some PAL calls. It
goes downhill from there - sending signals to processes early
in boot before kmem is initialized doesnt get very far. The result is 
an MCA that has nothing to do with the original failure but adds a lot
of confusion.

We'll fix our PROM....


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


