From: "Arnd Bergmann" <arnd@arndb.de>
Date: Mon, 27 Feb 2023 20:04:04 +0000
Subject: Re: [PATCH 0/2] char/agp: consolidate asm/agp.h
Message-Id: <5de30963-9be9-4e87-a696-7a642d92630f@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230212084611.1311177-1-rppt@kernel.org>
In-Reply-To: <20230212084611.1311177-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Dave Airlie <airlied@redhat.com>, "David S . Miller" <davem@davemloft.net>, Helge Deller <deller@gmx.de>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, dri-devel@lists.freedesktop.org, linux-alpha@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Sun, Feb 12, 2023, at 09:46, Mike Rapoport wrote:
> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
>
> asm/agp.h is duplicated in several architectures, with x86 being the
> only instance that differs from the rest.
>
> Introduce asm-generic/agp.h and use it instead of per-architecture
> headers for the most cases.
>
> I believe that asm-generic is the best tree to pick up this patches.
>
> Mike Rapoport (IBM) (2):  char/agp: consolidate
> {alloc,free}_gatt_pages()  char/agp: introduce asm-generic/agp.h

Hi Mike,

It looks like I wrote an email saying I merged these two patches,
but never actually sent it out. Not sure if you found out another
way, but this was part of the asm-generic tree for 6.3 and is now
merged upstream.

Thanks for the cleanup,

     Arnd
