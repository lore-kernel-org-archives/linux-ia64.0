From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 15 May 2023 14:20:46 +0000
Subject: Re: [RFC PATCH v2] fs/xattr: add *at family syscalls
Message-Id: <CAOQ4uxgLT8aae7zo3vNRTO+XKr4Xm5j=yUYPS0L1Fm751RS00A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230511150802.737477-1-cgzones@googlemail.com>
 <20230515-kopfgeld-umkurven-f27be4b68a26@brauner> <CAOQ4uxgtxLLfBuVUAT7+N7cox+03wJA3ACGEu76dZd5RqGWXTQ@mail.gmail.com>
 <20230515-banal-vergab-a7abb53169b5@brauner>
In-Reply-To: <20230515-banal-vergab-a7abb53169b5@brauner>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christian Brauner <brauner@kernel.org>
Cc: =?UTF-8?Q?Christian_G=C3=B6ttsche?= <cgzones@googlemail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, audit@vger.kernel.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org, Jan Kara <jack@suse.cz>, jlayton@kernel.org, cyphar@cyphar.com, Arnd Bergmann <arnd@arndb.de>

On Mon, May 15, 2023 at 4:52 PM Christian Brauner <brauner@kernel.org> wrote:
>
> On Mon, May 15, 2023 at 04:04:21PM +0300, Amir Goldstein wrote:
> > On Mon, May 15, 2023 at 1:33 PM Christian Brauner <brauner@kernel.org> wrote:
> > >
> > > On Thu, May 11, 2023 at 05:08:02PM +0200, Christian Göttsche wrote:
> > > > Add the four syscalls setxattrat(), getxattrat(), listxattrat() and
> > > > removexattrat().  Those can be used to operate on extended attributes,
> > > > especially security related ones, either relative to a pinned directory
> > > > or on a file descriptor without read access, avoiding a
> > > > /proc/<pid>/fd/<fd> detour, requiring a mounted procfs.
> > > >
> > > > One use case will be setfiles(8) setting SELinux file contexts
> > > > ("security.selinux") without race conditions.
> > > >
> > > > Add XATTR flags to the private namespace of AT_* flags.
> > > >
> > > > Use the do_{name}at() pattern from fs/open.c.
> > > >
> > > > Use a single flag parameter for extended attribute flags (currently
> > > > XATTR_CREATE and XATTR_REPLACE) and *at() flags to not exceed six
> > > > syscall arguments in setxattrat().
> > > >
> > > > Previous approach ("f*xattr: allow O_PATH descriptors"): https://lore.kernel.org/all/20220607153139.35588-1-cgzones@googlemail.com/
> > > > v1 discussion: https://lore.kernel.org/all/20220830152858.14866-2-cgzones@googlemail.com/
> > > >
> > > > Signed-off-by: Christian Göttsche <cgzones@googlemail.com>
> > > > CC: x86@kernel.org
> > > > CC: linux-alpha@vger.kernel.org
> > > > CC: linux-kernel@vger.kernel.org
> > > > CC: linux-arm-kernel@lists.infradead.org
> > > > CC: linux-ia64@vger.kernel.org
> > > > CC: linux-m68k@lists.linux-m68k.org
> > > > CC: linux-mips@vger.kernel.org
> > > > CC: linux-parisc@vger.kernel.org
> > > > CC: linuxppc-dev@lists.ozlabs.org
> > > > CC: linux-s390@vger.kernel.org
> > > > CC: linux-sh@vger.kernel.org
> > > > CC: sparclinux@vger.kernel.org
> > > > CC: linux-fsdevel@vger.kernel.org
> > > > CC: audit@vger.kernel.org
> > > > CC: linux-arch@vger.kernel.org
> > > > CC: linux-api@vger.kernel.org
> > > > CC: linux-security-module@vger.kernel.org
> > > > CC: selinux@vger.kernel.org
> > > > ---
> > >
> > > Fwiw, your header doesn't let me see who the mail was directly sent to
> > > so I'm only able to reply to lists which is a bit pointless...
> > >
> > > > v2:
> > > >   - squash syscall introduction and wire up commits
> > > >   - add AT_XATTR_CREATE and AT_XATTR_REPLACE constants
> > >
> > > > +#define AT_XATTR_CREATE              0x1     /* setxattrat(2): set value, fail if attr already exists */
> > > > +#define AT_XATTR_REPLACE     0x2     /* setxattrat(2): set value, fail if attr does not exist */
> > >
> > > We really shouldn't waste any AT_* flags for this. Otherwise we'll run
> > > out of them rather quickly. Two weeks ago we added another AT_* flag
> > > which is up for merging for v6.5 iirc and I've glimpsed another AT_*
> > > flag proposal in one of the talks at last weeks Vancouver conference
> > > extravaganza.
> > >
> > > Even if we reuse 0x200 for AT_XATTR_CREATE (like we did for AT_EACCESS
> > > and AT_REMOVEDIR) we still need another bit for AT_XATTR_REPLACE.
> > >
> > > Plus, this is really ugly since AT_XATTR_{CREATE,REPLACE} really isn't
> > > in any way related to lookup and we're mixing it in with lookup
> > > modifying flags.
> > >
> > > So my proposal for {g,s}etxattrat() would be:
> > >
> > > struct xattr_args {
> > >         __aligned_u64 value;
> > >         __u32 size;
> > >         __u32 cmd;
> > > };
> > >
> > > So everything's nicely 64bit aligned in the struct. Use the @cmd member
> > > to set either XATTR_REPLACE or XATTR_CREATE and treat it as a proper
> > > enum and not as a flag argument like the old calls did.
> > >
> > > So then we'd have:
> > >
> > > setxattrat(int dfd, const char *path, const char __user *name,
> > >            struct xattr_args __user *args, size_t size, unsigned int flags)
> > > getxattrat(int dfd, const char *path, const char __user *name,
> > >            struct xattr_args __user *args, size_t size, unsigned int flags)
> > >
> > > The current in-kernel struct xattr_ctx would be renamed to struct
> > > kernel_xattr_args and then we do the usual copy_struct_from_user()
> > > dance:
> > >
> > > struct xattr_args args;
> > > err = copy_struct_from_user(&args, sizeof(args), uargs, usize);
> > >
> > > and then go on to handle value/size for setxattrat()/getxattrat()
> > > accordingly.
> > >
> > > getxattr()/setxattr() aren't meaningfully filterable by seccomp already
> > > so there's not point in not using a struct.
> > >
> > > If that isn't very appealing then another option is to add a new flag
> > > namespace just for setxattrat() similar to fspick() and move_mount()
> > > duplicating the needed lookup modifying flags.
> > > Thoughts?
> >
> > Here is a thought: I am not sure if I am sorry we did not discuss this API
> > issue in LSFMM or happy that we did not waste our time on this... :-/
> >
> > I must say that I dislike redefined flag namespace like FSPICK_*
> > just as much as I dislike overloading the AT_* namespace and TBH,
> > I am not crazy about avoiding this problem with xattr_args either.
> >
> > A more sane solution IMO could have been:
> > - Use lower word of flags for generic AT_ flags
> > - Use the upper word of flags for syscall specific flags
>
> We'd have 16 lower bits for AT_* flags and upper 16 bits for non-AT_*
> flags. That might be ok but it isn't great because if we ever extend
> AT_* flags into the upper 16 bits that are generally useful for all
> AT_* flag taking system calls we'd not be able to use them. And at the
> rate people keep suggesting new AT_* flags that issue might arise
> quicker than we might think.
>
> And we really don't want 64 bit flag arguments because of 32 bit
> architectures as that gets really ugly to handle cleanly (Arnd has
> talked a lot about issues in this area before).
>
> >
> > So if it were up to me, I would vote starting this practice:
> >
> > + /* Start of syscall specific range */
> > + #define AT_XATTR_CREATE       0x10000     /* setxattrat(2): set
> > value, fail if attr already exists */
> > + #define AT_XATTR_REPLACE     0x20000     /* setxattrat(2): set
> > value, fail if attr does not exist */
> >
> > Which coincidentally happens to be inline with my AT_HANDLE_FID patch...
>
> This is different though. The reason AT_HANDLE_FID is acceptable is
> because we need the ability to extend an existing system call and we're
> reusing a bit that is already used in two other system calls. So we
> avoid adding a new system call just to add another flag argument and
> we're also not using up an additional AT_* bit. This makes it bearable
> imho. But here we're talking about new system calls where we can avoid
> this problem arising in the first place.
>
> >
> > Sure, we will have some special cases like MOVE_MOUNT_* and
> > legacy pollution to the lower AT_ flags word, but as a generic solution
> > for syscalls that need the common AT_ lookup flags and just a few
> > private flags, that seems like the lesser evil to me.
>
> It is fine to do this in some cases but we shouldn't encourage mixing
> distinct flag namespaces let alone advertising this as a generic
> solution imho. The AT_XATTR_* flags aren't even flags they behave like
> an enum.

OK. I see your point.
Also, wrt struct xattr_args, there is sort of a precedent with
XFS_IOC_ATTRMULTI_BY_HANDLE ioctl, struct xfs_attr_multiop
and flags XFS_IOC_ATTR_{CREATE,REPLACE}.

Just a nit, I would use xattr_args field names that are the
same as setxattr() arg names, so s/cmd/flags.

Thanks,
Amir.
