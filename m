From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 19:13:57 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <200412161113.58224.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com> <200412161107.57457.jbarnes@engr.sgi.com> <16833.56805.348569.77624@napali.hpl.hp.com>
In-Reply-To: <16833.56805.348569.77624@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz, davidm@hpl.hp.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thursday, December 16, 2004 11:11 am, David Mosberger wrote:
> >>>>> On Thu, 16 Dec 2004 11:07:56 -0800, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>
>   Jesse> On Thursday, December 16, 2004 10:56 am, Jesse Barnes wrote:
>
>   Jesse> Maybe this is a little better?
>
> The ia64_pci_legacy_{read,write}() functions definitely look much
> better, except I don't think you need any casts in the outX() calls.

You're right, I've removed them.

Thanks,
Jesse
