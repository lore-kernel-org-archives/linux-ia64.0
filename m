From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 17:17:55 +0000
Subject: Re: [Linux-ia64] How to set/reset gp pointer : info needed
Message-Id: <marc-linux-ia64-105590709806100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 07:08:51 -0800 (PST), Raj Patil <rpatil0296@yahoo.com> said:

  Raj> Reason: I am just trying to port an utility to ia64 based Linux
  Raj> platform from x86 platform. It adds an entry to syscall table
  Raj> to point to a function in a module. It is like adding a new
  Raj> temp syscall for a small duration.

Is the module open-source?  If not, you run the risk of violating the
kernel's GPL license (binary-only modules are OK but only as long as
they use "standard" kernel interfaces; planting a syscall-hook goes
beyond that).

	--david

