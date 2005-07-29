From: Khalid Aziz <khalid_aziz@hp.com>
Date: Fri, 29 Jul 2005 19:40:06 +0000
Subject: Re: [PATCH] /proc/iomem update
Message-Id: <1122666006.20867.38.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1DyZJE-0006Au-00@lyra.fc.hp.com>
In-Reply-To: <E1DyZJE-0006Au-00@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That "continue" is intentional and you are right, it will cause memory
leak. It should be preceded by kfree(res). I will fix that.

Thanks,
Khalid

On Fri, 2005-07-29 at 11:22 -0700, david mosberger wrote:
> Is the "continue" here spurious?  If not, it would cause
> memory-leaking since "res" has been allocated already.
> 
> +                       case EFI_MEMORY_MAPPED_IO:
> +                       case EFI_MEMORY_MAPPED_IO_PORT_SPACE:
> +                               continue;
> +                               break;
> 
>   --david
-- 

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

