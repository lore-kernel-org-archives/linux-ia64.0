From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 12 Dec 2003 04:48:21 +0000
Subject: Re: new syscall-stub support now in CVS glibc
Message-Id: <marc-linux-ia64-107120454722437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107110849625591@msgid-missing>
In-Reply-To: <marc-linux-ia64-107110849625591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 11, 2003 at 08:09:10PM -0800, David Mosberger wrote:
>   Ian> ** Note: you want to do this in a chroot environment **
> Is this a general caution (which I'm sure is in place) or do you know
> of something that breaks?  In theory, this libc should even let you
> boot with non-TLS kernels, but I certainly haven't tried that.

A general caution just in case I did something wrong with the package
... I'd only trust it when the Debian guys have done it :)

-i
