From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 27 Aug 2003 23:18:51 +0000
Subject: Re: 2.4.21+ Patch for non-identity mapped kernel (SGI SN)
Message-Id: <marc-linux-ia64-106202723411009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106122911803891@msgid-missing>
In-Reply-To: <marc-linux-ia64-106122911803891@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 18 August 2003 11:46 am, Jack Steiner wrote:
> Attached is a patch that makes arch/ia64/kernel/head.S work on the
> SGI SN system. The patch consists mostly of a backport of portions
> of the same file from 2.6. 
> 
> I tried to minimized differences between the new file & 2.6 as 
> opposed to minimizing differences between the new file & 2.4.21. 
> This makes the patch somewhat larger than needed but (I think) is 
> correct for the long term.
> 
> 
> The changes add support for non-identity mapped kernels. This patch
> does NOT change the kernel load address - it just adds support for the
> case where it was loaded into non-identity mapped memory.

I applied this, thanks.

