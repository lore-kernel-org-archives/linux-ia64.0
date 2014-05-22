From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 22 May 2014 08:51:30 +0000
Subject: Re: ia64: CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK?
Message-Id: <1400748690.16832.10.camel@x220>
List-Id: <linux-ia64.vger.kernel.org>
References: <1400748416.16832.7.camel@x220>
In-Reply-To: <1400748416.16832.7.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, Fenghua,

On Thu, 2014-05-22 at 10:46 +0200, Paul Bolle wrote:
> v2.6.27 shipped with commit e92e8c68a61a ("[IA64] pvops: define
> paravirtualized instructions for native."). That commit added a
> preprocessor test for CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK to
> arch/ia64/include/asm/native/inst.h.
> 
> There never was a Kconfig symbol PARAVIRT_GUEST_ASM_CLOBBER_CHECK, so
> this test has always evaluated to false.
> 
> Was this macro intended to be set through the kconfig tools? Or was it
> perhaps intended to be set manually whenever one wanted to use it?
> Either way, is that macro and the code currently hidden behind it still
> needed?

Isaku's address bounces. So I'm not likely to get a reply from Isaku.
Could one of you please have a look at this?


Paul Bolle

