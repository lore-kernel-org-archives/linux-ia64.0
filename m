From: Borislav Petkov <bp@alien8.de>
Date: Mon, 26 Nov 2018 18:04:55 +0000
Subject: Re: [PATCH 0/2 RESEND v7] add reserved e820 ranges to the kdump kernel e820 table
Message-Id: <20181126180455.GI4843@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124051223.19994-1-lijiang@redhat.com>
 <d457ed46-d983-20b2-ad7f-9eaa6d98f2bf@intel.com>
In-Reply-To: <d457ed46-d983-20b2-ad7f-9eaa6d98f2bf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>
Cc: Lianbo Jiang <lijiang@redhat.com>, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

On Mon, Nov 26, 2018 at 09:44:46AM -0800, Dave Hansen wrote:
> On 11/23/18 9:12 PM, Lianbo Jiang wrote:
> > These patches add the new I/O resource descriptor 'IORES_DESC_RESERVED'
> > for the iomem resources search interfaces, and in order to make it still
> > work after the new descriptor is added, these codes originally related
> > to 'IORES_DESC_NONE' have been updated.
> 
> I'm having a really hard time figuring out what problem these patches solve.
> 
> What end-user visible behavior does this set change?

Yeah, that was a long process of digging out the "why".

I'd recommend reading the previous threads and, more specifically:

https://lkml.kernel.org/r/CABhMZUUscS3jUZUSM5Y6EYJK6weo7Mjj5-EAKGvbw0qEe%2B38zw@mail.gmail.com

in short: we need to export e820 reserved ranges to the second kernel so
that it can talk to PCI devices properly. (And I'm wondering how it did
work until now...)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
