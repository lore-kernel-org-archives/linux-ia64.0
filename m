From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sun, 28 May 2023 10:13:50 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <4820abf96ee975181edcc15d84b41c4aefad0d8e.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

On Sun, 2023-05-28 at 09:30 +0200, Frank Scheiner wrote:
> > Frank, could you please give it a try?
> > 
> > Thanks,
> > Song
> > 
> > diff --git i/kernel/module/main.c w/kernel/module/main.c
> > index 0f9183f1ca9f..e4e723e1eb21 100644
> > --- i/kernel/module/main.c
> > +++ w/kernel/module/main.c
> > @@ -1514,14 +1514,14 @@ static void __layout_sections(struct module
> > *mod, struct load_info *info, bool i
> >                  MOD_RODATA,
> >                  MOD_RO_AFTER_INIT,
> >                  MOD_DATA,
> > -               MOD_INVALID,    /* This is needed to match the masks array */
> > +               MOD_DATA,
> >          };
> >          static const int init_m_to_mem_type[] = {
> >                  MOD_INIT_TEXT,
> >                  MOD_INIT_RODATA,
> >                  MOD_INVALID,
> >                  MOD_INIT_DATA,
> > -               MOD_INVALID,    /* This is needed to match the masks array */
> > +               MOD_INIT_DATA,
> >          };
> > 
> >          for (m = 0; m < ARRAY_SIZE(masks); ++m) {
> 
> Thanks, that patch (as -patch4 on top of v6.4-rc3) fixes the boot 
> regression for me on the rx2620:

Sounds good. Would be great to get this into 6.4 before release.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
