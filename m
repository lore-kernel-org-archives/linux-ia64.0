From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 25 Jan 2002 20:01:57 +0000
Subject: Re: [Linux-ia64] ptrace behavior accessing ar.lc and ar.ec
Message-Id: <marc-linux-ia64-105590698805936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805929@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805929@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Wei,

>>>>> On Fri, 25 Jan 2002 08:43:28 -0800 (PST), wei@baldursgate.ucsd.edu said:

  Wei> Hi David, Thanks for replying.  Here's a reduced testcase that
  Wei> replicates the result.  Its derived from the utrace.c program
  Wei> you gave me a long time ago.

I can't reproduce the problem with 2.4.17.

  Wei> I'm currently using "Linux version 2.4.3-12smp" "Red Hat Linux
  Wei> 7.1 2.96-85".

That's a very old kernel.  Can you try after upgrading to something
more recent?

Thanks,

	--david

