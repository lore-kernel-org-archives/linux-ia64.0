From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 01 Aug 2003 14:20:17 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-105974763612882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
>   Alex> +# define SAL_CALL_SAFE(result,args...)
> 
> How about calling this SAL_CALL_REENTRANT() or something like that?
> SAFE isn't particularly meaningful and it's backwards from the
> caller's point of view (where SAL_CALL() is the safe macro to use...).

   Perhaps SAL_CALL_DANGEROUS() ;^)  Yes, I agree, the name is misleading
from the caller perspective.  SAL_CALL_REENTRANT() is a much better
choice.  Let me know if you want an updated patch.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
