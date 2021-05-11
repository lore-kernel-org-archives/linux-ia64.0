From: Paul Moore <paul@paul-moore.com>
Date: Tue, 11 May 2021 17:51:48 +0000
Subject: Re: [PATCH v3 1/3] audit: replace magic audit syscall class numbers with macros
Message-Id: <CAHC9VhQ9DgiMKScTt5xfyK25WM-KPUrFksFS7dH51u0+PemPLA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1619811762.git.rgb@redhat.com> <bda073f2a8b11000ef40cf8b965305409ee88f44.1619811762.git.rgb@redhat.com>
 <CAHC9VhShi4u26h5OsahveQDNxO_uZ+KgzGOYEp5W7w6foA-uKg@mail.gmail.com> <20210511171356.GN3141668@madcap2.tricolour.ca>
In-Reply-To: <20210511171356.GN3141668@madcap2.tricolour.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Guy Briggs <rgb@redhat.com>
Cc: Linux-Audit Mailing List <linux-audit@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@parisplace.org>, Steve Grubb <sgrubb@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>, Arnd Bergmann <arnd@kernel.org>

On Tue, May 11, 2021 at 1:14 PM Richard Guy Briggs <rgb@redhat.com> wrote:
>
> On 2021-05-10 21:23, Paul Moore wrote:
> > On Fri, Apr 30, 2021 at 4:36 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> > >
> > > Replace audit syscall class magic numbers with macros.
> > >
> > > This required putting the macros into new header file
> > > include/linux/auditscm.h since the syscall macros were included for both 64
> > > bit and 32 bit in any compat code, causing redefinition warnings.
> >
> > The ifndef/define didn't protect against redeclaration?  Huh.  Maybe
> > I'm not thinking about this correctly, or the arch specific code is
> > doing something wonky ...
> >
> > Regardless, assuming that it is necessary, I would prefer if we called
> > it auditsc.h instead of auditscm.h; the latter makes me think of
> > sockets and not syscalls.
>
> The "m" was for "macros", since there are auditsc bits in audit.h as
> well, but I have no significant objection.

Yes, I figured as much, but my comment about it looking like a socket
"thing" still stands.  I'm open to other ideas if you don't like
auditsc.h, I just don't like auditscm.h.

-- 
paul moore
www.paul-moore.com
