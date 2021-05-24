From: Paul Moore <paul@paul-moore.com>
Date: Mon, 24 May 2021 23:04:07 +0000
Subject: Re: [PATCH v4 2/3] audit: add support for the openat2 syscall
Message-Id: <CAHC9VhTyAFou=_Xu7ZSZSY+19Yii=hQ1NW1LPisk49Ot9wg7rg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1621363275.git.rgb@redhat.com> <f5f1a4d8699613f8c02ce762807228c841c2e26f.1621363275.git.rgb@redhat.com>
 <20210520075842.vnbwbw6yffkybk6z@wittgenstein>
In-Reply-To: <20210520075842.vnbwbw6yffkybk6z@wittgenstein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Richard Guy Briggs <rgb@redhat.com>, Linux-Audit Mailing List <linux-audit@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Eric Paris <eparis@parisplace.org>, Steve Grubb <sgrubb@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>, Arnd Bergmann <arnd@kernel.org>

On Thu, May 20, 2021 at 3:58 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> On Wed, May 19, 2021 at 04:00:21PM -0400, Richard Guy Briggs wrote:
> > The openat2(2) syscall was added in kernel v5.6 with commit fddb5d430ad9
> > ("open: introduce openat2(2) syscall")
> >
> > Add the openat2(2) syscall to the audit syscall classifier.
> >
> > Link: https://github.com/linux-audit/audit-kernel/issues/67
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > Link: https://lore.kernel.org/r/f5f1a4d8699613f8c02ce762807228c841c2e26f.1621363275.git.rgb@redhat.com
> > ---
> >  arch/alpha/kernel/audit.c           | 2 ++
> >  arch/ia64/kernel/audit.c            | 2 ++
> >  arch/parisc/kernel/audit.c          | 2 ++
> >  arch/parisc/kernel/compat_audit.c   | 2 ++
> >  arch/powerpc/kernel/audit.c         | 2 ++
> >  arch/powerpc/kernel/compat_audit.c  | 2 ++
> >  arch/s390/kernel/audit.c            | 2 ++
> >  arch/s390/kernel/compat_audit.c     | 2 ++
> >  arch/sparc/kernel/audit.c           | 2 ++
> >  arch/sparc/kernel/compat_audit.c    | 2 ++
> >  arch/x86/ia32/audit.c               | 2 ++
> >  arch/x86/kernel/audit_64.c          | 2 ++
> >  include/linux/auditsc_classmacros.h | 1 +
> >  kernel/auditsc.c                    | 3 +++
> >  lib/audit.c                         | 4 ++++
> >  lib/compat_audit.c                  | 4 ++++
> >  16 files changed, 36 insertions(+)

...

> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> > index d775ea16505b..3f59ab209dfd 100644
> > --- a/kernel/auditsc.c
> > +++ b/kernel/auditsc.c
> > @@ -76,6 +76,7 @@
> >  #include <linux/fsnotify_backend.h>
> >  #include <uapi/linux/limits.h>
> >  #include <uapi/linux/netfilter/nf_tables.h>
> > +#include <uapi/linux/openat2.h>
> >
> >  #include "audit.h"
> >
> > @@ -196,6 +197,8 @@ static int audit_match_perm(struct audit_context *ctx, int mask)
> >               return ((mask & AUDIT_PERM_WRITE) && ctx->argv[0] = SYS_BIND);
> >       case AUDITSC_EXECVE:
> >               return mask & AUDIT_PERM_EXEC;
> > +     case AUDITSC_OPENAT2:
> > +             return mask & ACC_MODE((u32)((struct open_how *)ctx->argv[2])->flags);
>
> That's a lot of dereferncing, casting and masking all at once. Maybe a
> small static inline helper would be good for the sake of legibility? Sm
> like:
>
> static inline u32 audit_openat2_acc(struct open_how *how, int mask)
> {
>         u32 flags = how->flags;
>         return mask & ACC_MODE(flags);
> }
>
> but not sure. Just seems more legible to me.
> Otherwise.

I'm on the fence about this.  I understand Christian's concern, but I
have a bit of hatred towards single caller functions like this.  Since
this function isn't really high-touch, and I don't expect that to
change in the near future, let's leave the casting mess as-is.

-- 
paul moore
www.paul-moore.com
