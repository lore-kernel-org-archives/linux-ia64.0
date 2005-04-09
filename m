From: Grant Grundler <iod00d@hp.com>
Date: Sat, 09 Apr 2005 03:00:59 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050409030059.GK3844@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 04:49:11PM -0700, David Mosberger wrote:
> With the attached test-program, I'm seeing these results on a 1.5GHz
> Madison:

I've committed test_fls.c to CVS at:
	http://cvs.parisc-linux.org/build-tools/

It requires at least gcc-3.4 for ia64.
gcc-3.3 will fail with:  undefined reference to `__builtin_popcount'

If someone has more fun with this program and wants to archive
the changes, please send me a patch.

thanks,
grant
