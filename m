From: Don Dugger <n0ano@n0ano.com>
Date: Wed, 30 Oct 2002 15:14:22 +0000
Subject: Re: [Linux-ia64] gdb'ing 32-bit executable on IA64
Message-Id: <marc-linux-ia64-105590709805293@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nitin-

Use an IA32 `gdb'.  The standard `gdb' on IA64 machines only deals with
IA64 processes.  All you have to do is copy `gdb' over from an IA32
machine and then use that to debug your IA32 processes.

On Wed, Oct 30, 2002 at 09:58:05AM -0500, Sane_Purushottam@emc.com wrote:
> When I try to run a 32-bit executable in gdb on a IA-64 linux (RH 7.2), I
> can set the breakpoint fine but when I try to run it, I get an error "Can't
> insert breakpoint for slot numbers greater than 2"
> 
> What's the solution ??
> 
> Nitin Sane
> sane_purushottam@emc.com
> (508) 382-7319
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

