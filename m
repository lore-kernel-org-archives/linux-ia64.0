From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 22 Sep 2003 19:39:18 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106425957923121@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Sep 21, 2003 at 02:04:34PM -0700, Richard Henderson wrote:
> On Fri, Sep 19, 2003 at 09:32:18AM -0700, H. J. Lu wrote:
> > The basically problem is glibc doesn't store information about what
> > the kernel interface is so that it can't efficiently set up parameters
> > for system calls. Is there a way to improve the situation?
> 
> Use __typeof instead of hard-coding long in the LOAD_ARGS macros.
> That's where the extension comes from.

How can I make __typeof to work with

	char buf [300];

	INLINE_SYSCALL (read, 3, fd, buf, sizeof buf);

Can I get char * from char [300]?


H.J.

