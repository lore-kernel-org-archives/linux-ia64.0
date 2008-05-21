From: Gerald Pfeifer <gp@novell.com>
Date: Wed, 21 May 2008 13:28:57 +0000
Subject: Re: [PATCH 2/2] ia64/pv_ops: documentation on ia64/pv_ops
Message-Id: <alpine.LNX.1.10.0805211200100.3196@enan.fvgr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1211355072669-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1211355072669-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 May 2008, Isaku Yamahata wrote:
> Documentation on ia64/pv_ops which describes its strategy and 
> implementation.

I hope you do not mind if I make some minor suggestions on how to
improve this nice documentation?

> +On the other hand there are several IA64 virtualization technologies like
> +kvm/IA64, xen/IA64 and many other academic IA64 hypervisors so that it is
> +good to add virtualization support on Linux/IA64.

How about making this "On the other hand, now that there are also several
....good to add generic virtualization infrastructure to Linux/IA64" or
something alone these lines?

> +It allows each hypervisors to override operations which is important for

"hypervisor" (singular) and "which are" (plural)

> +hypervisors at API level. And it allows single kernel binary to run on
> +all supported execution environments including native machine.

Here I suggest to say "a single kernel binary".

> +Essentially paravirt_ops is the set of table of function pointers and
> +operations correspond to from low level sensitive instructions to high
> +level functionalities in various area.

I am afraid this sentence does not completely translate.  Could this be 
written as "...is a set of function pointers and operations corresponding 
to low level sensitive instructions and high level functionalities in
various areas"?

> +... It is because some operations corresponds to very low
> +level so that indirect call overhead isn't neglectable.

How about making this "Some of these operations are very performance 
sensitive and indirect call overhead is not neglible".

> +- simple indirect call
> +  The operations correspond to high level functionality so that the
> +  overhead of indirect call isn't very important.

Here, and in the other cases, we may want to consider saying "these
operations".

> +  Usually the operations correspond to low level instructions so that
> +  they are called so frequent and performance critical. So the
> +  overhead is very important.

How about "...instructions.  They are called frequently and performance
critical"?

> +We can replace some implementations very easily defining new machine
> +vector. 

"a new machine vector"

> +- virtualization support needs wider support then machine vector does.

"than"

> +  Probably the calling overhead might not very large compared to the 
> +  emulation overhead of virtualization. However on native case, the
> +  overhead should be eliminated completely.

I believe a "be" may be missing from the first sentence, and we may
want to say "in the native case".

> +Possibly it might be better to move some function pointers from
> +paravirt_ops to machine vector. In fact xen domU case both pv_ops and
> +machine vector are utilized.

How about making this "In fact, the Xen domU cases utilizes both
pv_ops and machine vector"?

> +Because of the architecture difference between ia64 and x86, the
> +resulted set of functions is very different from x86 pv_ops.

"resulting"

> +They are not very performance critical part so that simple C indirect
> +function call is accepted.

I believe we can omit "part" here, and perhaps use "acceptable" instead
of "accepted".

> +    A structure describes the execution environment.

Here and in the following entries I recommend saying "This structure
describes..." or just "This describes...".

> +- a set of indirect calls which needs optimization

"need"

> +Currently this class functions correspond to a subset of IA64
> +intrinsics.

"class of functions"

> +using gcc extended inline assembly code.

Wearing my GCC hat, "GCC" (all uppercase) is the preferred spelling,
but this is a most minor nit indeed.

> +For maintenance purpose, the taken approach for .S files is single
> +source code and compile multi times with different macros definitios.

"multiple", "definitions"

> +Probably initialized in head.S using multi entry point or other trick.

Have you considered using "or some other trick here"?

Thanks again for taking the time to write all this up, and I do hope my
comments appear useful!

Gerald
-- 
Dr. Gerald Pfeifer            E gp@novell.com      SUSE Linux Products GmbH
Director Inbound Product Mgmt  T +49(911)74053-0    HRB 16746 (AG Nuremberg)
openSUSE/SUSE Linux Enterprise  F +49(911)74053-483  GF: Markus Rex
