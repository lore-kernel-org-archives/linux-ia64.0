From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 15:52:31 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905405@msgid-missing>
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

  Randolph> The offending assembly code is attached. it's the
  Randolph> ".restore sp" near the end that is triggering the error.

This is a bug in the assembler that was fixed on Feb 22nd.  I think
it should be in binutils-2.12, though I didn't not verify.

	--david

