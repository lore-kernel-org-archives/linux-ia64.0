From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 01:07:58 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 08 May 2003 10:13:06 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Wed, 7 May 2003 16:51:21 -0700, David Mosberger
  Keith> <davidm@napali.hpl.hp.com> wrote:
  >> How many tools are out there that depend on System.map or
  >> similar?  I suppose you could just generate a fresh System.map at
  >> boot time (or have something like /proc/System.map).

  Keith> ksymoops (user space), kdb, kksymoops (kernel).

What about crash-dump tools such as lkcd?  Do they depend on absolute
addresses?

	--david

