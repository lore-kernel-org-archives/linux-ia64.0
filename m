From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Sat, 08 Nov 2003 07:36:07 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106827714907686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I can estimate what the procedure includes, such as changing 
> > poisoned memory to uncacheable, clearing suspect data in cache, and storing 
> > zeros to the poisoned area.
> 
> There is no way to tell if the error is soft/transient
> and can be cleared by that sequence, or hard/permanent.

I think there is. Depending on your chipset you can re-read the memory
uncached after all outstanding references have terminated. If you don't
get the same error, it is transient. 

Since I would expect that the majority of errors to be transient, I think
this really is the right approach. Again, depending on the chipset architecture
you might want to do some uncached write/reads ("micro-diagnostics") to
see if the problem can be identified to confirm the nature of the problem.

I used similar approaches on other architectures when figuring out if
a Single Bit was transient or hard. The goal was to stop triggering for SBEs
once you know that you have a hard SBE due to the large overhead

> The safest option is to simply take the page with
> the error out of service and not re-use it.

One problem might be that you now miss a page of main memory and it might
require an additional TLB entry if you use large memory segments

- Matthias

> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

