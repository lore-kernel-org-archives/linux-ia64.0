From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 07 May 2001 18:08:09 +0000
Subject: Re: [Linux-ia64] Cleanup include/asm-ia64/offsets.h - take 2
Message-Id: <marc-linux-ia64-105590693005541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 1 May 2001 09:36:25 +0100 (BST), Doug Rabson <dfr@nlsystems.com> said:

  Doug> We have similar issues in FreeBSD (and all the other BSDs
  Doug> too). Our current solution is to compile a file which uses
  Doug> offsetof() to determine the symbol values and then use a
  Doug> script to extract those values.

We do the same when cross-compiling a kernel.

	--david

