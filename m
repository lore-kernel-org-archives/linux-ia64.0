From: n0ano@n0ano.com
Date: Wed, 12 Mar 2003 17:07:36 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Because 32K is not supported by the hardware and last time I tried
Linux had probllems with page sizes >= 64K.  The scsi code used
a bit map that blew up with large page sizes.  I know someone created
a patch to fix this problem but I don't know if it made it into the
official tree.

On Wed, Mar 12, 2003 at 05:38:44PM +0100, Jan Schreckenbach wrote:
> Hello,
> 
> why should the page size on Itanium 2 not bigger than 16KB?
> 
> Regards,
> Jan
> 
> -- 
> _______________________________________________________________________
> 
> THE BEST RUN E-BUSINESSES RUN SAP
> _______________________________________________________________________
> 
> Jan Schreckenbach                      email: Jan.Schreckenbach@sap.com
> SAP AG Walldorf/Baden, Germany         Phone: +49 6227  7-47474
> LinuxLab                               Fax  : +49 6227 78-31414
> 
> SAP LinuxLab support address: linux@sap.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/447-2201

