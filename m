From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 27 Oct 2002 16:41:48 +0000
Subject: Re: [Linux-ia64] ia64 2.5.44 make dep offsets.h not found
Message-Id: <marc-linux-ia64-105590709805262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805245@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805245@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Oct 2002 18:20:02 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Thu, 24 Oct 2002 22:35:37 -0700, David Mosberger
  Keith> <davidm@napali.hpl.hp.com> wrote:
  >> A quick patch that gets 2.5.44 (mostly) working on ia64 is now at
  >> ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:
  >>
  >> linux-2.5.44-ia64-021024.diff.gz

  Keith> If you start from a clean Linus 2.5.44 and apply the above
  Keith> patch then include/asm-ia64/offsets.h does not exist.  All
  Keith> asm-*/offsets.h files have been deleted from the base
  Keith> tarball, they are generated files.

Try "make dep" first.  That should generate offsets.h.

	--david

