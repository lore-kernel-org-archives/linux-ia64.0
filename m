From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 Nov 2003 13:13:28 +0000
Subject: Re: Incorrect definition of pal cache_check info
Message-Id: <marc-linux-ia64-106803805524254@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106801411302949@msgid-missing>
In-Reply-To: <marc-linux-ia64-106801411302949@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 05 Nov 2003 17:34:19 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>Both 2.4 and 2.6 kernels define struct pal_cache_check_info_s as
>...
>which bears very little resemblance to the Cache_Check layout described
>in Intel Itanium Architecture Software Developer's Manual Volume 2:
>System Architecture, under PAL_MC_ERROR_INFO.  It looks like struct
>pal_tlb_check_info_s is wrong as well.  What gives?

Answering my own question.  Some of the PAL structure definitions are
from PAL_MC_ERROR_INFO revision 1.0, the kernel has not been corrected
for revision 2.1.

