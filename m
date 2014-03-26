From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 13:57:23 +0000
Subject: Re: [PATCH v3 3/5] x86: Call efi_memblock_x86_reserve_range() on native EFI platform only
Message-Id: <20140326135723.GG24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-4-git-send-email-daniel.kiper@oracle.com>
 <20140326130009.GB24856@console-pimps.org>
 <5332E2B9020000780000255D@nat28.tlf.novell.com>
 <20140326133119.GD24856@console-pimps.org>
 <5332E6AE02000078000025F0@nat28.tlf.novell.com>
 <20140326134845.GN3454@olila.local.net-space.pl>
In-Reply-To: <20140326134845.GN3454@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: Jan Beulich <JBeulich@suse.com>, david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, konrad.wilk@oracle.com, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

On Wed, 26 Mar, at 02:48:45PM, Daniel Kiper wrote:
> 
> On my machine this function crashes on Xen so that is why I have changed
> condition. However, if you say that this issue could be solved in
> another way I will investigate it further.

Daniel, could you paste the crash? Do you get a stack trace?

-- 
Matt Fleming, Intel Open Source Technology Center
