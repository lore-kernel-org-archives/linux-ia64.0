From: James E Wilson <wilson@tuliptree.org>
Date: Tue, 12 Jul 2005 01:55:22 +0000
Subject: Re: curious compiler-warning
Message-Id: <1121133322.9211.75.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430507111600684085cc@mail.gmail.com>
In-Reply-To: <ed5aea430507111600684085cc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-07-11 at 16:00, david mosberger wrote:
> arch/ia64/kernel/time.c:198: warning: format '%u' expects type
> 'unsigned int', but argument 5 has type 'unsigned int'
> Argument 5 here is a bit field declared as:
>   unsigned long field : 32;

This looks like a bug to me.  There have been some significant changes
to the bit-field support over the last few years.  There were some cases
where we were non-conforming with respect to C89: getting sign/zero
extension wrong, performing operations with the wrong precision.  Plus
some changes were needed for C99 support.  It looks like these changes
have accidentally broken the -Wformat support.

Just taking a quick look, I don't see any existing bug report for this,
so I created a new one.  This is now FSF gcc bug 22421.
    http://gcc.gnu.org/bugzilla/show_bug.cgi?id"421



