From: Matthew Wilcox <willy@debian.org>
Date: Fri, 01 Nov 2002 12:21:28 +0000
Subject: Re: [Linux-ia64] mremap and "negative" addresses
Message-Id: <marc-linux-ia64-105590709805323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805322@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805322@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 01, 2002 at 07:08:10PM +1100, Matt Chapman wrote:
> mremap, like mmap, can return addresses in region 4 which
> are "negative" (when interpreted as signed values) and thus
> interpreted as syscall failure.  The following patch
> implements the same workaround as for mmap and other such
> syscalls.

hmm.. x86 handles this kind of thing by comparing against (unsigned
long)-125 instead.  any reason we can't do the same?

i also notice that sys_fcntl has no workaround:

                case F_GETOWN:
                        /*
                         * XXX If f_owner is a process group, the
                         * negative return value will get converted
                         * into an error.  Oops.  If we keep the
                         * current syscall conventions, the only way
                         * to fix this will be in libc.
                         */
                        err = filp->f_owner.pid;
                        break;

or is the workaround for this in libc?

-- 
Revolutions do not require corporate support.

