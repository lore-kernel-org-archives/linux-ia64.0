From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Tue, 31 Jul 2001 23:02:30 +0000
Subject: RE: [Linux-ia64] Patch to set the OSFXSR bit of CR4
Message-Id: <marc-linux-ia64-105590693005976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005975@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005975@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It is already enabled in 2.4.7 kernel.

Thanks,
Asit


> -----Original Message-----
> From: Robboy, David G [mailto:david.g.robboy@intel.com]
> Sent: Tuesday, July 31, 2001 3:58 PM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] Patch to set the OSFXSR bit of CR4
> 
> 
> Linux should enable the ia32 "streaming SIMD" instructions (the PIII
> extensions of MMX).  These instructions work on the Itanium 
> processor under
> seamless. Currently Linux disables them by clearing the 
> OSFXSR bit of CR4.
> 
> Here's the patch for linux R2.4.5.
> 
>   - David Robboy
> 
> include/asm-ia64/ia32.h
> 373c373
> < #define IA32_CR4       0             /* No architectural 
> extensions */
> ---
> > #define IA32_CR4       (1 << 9)          /* Set OSFXSR to 
> enable streaming
> SIMD */
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

