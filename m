From: Dave Hansen <dave.hansen@intel.com>
Date: Wed, 28 Nov 2018 16:02:26 +0000
Subject: Re: [PATCH 1/2 RESEND v7] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <4ff951f6-c1bf-ff98-b70b-a138e54488af@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124051223.19994-1-lijiang@redhat.com>
 <20181124051223.19994-2-lijiang@redhat.com>
 <ae405fe9-94fd-3fb7-decd-c7821cf95b7d@intel.com>
 <460c5552-a48e-3523-275a-7f94d0f08f9b@redhat.com>
 <703ce20d-be09-9b8d-d457-5b002a50dff7@intel.com>
 <d84fbefb-f856-c600-5207-c63f48b1b308@redhat.com>
In-Reply-To: <d84fbefb-f856-c600-5207-c63f48b1b308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lijiang <lijiang@redhat.com>, linux-kernel@vger.kernel.org
Cc: kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

On 11/27/18 7:51 PM, lijiang wrote:
> But now, the 'E820_TYPE_RESERVED' type is converted to the descriptor 'IORES_DESC_RESERVED'
> instead of 'IORES_DESC_NONE', it has been changed and the value of 'mem_flags.desc_other'
> is equal to 'true'. This is wrong.

Thanks for the improved description of the problem.  Seems to all make
sense now.

Could you include this in the changelog for the next version?
