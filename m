From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 24 Jun 2004 15:34:58 +0000
Subject: Re: [PATCH]netpoll.c unaligned access
Message-Id: <200406240934.58369.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40DA8FC8.FEF0D430@Bull.Net>
In-Reply-To: <40DA8FC8.FEF0D430@Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 24 June 2004 2:24 am, Benoit Welterlen wrote:
> I use netpoll (net/core/netpoll.c) to send dump over the network on IA64
> (LKCD). But I have "unaligned access" in the netpoll_send_udp function.
> I rewrited it to avoid this message :

Please read Documentation/SubmittingPatches (in the Linux kernel
source tree) and post a patch (output of "diff -u") as outlined
there.
