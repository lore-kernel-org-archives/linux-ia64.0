From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 26 Mar 2014 15:25:16 +0000
Subject: Re: [PATCH v3 4/5] xen: Define EFI related stuff
Message-Id: <5332FF6C02000078000027A5@nat28.tlf.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-5-git-send-email-daniel.kiper@oracle.com>
 <alpine.DEB.2.02.1403261452160.2747@kaball.uk.xensource.com>
In-Reply-To: <alpine.DEB.2.02.1403261452160.2747@kaball.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stefano.stabellini@eu.citrix.com
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, Tang Liang <liang.tang@oracle.com>, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

>>> On 26.03.14 at 15:58, <stefano.stabellini@eu.citrix.com> wrote:
>> +struct xenpf_efi_runtime_call {
>> +	uint32_t function;
>> +    /*
>> +     * This field is generally used for per sub-function flags (defined
>> +     * below), except for the XEN_EFI_get_next_high_monotonic_count case,
>> +     * where it holds the single returned value.
>> +     */
>> +	uint32_t misc;
>> +	unsigned long status;
> 
> I realize that this is just the same as xen/include/public/platform.h,
> but this field should be xen_ulong_t.

Care to supply a patch to the canonical header?

Jan

