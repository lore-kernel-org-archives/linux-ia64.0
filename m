From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2004 17:05:01 +0000
Subject: Re: [Fastboot] RE: [BROKEN PATCH] kexec for ia64
Message-Id: <m1vffxh5xe.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
	<20040730155504.2a51b1fa.rddunlap@osdl.org>
	<m18ycvhx1j.fsf@ebiederm.dsl.xmission.com>
	<B8E391BBE9FE384DAA4C5C003888BE6F01CB2705@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F01CB2705@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, khalid.aziz@hp.com, "Randy.Dunlap" <rddunlap@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@osdl.org


Hmm. Your mailer did not add any references lines.


"Luck, Tony" <tony.luck@intel.com> writes:

> Jesse Barnes wrote:
> >With the addition of some ACPI tables and such.  I don't think 
> >those are freed by the kernel right now though, so it should
> >be pretty easy to point at the originals from the newly kexec'd
> >kernel, or make copies.
> 
> The "trim_bottom" and "trim_top" functions currently modify
> the memory map in place.  But this would only make a difference
> if you tried to kexec a kernel with a smaller granule size than
> the originally running kernel, and even then would only
> result in missing seeing some memory that you might have been
> able to use.

On x86 and x86-64 we can recover the memory map from /proc/iomem.

Does that work on ia64?  Can that be fixed to work on ia64?

All of that information needs to get exported to user space so
/sbin/kexec can pass it to the new kernel.

Eric
