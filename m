From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 17 Sep 2001 15:07:35 +0000
Subject: Re: [Linux-ia64] sigaltstack not working
Message-Id: <marc-linux-ia64-105590698805190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805189@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805189@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Sep 2001 16:12:34 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> The appended program isn't working as expected.  As soon as
  Andreas> the stack limit is reached it hangs without actually
  Andreas> executing the signal handler.

I'm aware of this problem and it's on my todo list, but I'm not sure
exactly when I'll find time to fix it.  Did you encounter this in a
real program or just with a test program?

	--david

