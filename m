From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 17 Oct 2002 08:19:30 +0000
Subject: Re: [Linux-ia64] Some Modules fail w/ unresolved cpu_info__per_cpu
Message-Id: <marc-linux-ia64-105590709805178@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805176@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805176@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Oct 2002 09:45:48 +0200, 
Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net> wrote:
>I found that the exported symbol name via /proc/ksyms is in fact:  
>  cpu_info__per_cpu_R__ver_cpu_info__per_cpu
>
>Then I did not ask much more questions to me trying to find the root
>cause of the problem within the kernel sources and I just added the 
>following trivial modification in the driver's code:
>#define cpu_info__per_cpu   cpu_info__per_cpu_R__ver_cpu_info__per_cpu
>
>With this workaround insmod didn't complain anymore about "cpu_info__per_cpu"
>and the driver works correctly.
>
>But I am agree it is just a workaround and we shouldn't have to
>modify drivers's code for such problem.

Arrghh, don't do that!  FAQ: http://www.tux.org/lkml/#s8-8.


