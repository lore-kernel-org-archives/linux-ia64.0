From: Andi Kleen <ak@suse.de>
Date: Wed, 03 Mar 2004 23:28:44 +0000
Subject: Re: ia32 sigwait patch
Message-Id: <20040304002844.3e3f1d80.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403031606.16257.bjorn.helgaas@hp.com>
In-Reply-To: <200403031606.16257.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 3 Mar 2004 16:06:16 -0700
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> It looks to me like current 2.4 on x86_64 suffers from the same
> problem with uts (sys_rt_sigtimedwait() gets a pointer to
> uninitialized "t" when uts is NULL).

Yes, indeed. Thanks for the hint.

-Andi

