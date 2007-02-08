From: Jay Lan <jlan@sgi.com>
Date: Thu, 08 Feb 2007 21:48:56 +0000
Subject: Re: [PATCH 2/2] [IA64] Add phys_efi command line option
Message-Id: <45CB9AC8.4000204@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070207062420.GB29959@verge.net.au>
In-Reply-To: <20070207062420.GB29959@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote:
> Hi,
> 
> I am resending this patch, which builds on the patch sent earlier
> in this thread to allow physical mode SAL/EFI to work.
> 

Hi Horms,

Do you plan to introduce this new option as a default to kexec in non-
Linux<->Xen kexec situations? We are concerned because physical mode
SAL/EFI calls do not currently work on SN platform.

Thanks,
 - jay

