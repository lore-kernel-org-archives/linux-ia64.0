From: Jonathan Corbet <corbet@lwn.net>
Date: Thu, 04 May 2023 18:41:21 +0000
Subject: Re: [PATCH v3] docs: directive `alias` for redirects
Message-Id: <87ednwndm6.fsf@meer.lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230504180210.727364-1-costa.shul@redhat.com>
In-Reply-To: <20230504180210.727364-1-costa.shul@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Costa Shulyupin <costa.shul@redhat.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, linux-doc@vger.kernel.org
Cc: Costa Shulyupin <costa.shul@redhat.com>, Vineet Gupta <vgupta@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Yanteng Si <siyanteng@loongson.cn>, Geert Uytterhoeven <geert@linux-m68k.org>, Max Filippov <jcmvbkbc@gmail.com>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, open list <linux-kernel@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:OPENRISC ARCHITECTURE" <linux-openrisc@vger.kernel.org>, "open list:PARISC ARCHITECTURE" <linux-parisc@vger.kernel.org>, "open list:SUPERH" <linux-sh@vger.kernel.org>

Costa Shulyupin <costa.shul@redhat.com> writes:

> and several redirects for moved main arch pages
>
> Problems:
> - The documentation lacks hierarchy
> - Relocating pages disrupts external links to
>   the documentation and causes confusion for users
>
> Benefits:
> - Users can easily access relocated pages from external resources
> - Using redirects frees up options for reorganizing the documentation
>
> The solution:
> - Introduced directive `alias` which declares previous path of
>   a moved document as the argument.
> - Redirects are implemented with Sphinx extension rediraffe_redirects.
>
> Signed-off-by: Costa Shulyupin <costa.shul@redhat.com>
>
> ---
>
> Changes:
> - complete new implementation

I honestly don't know why you keep throwing versions of this at us.  In
the absence of observed problems, I don't see the value in adding
infrastructure that we have to maintain going forward.

Please stop with this for now.

Thanks,

jon
