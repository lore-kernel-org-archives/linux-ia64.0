From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 17:25:05 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905409@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905403@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905403@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 7 Apr 2002 17:17:14 -0700, Randolph Chung <randolph@tausq.org> said:

  Randolph> Hi all, While trying to compile mozilla with libffi, the
  Randolph> configure phase dies with a message:

  Randolph> Error: Epilogue count of 4294967296 exceeds number of
  Randolph> nested prologues (0)

  Randolph> I see that this message comes from a patch submitted by
  Randolph> David in February. Is libffi broken? What is needed to fix
  Randolph> it?

I now realize that you must have been using the latest binutils, as the
old one silently generated bad unwind info.

As Richard pointed out in his mail, the offending code really is
broken.  I was planning to update the mozilla libffi anyhow, both to
sync up with Hans's recent unwind fixes and to look into whether we
could use the assembler directives added for C++ vtables to simplify
the generation of static closures.  Let me take a look at it.

	--david

