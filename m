From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Jan 2003 07:24:01 +0000
Subject: [Linux-ia64] Re: strace improvement patch
Message-Id: <marc-linux-ia64-105590709805654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805650@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805650@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Jan 2003 23:05:55 -0800, Roland McGrath <roland@redhat.com> said:

  Roland> Are you sure this really works on IA64?

Yes, it works very well on 2.5.52.  I tested it on decidedly
non-trivial, heavily multithreaded programs.

  Roland> I've committed the changes (along with some more fixes and
  Roland> new support for the new threads features in Linux 2.5).  Can
  Roland> you get the current sources from sourceforge and try them on
  Roland> IA64?  After getting a cvs checkout, you'll need to run
  Roland> "autoreconf -i" with automake-1.7.2 and autoconf-2.57.

I tried it and it works fine with 2.5.52.  Then I also tried on a
2.4.20 machine and sure enough, there it dies with a SIGSEGV.  I can
look into it, but not tonight, so you may want to go ahead with the
test-release.

Thanks,

	--david

