From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Wed, 29 Jan 2003 18:30:52 +0000
Subject: RE: [Linux-ia64] [Patch] trivial fix in linker script
Message-Id: <marc-linux-ia64-105590709805771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi David,

I think you are mentioning about ret_from_clone patch here. 

I am using GNU linker. 

Inline with your observation, Intel compiler emits the type of extern variables. And now based on the order in which object files are linked, linker is failing in some cases. 

If the object file with extern declaration comes after the object file with correct declaration, linker is working fine. But if the object file with extern declaration comes first, then linker is reporting "type of symbol changed" in the second object file with correct declaration.

gcc doesn't fix the type for extern variables, leaves it to the linker. So linking works irrespective of the order.

Is this a GNU linker issue?

thanks,
suresh

> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Tuesday, January 28, 2003 11:15 AM
> To: Siddha, Suresh B
> Cc: linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] [Patch] trivial fix in linker script
> 
> 
> >>>>> On Fri, 24 Jan 2003 12:05:35 -0800, "Siddha, Suresh B" 
> <suresh.b.siddha@intel.com> said:
> 
>   Suresh> hi David, I agree. Attached a bigger patch now :)
> 
> Well, it's not pretty so I deferred working on it to the last, and
> then I got distracted and forgot to do something about it.
> 
> Where exactly does the problem come from?  Is it that the Intel linker
> will complain when it finds the same symbol with different types?
> This kind of overzealous checking is quite a pain and is, IMHO, pretty
> much a bug (there are other annoying "features" like that in the Intel
> toolchain, for example that the assembler insists on all external
> symbols being declared; what a pain...).  If we need to have a
> workaround, we can add one but we should clearly document why the ugly
> hacks are needed.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

