From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 27 Jan 2001 05:21:30 +0000
Subject: Re: [Linux-ia64] gcc bug
Message-Id: <marc-linux-ia64-105590693005108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005105@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005105@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Jan 2001 20:20:31 -0800, Jim Wilson <wilson@cygnus.com> said:

  Jim> There was a comment about non-int bitfields.  This isn't
  Jim> allowed by the ISO C standard, but it is a very common
  Jim> extension.  Most C compilers support it.  Gcc will give a
  Jim> warning about this construct if you use -pedantic.  This isn't
  Jim> related to the problem though.

Yes.

  Jim> The problem with the code is that it uses invalid casts.

Oh, you are right.

  Jim> Gcc does support type punning via unions, though the ISO C
  Jim> standard technically does not allow this.

Good.

  Jim>If you write the code like this it should work
  Jim>union g {
  Jim>  struct f f;
  Jim>  unsigned long l;
  Jim>};

  Jim>  ((union g*)&w)->f.lo = ((union g*)&value1)->f.lo;
  Jim>  ((union g*)&w)->f.hi = ((union g*)&value2)->f.hi;

OK, that seems to take care of the problem.

  Jim> However, this is a bit cryptic.  It would be clearer, and you
  Jim> will get much more efficient code, if you write it something
  Jim> like this.  Using & usually forces values onto the stack.  If
  Jim> we do it this way, we do everything in registers until the
  Jim> write to r.

Yes, that would be much cleaner and better for performance.
Unfortunately, it's not my code and it's a large and complex program,
so I'll probably have to make do with the "union" wrapper for now.

Thanks a lot,

	--david

