From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 20:27:04 +0000
Subject: Re: [Linux-ia64] Modules without unwind data
Message-Id: <marc-linux-ia64-105590701905415@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905402@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905402@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 06 Apr 2002 18:15:42 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> The kernel cannot cope with modules without unwind data,
  Andreas> which happens with data-only modules like the fs/nls
  Andreas> modules when compiling with gcc 3.1.

Applied, thanks.

	--david

