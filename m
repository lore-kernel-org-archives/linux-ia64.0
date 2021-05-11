From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue, 11 May 2021 18:50:11 +0000
Subject: Re: [PATCH v3 1/3] audit: replace magic audit syscall class numbers with macros
Message-Id: <20210511185011.GP3141668@madcap2.tricolour.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1619811762.git.rgb@redhat.com>
 <bda073f2a8b11000ef40cf8b965305409ee88f44.1619811762.git.rgb@redhat.com>
 <CAHC9VhShi4u26h5OsahveQDNxO_uZ+KgzGOYEp5W7w6foA-uKg@mail.gmail.com>
In-Reply-To: <CAHC9VhShi4u26h5OsahveQDNxO_uZ+KgzGOYEp5W7w6foA-uKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Moore <paul@paul-moore.com>
Cc: Linux-Audit Mailing List <linux-audit@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@parisplace.org>, Steve Grubb <sgrubb@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>, Arnd Bergmann <arnd@kernel.org>

On 2021-05-10 21:23, Paul Moore wrote:
> On Fri, Apr 30, 2021 at 4:36 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> >
> > Replace audit syscall class magic numbers with macros.
> >
> > This required putting the macros into new header file
> > include/linux/auditscm.h since the syscall macros were included for both 64
> > bit and 32 bit in any compat code, causing redefinition warnings.
> 
> The ifndef/define didn't protect against redeclaration?  Huh.  Maybe
> I'm not thinking about this correctly, or the arch specific code is
> doing something wonky ...

I had a chat with Arnd about it in IRC upstream and started digging
deeper and it got quite messy.  As seen from the cover letter, audit.h
pulled in a chain of things which weren't entirely unreasonable given it
was compiling compat support in with native support by default.  I
suppose I could have defined _ASM_X86_UNISTD_64_H to prevent it from
being added, but that would be ugly on a generated file, have caused a
failure elsewhere and would need to be done for each compat file.  I
thought of defining CONFIG_X86_32 in arch/x86/ia32/audit.c but that
would cause other problems.  This was the cleanest solution.  Otherwise
I leave them as magic numbers like in V1.

> Regardless, assuming that it is necessary, I would prefer if we called
> it auditsc.h instead of auditscm.h; the latter makes me think of
> sockets and not syscalls.
> 
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > ---
> >  MAINTAINERS                        |  1 +
> >  arch/alpha/kernel/audit.c          |  8 ++++----
> >  arch/ia64/kernel/audit.c           |  8 ++++----
> >  arch/parisc/kernel/audit.c         |  8 ++++----
> >  arch/parisc/kernel/compat_audit.c  |  9 +++++----
> >  arch/powerpc/kernel/audit.c        | 10 +++++-----
> >  arch/powerpc/kernel/compat_audit.c | 11 ++++++-----
> >  arch/s390/kernel/audit.c           | 10 +++++-----
> >  arch/s390/kernel/compat_audit.c    | 11 ++++++-----
> >  arch/sparc/kernel/audit.c          | 10 +++++-----
> >  arch/sparc/kernel/compat_audit.c   | 11 ++++++-----
> >  arch/x86/ia32/audit.c              | 11 ++++++-----
> >  arch/x86/kernel/audit_64.c         |  8 ++++----
> >  include/linux/audit.h              |  1 +
> >  include/linux/auditscm.h           | 23 +++++++++++++++++++++++
> >  kernel/auditsc.c                   | 12 ++++++------
> >  lib/audit.c                        | 10 +++++-----
> >  lib/compat_audit.c                 | 11 ++++++-----
> >  18 files changed, 102 insertions(+), 71 deletions(-)
> >  create mode 100644 include/linux/auditscm.h
> 
> ...
> 
> > diff --git a/include/linux/auditscm.h b/include/linux/auditscm.h
> > new file mode 100644
> > index 000000000000..1c4f0ead5931
> > --- /dev/null
> > +++ b/include/linux/auditscm.h
> > @@ -0,0 +1,23 @@
> > +/* SPDX-License-Identifier: GPL-2.0-or-later */
> > +/* auditscm.h -- Auditing support syscall macros
> > + *
> > + * Copyright 2021 Red Hat Inc., Durham, North Carolina.
> > + * All Rights Reserved.
> > + *
> > + * Author: Richard Guy Briggs <rgb@redhat.com>
> > + */
> > +#ifndef _LINUX_AUDITSCM_H_
> > +#define _LINUX_AUDITSCM_H_
> > +
> > +enum auditsc_class_t {
> > +       AUDITSC_NATIVE = 0,
> > +       AUDITSC_COMPAT,
> > +       AUDITSC_OPEN,
> > +       AUDITSC_OPENAT,
> > +       AUDITSC_SOCKETCALL,
> > +       AUDITSC_EXECVE,
> > +
> > +       AUDITSC_NVALS /* count */
> > +};
> > +
> > +#endif
> 
> -- 
> paul moore
> www.paul-moore.com
> 

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
