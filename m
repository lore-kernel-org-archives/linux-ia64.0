From: Grant Grundler <iod00d@hp.com>
Date: Mon, 25 Aug 2003 17:05:32 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106183191904711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 25, 2003 at 10:21:03AM +0100, Christoph Hellwig wrote:
> Anyway, we should test explicitly for configurations supported by
> floppy.c.

yes - agreed

> So far this would be:
> 
> CONFIG_ISA
> CONFIG_M68K
> CONFIG_SPARC
> 
> any more?

CONFIG_GSC_LASI and CONFIG_SUPERIO in drivers/parisc/Kconfig.
Search for "Floppy" in  drivers/parisc/lasi.c and superio.c

Because of an on-going lawsuit, HP was not able to publish documentation
for LASI floppy controller (or it's bugs). We only have one cheesy
document for the NS87560UBD chip.

I don't recall any work was completed to enable floppy under those
chips but someone might want to take another whack at it in the future.

grant
