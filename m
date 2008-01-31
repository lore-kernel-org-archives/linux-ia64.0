From: Avi Kivity <avi@qumranet.com>
Date: Thu, 31 Jan 2008 17:07:23 +0000
Subject: Re: [kvm-devel] [PATCH] [00]Patch set to enable kvm on ia64 platforms
Message-Id: <47A2004B.7090703@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FC3@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCD31FC3-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Zhang, Xiantao wrote:
> Hi, Avi/Tony
> 	We have rebased kvm/ia64 code to latest kvm. In this version, we
> have fixed coding style issues, and all patches can pass checkpatch.pl,
> except one assembly header file, which is copyied from kernel, so we
> didn't change its issues. 
> Compared with last version, we implemented smp guest support, and
> addressed two stability issues which only take on with smp guests.  Now,
> based on our own test results, it has good stability, and good
> performance. Please review and help to commit them before linux 2.6.25
> merge :)
>  
>   

I suggest that Tony review, signoff, and push these through the ia64 
tree once kvm.git has been pulled (pull request was sent yesterday).  
Once that's in, incremental updates can go through kvm.git.  I am simply 
not qualified to review ia64 code.

-- 
error compiling committee.c: too many arguments to function

