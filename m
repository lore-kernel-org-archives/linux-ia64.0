From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 26 Mar 2014 14:17:53 +0000
Subject: Re: [PATCH v3 2/5] efi: Export arch_tables variable
Message-Id: <5332EFA102000078000026CD@nat28.tlf.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
 <1395781076-12000-3-git-send-email-daniel.kiper@oracle.com>
 <5332E25F020000780000255A@nat28.tlf.novell.com>
 <20140326140800.GP3454@olila.local.net-space.pl>
In-Reply-To: <20140326140800.GP3454@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com, jeremy@goop.org, fenghua.yu@intel.com, matt.fleming@intel.com, tony.luck@intel.com, x86@kernel.org, tglx@linutronix.de, xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com, konrad.wilk@oracle.com, eshelton@pobox.com, mingo@redhat.com, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hpa@zytor.com

>>> On 26.03.14 at 15:08, <daniel.kiper@oracle.com> wrote:
> On Wed, Mar 26, 2014 at 01:21:19PM +0000, Jan Beulich wrote:
>> >>> On 25.03.14 at 21:57, <daniel.kiper@oracle.com> wrote:
>> > Export arch_tables variable. Xen init function calls efi_config_init()
>> > which takes it as an argument.
>> >
>> > Additionally, put __initdata in place suggested by include/linux/init.h.
>>
>> Which isn't necessarily the most appropriate place.
> 
> Why? If comments in include/linux/init.h are not valid they should be 
> changed.

Because they can't go there uniformly: While on function declarations
you can put them there, on function definitions they need to come
before the function name. And placing attributes between type and
name does - iirc - work consistently for everything.

>> > --- a/include/linux/efi.h
>> > +++ b/include/linux/efi.h
>> > @@ -583,6 +583,8 @@ extern struct efi {
>> >  	struct efi_memory_map *memmap;
>> >  } efi;
>> >
>> > +extern efi_config_table_type_t arch_tables[] __initdata;
>>
>> And section placement annotations are bogus on declarations.
> 
> Hmmm... I am not sure which approach is better. I saw that
> in many places declarations have annotations. Could you
> point me some docs which states (and explains) that this
> is wrong idea.

Just use common sense: Attributes that are of concern to the
caller should go on the declaration. Attributes that only affect
code generation for the function/object in question should go on
the definition.

Jan

