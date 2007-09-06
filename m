From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 06 Sep 2007 16:36:58 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <ed5aea430709060936l3b403a5eibbfeb60b489ad5e4@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Natalie,

I'm confused.  In an earlier mail, you wrote:

 > The boot option is only temporary, until the SAL/PAL mechanism will be
 > shaken up.

Once the SAL/PAL mechanism exists, there won't be a need for
bootoption or a separate machvec anymore, or am I missing something?

The other thing that makes me a bit dubious about using a machvec here
is that it doesn't just apply for DIG, I'd think.  We wouldn't want to
duplicate all the existing machvecs (other than SGI, which never used
ptc.g anyhow), or would we?

  --david

On 9/5/07, Natalie Protasevich <protasnb@gmail.com> wrote:
> On 9/5/07, David Mosberger-Tang <dmosberger@gmail.com> wrote:
> > In my opinion, machvec is a bad idea for a temporary workaround.
> > You'll need to create new header files etc etc all just for a
> > short-lived workaround.  Just my 2 cents.
> >
> >   --david
>
> This is actually a feature. Can be a workaround for platform that
> didn't manage to make ptcg work, but can be intentionally disabled by
> design. Big modular scaled out systems may choose to disable it
> intentionally. I think it's more of feature implementation, which is
> offered by architecture and has found some users, so I'd say this
> might stay and not be short-lived. In this case, will machvec be more
> appropriate?
> Thanks,
> --Natalie
>
> >
> > On 9/5/07, Natalie Protasevich <protasnb@gmail.com> wrote:
> > > On 9/5/07, Robin Holt <holt@sgi.com> wrote:
> > > > > No :) those interested are big hardware makers of large scaled out
> > > > > boxes, such as HP, UIS. They are using own asics and are not
> > > > > necessarily being able to keep chipset native capabilities intact. As
> > > > > I said in the preamble, the mechanism has to be there so they can turn
> > > > > the ptc.g off and run the OS.
> > > >
> > > > This really sounds like it is best done as a machvec.  Currently, Altix
> > > > (sn2) does not have a ptc.g that spans nodes.  We have our own tlb purge
> > > > mechanism which is very flexible and scalable.  Maybe it would be best
> > > > to follow that example.  To repeat Bjorn's comments, this area can be
> > > > fraught with _VERY_ difficult to diagnose problems.  A boot test can
> > > > hardly be expected to uncover all the races so be patient while we walk
> > > > through this code.
> > > >
> > > All right, all right ... :) I'll do the machvec then. Thanks guys,
> > > will peek into the sn2 to get an idea.
> > >
> > > Regards,
> > > --Natalie
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >
> >
> >
> > --
> > Mosberger Consulting LLC, http://www.mosberger-consulting.com/
> >
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
