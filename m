From: Grant Grundler <iod00d@hp.com>
Date: Mon, 19 May 2003 21:34:59 +0000
Subject: Re: [Linux-ia64] MSIX Support.
Message-Id: <marc-linux-ia64-105590723705954@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705951@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705951@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 19, 2003 at 01:16:52PM -0700, Nakajima, Jun wrote:
> We posted a patch for MSI/MSI-X support to the kernel mailing list recently.

Cool!
Can you provide the patch or a URL?
Google couldn't find "msi_alloc" when explicitly searching lkml archives.

> Although it was for x86 (as far as the patch is concerned), I believe
> we should have the same interfaces to drivers.

yes. I think ia32, ia64, parisc, and alpha can all support MSI.
Maybe others too.

thanks,
grant

