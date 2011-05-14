From: "H. Peter Anvin" <hpa@zytor.com>
Date: Sat, 14 May 2011 18:07:39 +0000
Subject: Re: incompatible struct pci_root_info?
Message-Id: <4DCEC4EB.2050107@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4DCEB5BB.1080202@freemail.hu>
In-Reply-To: <4DCEB5BB.1080202@freemail.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Julia Lawall <julia@diku.dk>, LKML <linux-kernel@vger.kernel.org>

On 05/14/2011 10:02 AM, Németh Márton wrote:
> 
> As far as I know it is OK to have different types on different architectures
> with the same name. Is there any reason behind having two struct pci_root_info
> delcaration in arch/x86?
> 

It looks like a namespace collision; the same name being used for that
is really two different types.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

