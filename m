From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 19:41:57 +0000
Subject: Re: [Linux-ia64] How to set/reset gp pointer : info needed
Message-Id: <marc-linux-ia64-105590709806111@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 09:56:12 -0800 (PST), Raj Patil <rpatil0296@yahoo.com> said:

  Raj> I will check the source of this tool/module......  But,
  Raj> curious: You mean, one can not legally add a new syscall or
  Raj> hook?

I don't want to appear to be giving legal advise, so I'd recommend to
consult with your legal counsel to get a definite answer (or you can
ask for opinions on the lkml; preferably _after_ donning an asbestos
suit).

BTW: dynamically installing syscalls/hooks is a bad idea even for Open
Source modules.  It's just not a safe thing to do.  If you need a
syscall, argue why it's needed and why it's a good idea and if the
kernel developers concur, there will be no problem getting it
added/reserved.

	--david

