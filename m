From: Keith Owens <kaos@sgi.com>
Date: Wed, 13 Sep 2006 09:54:41 +0000
Subject: Re: [PATCH]Make gp value point to Region 5 in mca handler
Message-Id: <6559.1158141281@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158123325.2591.46.camel@linux-znh>
In-Reply-To: <1158123325.2591.46.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai (on 13 Sep 2006 12:55:25 +0800) wrote:
>MCA dispatch code take physical address of GP passed from SAL, 
>then call DATA_PA_TO_VA twice on GP before call into C code.
>The first time is in ia64_set_kernel_register, the second time is in
>VIRTUAL_MODE_ENTER.
>The gp is changed to a virtual address in region 7 because DATA_PA_TO_VA
>is implemented 
>by dep instruction. 
>
>However when notify blocks were called from MCA handler code, 
>because notify blocks are supported by callback function pointers, 
>gp value value was switched to region 5 again. 
>
>
>The patch set gp register to kernel gp of region 5 at entry of MCA
>dispatch.
>
>Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

The idea is right, but there is no need to pass __gp to
VIRTUAL_MODE_ENTER.  There will never be a case of VIRTUAL_MODE_ENTER
followed by entry to a module, so just hard code 'movl r1 = __gp' into
VIRTUAL_MODE_ENTER and drop it from the parameter list.


