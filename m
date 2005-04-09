From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 09 Apr 2005 04:05:48 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <16983.21660.530098.925@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Apr 2005 20:00:59 -0700, Grant Grundler <iod00d@hp.com> said:

  Grant> It requires at least gcc-3.4 for ia64.  gcc-3.3 will fail
  Grant> with: undefined reference to `__builtin_popcount'

If you change:

# define popcount(x)		__builtin_popcountl(x)

into:

#if __GNUC__ >= 4 || (__GNUC__ = 3 && __GNUC_MINOR__ >= 4)
# define popcount(x)         __builtin_popcountl(x)
#else
# define popcount(x)         ia64_popcnt(x)
#endif

then it should build with pre-v3.4 compilers, too.

	--david
