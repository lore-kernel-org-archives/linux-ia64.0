From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 27 Aug 2003 15:54:52 +0000
Subject: Re: Problems compiling kernel 2.4.18 patched with the latest patch
Message-Id: <marc-linux-ia64-106199999210342@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106197620015702@msgid-missing>
In-Reply-To: <marc-linux-ia64-106197620015702@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 26 August 2003 3:20 pm, Nagendra Singh Tomar wrote:
> The kernel is 2.4.18 taken from kernel.org
> Patch applied is linux-2.4.18-ia64-020722.diff taken from
> http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
> I get the following error 
> 
> /tmp/newhd/usr/src/linux-2.4.18-ia64/include/asm/machvec.h:82:12: pasting 
> "machvec_hpsim" and "." does not give a valid preprocessing token
> 
> The detailed compilation log can be found at the end of this mail. I have 
> made a cross compiler tool-chain on a IA32 system, running RedHat-8.0.
> I searched in the archives. Looks like people have faced this problem, but 
> it was fixed. Is it fixed for 2.4.18 or do I need a later kernel.

I assume you found this message in the archives:
http://www.gelato.unsw.edu.au/linux-ia64/0206/3530.html

I don't think the 2.4.18 patch was ever updated, so you probably
can't build a 2.4.18 generic kernel unless you want to apply the
machvec and sba_iommu patches.

That's a pretty old kernel, and the generic target was just starting
to come together then.  But I assume you have a good reason for
wanting to use such an old kernel.

Bjorn

