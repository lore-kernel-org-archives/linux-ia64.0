From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 22 Jul 2004 17:57:53 +0000
Subject: Re: Altix I/O code re-org
Message-Id: <200407221357.53404.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com>
In-Reply-To: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, hch@infradead.org, linux-kernel@vger.kernel.org

On Thursday, July 22, 2004 11:14 am, Pat Gefre wrote:
> We have redone the I/O layer in the Altix code.
>
> We are posting this code for review before submitting for
> inclusion in the 2.5 tree.
>
> The code can be seen at:
> ftp://oss.sgi.com/projects/sn2/sn2-update/
>
> The general changes are:
> o added new hardware support
> o ran all code thru Lindent
> o code cleanup (typedefs, include files, etc.)
> o simplified the directory structure (all files under arch/ia64/sn/io/
>   are deleted, new files are under arch/ia64/sn/ioif/)
> o code size reduced by >50%
> o major reorg of the code itself
> o copyright updates

One of the most important changes this patch makes is to rip out all of the 
SGI PCI probing code.  Our PROM now probes for I/O devices and tells the 
kernel where they are (similar to the ACPI model, which we may get to 
eventually).  The result is much more readable code with less duplication.  
Please take a look and let us know if you have any feedback, since we'd like 
to get this in as soon as we release a PROM that supports probing.

Thanks,
Jesse
