From: Jim Garlick <garlick@llnl.gov>
Date: Thu, 01 Apr 2004 03:23:50 +0000
Subject: Re: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <Pine.LNX.4.30.0403311923080.29860-100000@cleomedes.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 31 Mar 2004, Bjorn Helgaas wrote:

> On Tuesday 30 March 2004 11:43 pm, Francois Wellenreiter wrote:
> > All the processors call the "ia64_monarch_init_handler",
> > the result is that the same trace appears many times (1 per CPU in fact)
> > and a kernel oops occurs (I think it is due to a concurrent access
> > to the same stack without any lock mechanism).
>
> What kind of machine is this?  Linux registers different OS_INIT
> procedures for the monarch and non-monarch processors, so it
> sounds like a SAL bug if more than one CPU calls
> ia64_monarch_init_handler().

We see this also on Intel Tiger4's.

Jim

