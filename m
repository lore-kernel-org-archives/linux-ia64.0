From: Matthew Wilcox <willy@infradead.org>
Date: Tue, 21 May 2019 19:59:28 +0000
Subject: Re: [PATCH 1/2] open: add close_range()
Message-Id: <20190521195928.GB6738@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190521150006.GJ17978@ZenIV.linux.org.uk>
 <20190521113448.20654-1-christian@brauner.io>
 <28114.1558456227@warthog.procyon.org.uk>
 <20190521192009.GK17978@ZenIV.linux.org.uk>
In-Reply-To: <20190521192009.GK17978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, oleg@redhat.com, David Howells <dhowells@redhat.com>, linux-kselftest@vger.kernel.org, sparclinux@vger.kernel.org, shuah@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, miklos@szeredi.hu, x86@kernel.org, torvalds@linux-foundation.org, Christian Brauner <christian@brauner.io>, linux-mips@vger.kernel.org, linux-xtensa@linux-xtensa.org, tkjos@android.com, arnd@arndb.de, jannh@google.com, linux-m68k@lists.linux-m68k.org, tglx@linutronix.de, ldv@altlinux.org, linux-arm-kernel@lists.infradead.org, fweimer@redhat.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, May 21, 2019 at 08:20:09PM +0100, Al Viro wrote:
> On Tue, May 21, 2019 at 05:30:27PM +0100, David Howells wrote:
> 
> > If we can live with close_from(int first) rather than close_range(), then this
> > can perhaps be done a lot more efficiently by:
> > 
> > 	new = alloc_fdtable(first);
> > 	spin_lock(&files->file_lock);
> > 	old = files_fdtable(files);
> > 	copy_fds(new, old, 0, first - 1);
> > 	rcu_assign_pointer(files->fdt, new);
> > 	spin_unlock(&files->file_lock);
> > 	clear_fds(old, 0, first - 1);
> > 	close_fdt_from(old, first);
> > 	kfree_rcu(old);
> 
> I really hate to think how that would interact with POSIX locks...

POSIX locks store current->files in fl_owner; David's resizing the
underlying files->fdt, just like growing from 64 to 256 fds.
