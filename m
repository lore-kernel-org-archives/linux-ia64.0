From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 10 Jan 2002 21:28:41 +0000
Subject: Re: [Linux-ia64] [PATCH] mmio barrier patch update
Message-Id: <marc-linux-ia64-105590698805800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805779@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805779@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 10, 2002 at 01:28:35PM -0800, David Mosberger wrote:
> I kind of doubt a loop of reads would yield acceptable performance,
> but it is a solution that should work properly, so I'm OK with it.  I
> applied your patch to the 2.5 tree for now.

You're right that it would probably be slow, but I'm hoping that most
platforms have a sane way to address this problem.  I know, for
example, that the mips64 port can use a simple 'sync' instruction to
accomplish the same thing.  Thanks for applying the patch.  Any ideas
on how I might go about getting this macro accepted by other platform
maintainers so that we can sprinkle it into drivers as necessary?

Thanks,
Jesse

