From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 26 Jul 2004 23:34:01 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <200407261634.01719.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, July 26, 2004 4:30 pm, David Mosberger wrote:
> >>>>> On Mon, 26 Jul 2004 16:09:51 -0700, David Mosberger
> >>>>> <davidm@linux.hpl.hp.com> said:
>
> Oops, the first sentence got garabled:  it was meant to say:

So we just need to avoid EFI boot time services in the kexec path, ok.  How 
about the kernel relocation question?

Thanks,
Jesse
