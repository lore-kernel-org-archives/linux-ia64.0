From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 27 Sep 2021 15:19:50 +0000
Subject: Re: [PATCH v1 2/4] memblock: allow to specify flags with memblock_add_node()
Message-Id: <CAMuHMdWuRtxwRCy-x63s9BkDKk+hkXhEfZYC5pmXomzCuDBrYg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210927150518.8607-1-david@redhat.com> <20210927150518.8607-3-david@redhat.com>
In-Reply-To: <20210927150518.8607-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, arcml <linux-snps-arc@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kexec@lists.infradead.org

On Mon, Sep 27, 2021 at 5:05 PM David Hildenbrand <david@redhat.com> wrote:
> We want to specify flags when hotplugging memory. Let's prepare to pass
> flags to memblock_add_node() by adjusting all existing users.
>
> Note that when hotplugging memory the system is already up and running
> and we don't want to add the memory first and apply flags later: it
> should happen within one memblock call.
>
> Signed-off-by: David Hildenbrand <david@redhat.com>

>  arch/m68k/mm/mcfmmu.c            | 3 ++-
>  arch/m68k/mm/motorola.c          | 6 ++++--

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
