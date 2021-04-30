From: Richard Guy Briggs <rgb@redhat.com>
Date: Fri, 30 Apr 2021 17:42:35 +0000
Subject: Re: [PATCH v2 0/3] audit: add support for openat2
Message-Id: <20210430174235.GB3141668@madcap2.tricolour.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1619729297.git.rgb@redhat.com>
In-Reply-To: <cover.1619729297.git.rgb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux-Audit Mailing List <linux-audit@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@parisplace.org>, Steve Grubb <sgrubb@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>

On 2021-04-30 13:29, Richard Guy Briggs wrote:
> The openat2(2) syscall was added in v5.6.  Add support for openat2 to the
> audit syscall classifier and for recording openat2 parameters that cannot
> be captured in the syscall parameters of the SYSCALL record.

Well, that was a bit premature...  Commit descriptions in each of the
patches might be a good idea...  Somehow they got dropped from V1.  I
guess they seemed obvious to me.  :-)    Changelog might be a nice
addition too...  Sorry for the noise.

> Supporting userspace code can be found in
> https://github.com/rgbriggs/audit-userspace/tree/ghau-openat2
> 
> Supporting test case can be found in
> https://github.com/linux-audit/audit-testsuite/pull/103
> 
> Richard Guy Briggs (3):
>   audit: replace magic audit syscall class numbers with macros
>   audit: add support for the openat2 syscall
>   audit: add OPENAT2 record to list how
> 
>  arch/alpha/kernel/audit.c          | 10 ++++++----
>  arch/ia64/kernel/audit.c           | 10 ++++++----
>  arch/parisc/kernel/audit.c         | 10 ++++++----
>  arch/parisc/kernel/compat_audit.c  | 11 +++++++----
>  arch/powerpc/kernel/audit.c        | 12 +++++++-----
>  arch/powerpc/kernel/compat_audit.c | 13 ++++++++-----
>  arch/s390/kernel/audit.c           | 12 +++++++-----
>  arch/s390/kernel/compat_audit.c    | 13 ++++++++-----
>  arch/sparc/kernel/audit.c          | 12 +++++++-----
>  arch/sparc/kernel/compat_audit.c   | 13 ++++++++-----
>  arch/x86/ia32/audit.c              | 13 ++++++++-----
>  arch/x86/kernel/audit_64.c         | 10 ++++++----
>  fs/open.c                          |  2 ++
>  include/linux/audit.h              | 11 +++++++++++
>  include/linux/auditscm.h           | 24 +++++++++++++++++++++++
>  include/uapi/linux/audit.h         |  1 +
>  kernel/audit.h                     |  2 ++
>  kernel/auditsc.c                   | 31 ++++++++++++++++++++++++------
>  lib/audit.c                        | 14 +++++++++-----
>  lib/compat_audit.c                 | 15 ++++++++++-----
>  20 files changed, 168 insertions(+), 71 deletions(-)
>  create mode 100644 include/linux/auditscm.h
> 
> -- 
> 2.27.0
> 

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
