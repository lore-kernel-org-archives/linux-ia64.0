From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 22:49:14 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 arch/ia64/kernel/smpboot.c
Message-Id: <marc-linux-ia64-105590723705518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705320@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705320@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 26 March 2003 9:27 am, Jes Sorensen wrote:
> A small patch for 2.4 that stops the kernel from trying to syncrhonize
> ITC clocks between CPUs if we know that the ITC isn't synchronized
> across the backplane.
> 
> The patch is relative to 2.4.21-pre5-bjorn, but I believe it should
> apply directly to 2.5.x as well.

I applied this to 2.4.

