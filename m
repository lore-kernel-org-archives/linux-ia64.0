From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 09 Feb 2005 22:32:28 +0000
Subject: Re: porting to ia64
Message-Id: <2307.1107988348@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107986903.23187.23.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1107986903.23187.23.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 09 Feb 2005 17:08:23 -0500, 
Eric Desjardins <eric.desjardins@discreet.com> wrote:
>Hi,
>
>I'm not to familiar with kernel code but I'm trying to port a kernel
>driver from x86 to ia64.
>
>I was just wondering how should I translate that:
>
>static int interrupts_blocked()
>{
>   unsigned long flags = 0;
>                                                                                                        
>   __save_flags(flags);
>  
>   return (flags & X86_EFLAGS_IF) =
>0;                                                                                                 
>}

if (irqs_disabled()) { ... } works on all platforms.  Your driver does
not need to define its own function.

