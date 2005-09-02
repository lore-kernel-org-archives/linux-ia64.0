From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 02 Sep 2005 03:45:32 +0000
Subject: RE: ip_contrack module refuses to load...
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F044B0A3D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>doesn't that mean that those variables are a
>special kind of (per-CPU) variables and should
>get a special handling anyway?
>
>if not, then I'd agree with Peter that a per-cpu 
>variable on UP should not be treated any different 
>from a normal variable ...
>
>maybe you could clarify

On ia64 we always map per-cpu variables into the top
64k of the kernel virtual address space ... it doesn't
matter whether the kernel is UP or SMP.  So the module
loader should not have any special cases for UP.

This is different from most (all?) other architectures
where per-cpu variables are automagically redefined to
be normal kernel variables in the UP case.

-Tony
