From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Thu, 06 Sep 2007 18:00:09 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <32209efe0709061100n14a61d73ic524f501d46551c3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/6/07, David Mosberger-Tang <dmosberger@gmail.com> wrote:
> Natalie,
>
> I'm confused.  In an earlier mail, you wrote:
>
>  > The boot option is only temporary, until the SAL/PAL mechanism will be
>  > shaken up.
>
> Once the SAL/PAL mechanism exists, there won't be a need for
> bootoption or a separate machvec anymore, or am I missing something?

The SAL/PAL will only have information about ptc.g not being available
(like a flag). The OS has to have the code to handle this case which
is the IPI with subsequent local purge. The SAL/PAL mechanism only
releaves us from boot option, just like info in ACPI or SMBIOS would.
For now I just leave it to user input, until the mechanism will be
decided on. It's either mentioned above global tlb purge table entry
in SAL table, or alternative PALO (pal override) suggested by HP i
believe.

>
> The other thing that makes me a bit dubious about using a machvec here
> is that it doesn't just apply for DIG, I'd think.  We wouldn't want to
> duplicate all the existing machvecs (other than SGI, which never used
> ptc.g anyhow), or would we?
>
So far it appears to me that it will be defined for ia64 somewhere in
asm-generic/tlb.h and in asm-ia64/tlb.h as
platform_global_tlb_ipi_purge() something, but I'm not sure about
that, will have to start digging.
Thanks,
--Natalie
>   --david
>
> On 9/5/07, Natalie Protasevich <protasnb@gmail.com> wrote:
> > On 9/5/07, David Mosberger-Tang <dmosberger@gmail.com> wrote:
> > > In my opinion, machvec is a bad idea for a temporary workaround.
> > > You'll need to create new header files etc etc all just for a
> > > short-lived workaround.  Just my 2 cents.
> > >
> > >   --david
> >
> > This is actually a feature. Can be a workaround for platform that
> > didn't manage to make ptcg work, but can be intentionally disabled by
> > design. Big modular scaled out systems may choose to disable it
> > intentionally. I think it's more of feature implementation, which is
> > offered by architecture and has found some users, so I'd say this
> > might stay and not be short-lived. In this case, will machvec be more
> > appropriate?
> > Thanks,
> > --Natalie
> >
> > >
> > > On 9/5/07, Natalie Protasevich <protasnb@gmail.com> wrote:
> > > > On 9/5/07, Robin Holt <holt@sgi.com> wrote:
> > > > > > No :) those interested are big hardware makers of large scaled out
> > > > > > boxes, such as HP, UIS. They are using own asics and are not
> > > > > > necessarily being able to keep chipset native capabilities intact. As
> > > > > > I said in the preamble, the mechanism has to be there so they can turn
> > > > > > the ptc.g off and run the OS.
> > > > >
> > > > > This really sounds like it is best done as a machvec.  Currently, Altix
> > > > > (sn2) does not have a ptc.g that spans nodes.  We have our own tlb purge
> > > > > mechanism which is very flexible and scalable.  Maybe it would be best
> > > > > to follow that example.  To repeat Bjorn's comments, this area can be
> > > > > fraught with _VERY_ difficult to diagnose problems.  A boot test can
> > > > > hardly be expected to uncover all the races so be patient while we walk
> > > > > through this code.
> > > > >
> > > > All right, all right ... :) I'll do the machvec then. Thanks guys,
> > > > will peek into the sn2 to get an idea.
> > > >
> > > > Regards,
> > > > --Natalie
> > > > -
> > > > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > >
> > >
> > >
> > > --
> > > Mosberger Consulting LLC, http://www.mosberger-consulting.com/
> > >
> >
>
>
> --
> Mosberger Consulting LLC, http://www.mosberger-consulting.com/
>
