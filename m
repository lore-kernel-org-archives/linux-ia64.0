From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 Oct 2005 21:19:39 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <200510111519.39269.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 11 October 2005 2:00 pm, Mark Maule wrote:
> So we will dup some of the PCDP scan code in sn/kernel/setup.c for the time
> being.  Does anyone have a problem with moving drivers/firmware/pcdp.h under
> include/asm-ia64 so that I don't also have to dup the structure definitions?

I don't want to move pcdp.h under asm-ia64.  EFI (and, I hope,
PCDP) is coming to x86 soon.  There's nothing ia64-specific
in pcdp.h or pcdp.c, so I think it would be a mistake to
move it to an arch-specific directory.
