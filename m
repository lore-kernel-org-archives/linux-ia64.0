From: "Aneesh Kumar K.V" <aneesh.kumar@digital.com>
Date: Mon, 07 Oct 2002 10:09:36 +0000
Subject: Re: [Linux-ia64] sigcontext structure
Message-Id: <marc-linux-ia64-105590701906087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 

Using sigaction with siginfo will help you in catching those address. 

siginfo.si_addr carry the faulting  address 

and  the below statement shows how it is calcluated  
siginfo.si_addr = (void *) (regs->cr_iip + ia64_psr(regs)->ri); 

where regs is pt_regs. 



-aneesh 


On Sun, 2002-10-06 at 23:13, shiva chetan wrote:
> where can i find info on sigcontext structure on linux/ia-64 ?
> specifically which registers hold the faulting address/type on a
> segmention fault and the trap no on a SIGTRAP ?
>  
> thanks
> chetan



