From: lijiang <lijiang@redhat.com>
Date: Mon, 07 Jan 2019 05:10:26 +0000
Subject: Re: [PATCH 1/2 v8] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <9e994396-4bf9-ed96-a8e7-c4ca2f69170d@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181129080956.20776-1-lijiang@redhat.com>
 <20181129080956.20776-2-lijiang@redhat.com>
 <20181130033703.GA23624@dhcp-128-65.nay.redhat.com>
 <bbf6352b-b060-4cb8-dfd2-99166b0149a7@redhat.com>
 <20181206201147.GG3986@zn.tnic>
In-Reply-To: <20181206201147.GG3986@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, bhe@redhat.com, Tom Lendacky <thomas.lendacky@amd.com>, Toshi Kani <toshi.kani@hp.com>, Dan Williams <dan.j.williams@intel.com>

在 2018年12月07日 04:11, Borislav Petkov 写道:
> On Fri, Nov 30, 2018 at 03:04:44PM +0800, lijiang wrote:
>> I have noticed the changes on x86, but for IA64, i'm not sure whether it should do the same
>> thing, so keep it as before.
>>
>> If IA64 people would like to give any comment, that will be appreciated.
> 
> I think you should not touch ia64 and not make Tony unnecessarily power
> up the old rust.
> 

Ok, i will get rid of previous changes to IA64 in next post.

Thanks.

> :-)
> 
