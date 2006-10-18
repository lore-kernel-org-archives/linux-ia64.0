From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 18 Oct 2006 00:30:11 +0000
Subject: RE: [Patch] remove some rsm psr.dt in ivt.S
Message-Id: <000001c6f24c$92b109b0$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1161123027.2592.63.camel@linux-znh>
In-Reply-To: <1161123027.2592.63.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote on Tuesday, October 17, 2006 3:10 PM
> The rsm psr.dt in page_not_present, key_permission, iaccess_rights and
> daccess_right are not necessary. 
> Since there is no data access between those points to page_fault, and
> page_fault will enable psr.dt at the beginning.
> 
> @@ -1221,10 +1219,8 @@ END(page_not_present)
>  ENTRY(key_permission)
>  	DBG_FAULT(21)
>  	mov r16=cr.ifa
> -	rsm psr.dt
>  	mov r31=pr
>  	;;
> -	srlz.d
>  	br.sptk.many page_fault
>  END(key_permission)


You can get rid of that stop bit too.  Same for two other instances.
And your changelog mentioned daccess_right, but patch missed that hunk.

- Ken
