From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Sat, 18 Jan 2003 03:04:55 +0000
Subject: RE: [Linux-ia64] [Patch] Fix in process.c
Message-Id: <marc-linux-ia64-105590709805724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi David,

Type of "ia64_ret_from_clone" is declared differently here(char as against function) and we end up linking object files with different types for the symbol(which the linker will not like).

Current C-code is assuming gcc specific behaviour(gcc does not fix the type for extern variables, leaves it to the linker). 

thanks,
suresh

> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Friday, January 17, 2003 5:53 PM
> To: Siddha, Suresh B
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] [Patch] Fix in process.c
> 
> 
> This one I REALLY don't like:
> 
> >>>>> On Fri, 17 Jan 2003 17:43:44 -0800, "Siddha, Suresh B" 
> <suresh.b.siddha@intel.com> said:
> 
>   Suresh> - extern char ia64_ret_from_clone;
>   Suresh> + extern void  ia64_ret_from_clone(void);
> 
>   Suresh> - child_stack->b0 = (unsigned long) &ia64_ret_from_clone;
>   Suresh> + child_stack->b0 = ((unsigned long *) 
> &ia64_ret_from_clone)[0];
> 
> Why materialize a function pointer for ABSOLUTELY no reason?
> Furthermore, &FUNC can be used as a static initializer, whereas
> ((long*)&FUNC)[0] cannot.
> 
> 	--david
> 

