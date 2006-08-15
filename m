From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 15 Aug 2006 22:36:57 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155681417.2585.70.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-08-16 at 03:15, Jay Lan wrote:
> Zou Nan hai wrote:
> > On Tue, 2006-08-15 at 09:56, Jay Lan wrote:
> > 
> >>Bob Montgomery wrote:
> >>
> >>>On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
> >>>
> >>>
> >>>>This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
> >>>
> >>>
> > 
> > 
> WARNING: can't access
> exec of init () failed!!!: No such file or directory
> 
> 
  Did you pass the correct kernel parameter to --append?
  It seems that root filesystem was not able to be mounted.

> Regards,
>   - jay

  Thanks
  Zou Nan hai
