From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Mon, 19 May 2003 20:16:52 +0000
Subject: RE: [Linux-ia64] MSIX Support.
Message-Id: <marc-linux-ia64-105590723705953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705951@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705951@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We posted a patch for MSI/MSI-X support to the kernel mailing list recently. Although it was for x86 (as far as the patch is concerned), I believe we should have the same interfaces to drivers. Please take a look at msi_alloc/fee_vectors(), for example, to support multiple messages.

Thanks,
Jun

> -----Original Message-----
> From: Colin Ngam [mailto:cngam@sgi.com]
> Sent: Monday, May 19, 2003 12:55 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] MSIX Support.
> 
> 
> Hi,
> 
> Has there been any discussion or work done in this
> area with regards to interfaces provided to drivers
> for MSIX?
> 
> Thanks.
> 
> colin
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

