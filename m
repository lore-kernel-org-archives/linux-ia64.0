From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 01:57:13 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106566496514795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Oct 2003 11:25:58 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> The problem is not the interfaces - they tend to use "long"
  Nathan> directly and will be unaffected.  When I started running our
  Nathan> tests with large inode numbers, for the most part everything
  Nathan> just worked.

Argh, of course it's about interfaces.  We don't want to break
something unknowingly because of this change.  Saying that "for the
most part everything just worked" isn't exactly reassuring!

  Nathan> e.g. the ia64 include/asm-ia64/stat.h uses long for the
  Nathan> inode number field, and the struct inode i_ino is a long
  Nathan> also.  So, for the most part everything works as is - there
  Nathan> are corner cases (i.e. getdents) that this fixes though, as
  Nathan> I explained.  It does not change any external interfaces (if
  Nathan> it did they'd be broken already, but I haven't seen any
  Nathan> evidence of that in my testing).

Are you saying that you reviewed the entire syscall interface and did
a reasonable review of anything else (e.g., /proc) that might expose
ino_t in one way or another?

	--david
