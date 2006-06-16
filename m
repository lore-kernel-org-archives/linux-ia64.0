From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Fri, 16 Jun 2006 15:50:06 +0000
Subject: Re: esi-support (2nd take)
Message-Id: <ed5aea430606160850y57189b95m72832f5e8be43b47@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430606151012p52138f13r7ee7b7e1b6fb6615@mail.gmail.com>
In-Reply-To: <ed5aea430606151012p52138f13r7ee7b7e1b6fb6615@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, I checked on the locking issue with Dong Wei and according to him,
ESI is logically a part of SAL, so the same lock should be used to
serialize SAL and ESI calls.  In other words, the current patch should
be fine.

Thanks,

  --david

On 6/15/06, David Mosberger-Tang <David.Mosberger@acm.org> wrote:
> Hi Tony,
>
> Below is a revised version of the ESI-support patch with the following changes:
>
>  * Export ia64_esi_call and ia64_esi_call_phys() as GPL symbols.
>
>  * Disallow building esi.c as a module for now.  Building as a module
> would currently
>    lead to an unresolved reference to "sal_lock" on SMP kernels
> because that symbol
>    doesn't get exported.  If it turns out that ESI calls can be locked
> separately from
>    SAL calls, we can replace sal_lock with a new esi_lock and reenable
> building as
>    a module (I'm checking into whether or not this is safe).
>
>  * Export esi_call_phys() only if ESI is enabled.
>
>  * Remove internal stuff from esi.h and add a "proc_type" argument to
> ia64_esi_call() such
>    that serialization-requirements can be expressed (ESI follows SAL
> here, where procedure
>    calls may have to be serialized, are MP-safe, or MP-safe andr reentrant).
>
> Signed-off-by: David Mosberger <David.Mosberger@acm.org>
>
>   --david
> --
> Mosberger Consulting LLC, http://www.mosberger-consulting.com/
>
>
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
