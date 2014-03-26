From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 26 Mar 2014 13:53:46 +0000
Subject: Re: [PATCH v3 5/5] xen: Put EFI machinery in place
Message-Id: <20140326135346.GF24856@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-6-git-send-email-daniel.kiper@oracle.com>
 <20140326131214.GC24856@console-pimps.org>
 <5332E4A802000078000025B6@nat28.tlf.novell.com>
 <20140326134617.GE24856@console-pimps.org>
In-Reply-To: <20140326134617.GE24856@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, Daniel Kiper <daniel.kiper@oracle.com>, konrad.wilk@oracle.com, Tang Liang <liang.tang@oracle.com>, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

On Wed, 26 Mar, at 01:46:17PM, Matt Fleming wrote:
> On Wed, 26 Mar, at 01:31:04PM, Jan Beulich wrote:
> > >>> On 26.03.14 at 14:12, <matt@console-pimps.org> wrote:
> > > 
> > > Is there a reason that you can't just populate an efi_system_table_t
> > > object, which could be used by efi_init(), so that we can save you the
> > > trouble of duplicating all of this code?
> > 
> > Would the generic function cope with all other fields being NULL (or
> > equivalent)?
>  
> I've no idea, but it shouldn't be difficult to make that work. And by
> making it work in the generic code

Guh, hit Send too soon... sorry.

What I was trying to say was that there's a real benefit to keeping all
these idiosyncrasies, such as "This field may be NULL on some platforms,
or this field, or that", in one place, because it gives you an immediate
view of what platforms Linux supports and what assumptions we can make.

It also helps immensely when the time comes to do some refactoring -
because it's all contained in one central place all the use cases are in
front of you.

Obviously this approach doesn't work for super-platform specific stuff,
but it's not clear to me that these patches fall into that category.

-- 
Matt Fleming, Intel Open Source Technology Center
