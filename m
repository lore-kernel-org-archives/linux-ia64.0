From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Aug 2018 19:23:26 +0000
Subject: Re: [PATCH] ia64: Fix kernel BUG at lib/ioremap.c:72!
Message-Id: <CA+55aFzLnJbAO=_ZNAU3mOnp+LsZj2=SLSxWfDkRxbyFXzWtNw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAK8P3a0Jk_Q-9c7PizRF4HteigfiOprRszpaV9SCk-6tUYfVVQ@mail.gmail.com>
 <20180820163104.12879-1-tony.luck@intel.com>
In-Reply-To: <20180820163104.12879-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, boris.brezillon@bootlin.com, Bjorn Helgaas <bhelgaas@google.com>, Sinan Kaya <okaya@codeaurora.org>, tn@semihalf.com, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, miquel.raynal@bootlin.com

On Mon, Aug 20, 2018 at 9:31 AM Tony Luck <tony.luck@intel.com> wrote:
> I'd suggested an #if !CONFIG_IA64 in the functon, but Arnd
> suggested keeping the fix inside the arch/ia64 tree.
>
> Fixes: 0bbf47eab469 ("ia64: use asm-generic/io.h")

Applied.

            Linus
