From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 15:49:49 +0000
Subject: Re: [Linux-ia64] swiotlb on rx4610, again
Message-Id: <marc-linux-ia64-105590723705532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705531@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705531@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 17 April 2003 7:06 am, Matthieu Delahaye wrote:
> Hi guys,
> 
> I have two rx4610 which ran well until last week under Linux for more than
> one year.
> They ran with first an unstable and then a stable Debian Woody with the
> standard stock kernel (2.4.17) provided by Debian.
> I didn't change their hardware configuration since.
> 
> Thanks to an ext3 filesystem crash, I had to reinstall Linux on. Using
> the same standard process I always used, no way this time to complete
> the installation:
> Kernel panic: map_single could not allocated software IO TLB (42 bytes)
> In interrupt handler - not syncing
> Looking on the second one I have, same problem.

Can you give us a little more information about what kernel you're
trying to reinstall?  Often the installer uses a different kernel than
the one you end up running, so perhaps the install kernel is broken.
If you're reinstalling Debian,  you might get more knowledgeable help
on debian-ia64@lists.debian.org.

Bjorn


