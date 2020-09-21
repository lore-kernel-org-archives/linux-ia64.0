From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 21 Sep 2020 08:38:41 +0000
Subject: Re: Build regressions/improvements in v5.9-rc6
Message-Id: <CAMuHMdXCQ-FgPXHVjnXujMvi_tg12AzXo5i2+i=JAnUmeNci_Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200921082716.29247-1-geert@linux-m68k.org>
In-Reply-To: <20200921082716.29247-1-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E . McKenney" <paulmck@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, Sep 21, 2020 at 10:32 AM Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> JFYI, when comparing v5.9-rc6[1] to v5.9-rc5[3], the summaries are:
>   - build errors: +3/-5

  + /kisskb/src/drivers/dax/super.c: error: redefinition of
'dax_supported':  => 325:6

m68k-defconfig
sun3_defconfig
mips-allmodconfig
sparc-allmodconfig
sparc64-allmodconfig
mips-allmodconfig
powernv_defconfig+THIN
(many more reported in the wild)

  + error: modpost: "rcu_idle_enter" [drivers/acpi/processor.ko]
undefined!:  => N/A
  + error: modpost: "rcu_idle_exit" [drivers/acpi/processor.ko]
undefined!:  => N/A

ia64-defconfig

> [1] http://kisskb.ellerman.id.au/kisskb/branch/linus/head/ba4f184e126b751d1bffad5897f263108befc780/ (all 192 configs)
> [3] http://kisskb.ellerman.id.au/kisskb/branch/linus/head/856deb866d16e29bd65952e0289066f6078af773/ (all 192 configs)
Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
