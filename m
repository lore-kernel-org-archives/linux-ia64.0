From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 02 Oct 2001 17:32:22 +0000
Subject: Re: [Linux-ia64] pfmon runs halted a system (2.4.9 kernel)
Message-Id: <marc-linux-ia64-105590698805294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 02, 2001 at 10:00:30AM -0700, Choi, Youngsoo wrote:
> Hi,
> We are running RedHat 7.1 Linux on an Itanium BigSur with 2.4.9 kernel.
> When we ran some benchmarks with pfmon, the system often halted and needed
> rebooting, especially when the running script was executed from rlogin
> session. Running from console did not cause the problem as much, but some.
> Is there any way to trace where it occurs and what's the reason?
> Is pfmon more stable with 2.4.10 kernel without any other issues?
> 

Could you give more details as to what you were trying to measure on which
program, what are the console messages. You can turn on perfmon kernel
debugging messages by using pfdbg --on. This program is part of the pfmon
package. I can't say if 2.4.10 would buy you anything until I get more infos
on your problem.

-- 
-Stephane

