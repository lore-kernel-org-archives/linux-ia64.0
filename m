From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 May 2003 18:41:32 +0000
Subject: Re: [Linux-ia64] Re: [BK PATCH] SN update
Message-Id: <marc-linux-ia64-105590723705908@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705890@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705890@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 May 2003 11:20:02 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  >> That's not safe in my mind.  What I'd like is an efficient way to
  >> preview a pull (see a diff -u between the remote tree and where I'm
  >> pulling into).  Note the "efficient" part.  Having to do a full clone
  >> first doesn't qualify.

  Jesse> I found myself wishing the same thing as I tried to get together a
  Jesse> patch for you.

Pulling from upstream is a bit easier: since there is only one
upstream, what I do clone the upstream locally and then do an
unconditional pull.  Then I do a diff between the last version of the
tree and the current one.  It does require maintaining two trees,
but that's not too bad.

The scheme doesn't work well if you pull from many places, though (I
don't know about you, but somehow I'm _always_ short of diskspace, no
matter how big the drives are getting...).

	--david

