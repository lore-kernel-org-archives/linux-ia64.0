From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 01 Dec 2003 17:42:03 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) testing report
Message-Id: <marc-linux-ia64-107030079310016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106985955514249@msgid-missing>
In-Reply-To: <marc-linux-ia64-106985955514249@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 26 November 2003 8:14 am, Matthew Wilcox wrote:
> On Wed, Nov 26, 2003 at 11:12:04PM +0800, Yu, Luming wrote:
> > 1. Failed to bk pull  http://linux-acpi.bkbits.net/linux-acpi-test-2.4.22  , Error message was
> > 
> > 	" Entire  repository is locked by:
> > 		RESYNC directory.
> > 	ERROR-Unable to lock repository for update"
> 
> This problem's at your end; you need to do some BK magic to fix it.
> I don't use BK myself, but I'm sure somebody else can tell you how to
> fix it.

I think this means a previous "bk pull" is incomplete because it found
changes that need to be merged manually.  You should be able to use
"bk resolve" to finish that merge, then retry the new "bk pull".

