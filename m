From: Horms <horms@verge.net.au>
Date: Mon, 30 Oct 2006 09:11:26 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061030091126.GB21894@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 27, 2006 at 10:15:16AM +0100, Andy Whitcroft wrote:
> Hi,
> 
> Mel and I spent a bit more time thinking about this.  If the efi map is
> being modified such that the kernel area becomes loader data that may
> well move up the start of conventional memory as far as the running
> kernel is concerned.
> 
> [Apologies in advance if Zou is not an appropriate name.]
> 
> It would be helpful both to have a dump of the efi map and the start
> address of the kernel from the affected machine (Horms) and if possible
> the efi map and start address of the kernel from your working test
> platform (Zou).  Also, if we could get the boot logs from a conventional
> kernel and the kexec kernel from the working test platform (Zou).

Below is a log of 05e0caad3b7bd0d0fbeff980bca22f186241a501 + kexec.
It shows the initial successful boot and kdump with oopses. I enabled
EFI_DEBUG which prints out the efi map. And just before that
I added some code to print out the value of _start. If this is not
what you need please let me know.

I can also produce logs for 05e0caad3b7bd0d0fbeff980bca22f186241a501
without kexec, or with 05e0caad3b7bd0d0fbeff980bca22f186241a501 reversed
if you like.

> A logical next step might be to bodge things such that we offer up the
> kernel image as an active range and see if that sorts out the alignment
> issue we are seeing, this will allow us to be certain it is the kernel
> image in this area.  Something like the following inserted into
> register_memory() might work:
> 
> 	add_active_range(0, code_resource.start >> PAGE_SHIFT,
> 			    data_resource.end >> PAGE_SHIFT);
> 
> Not sure this is the right thing as a fix, but would help confirm the
> theory.

I will poke around with that. Though it will probably be tomorrow.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

