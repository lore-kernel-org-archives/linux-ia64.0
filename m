From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 20:14:30 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <16576.55334.917601.818029@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 4 Jun 2004 15:23:19 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Where this came out of was requests from various partners and
  Bill> We can always just live with crappy ia32 (and by extension,
  Bill> x86-64) support on ia64. :)

I don't think "crappy" is acceptable but it doesn't have to be perfect
on ia64, because you 99% of the apps on a typically Linux box will be
ia64-native binaries (I'd imagine the reverse may often be true for
x86-64).

Again, I don't think multi-arch support is ia64-specific, so whatever
can be done to improve this support will help other platforms, too.
I'm guessing that some of the ISV problems have come from the fact
that they tried to install _everything_ into /emul/ia32-linux?  That
is probably not the best approach.  For self-contained applications,
just installing in /opt or some place like that should work just fine
(and in my experience it does).  /emul/ia32-linux should probably be
reserved for use for files that are known or very likely to collide
with ia64 files of the same name (such as the gtk engine shared
libraries).

As for running shell scripts: isn't there a linux32 command that takes
care of that?

	--david
