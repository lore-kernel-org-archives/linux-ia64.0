From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Aug 2000 18:34:15 +0000
Subject: Re: [Linux-ia64] C++ compatible include files
Message-Id: <marc-linux-ia64-105590678205376@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205375@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205375@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Aug 2000 14:23:53 -0400, roneng@ca.ibm.com said:

  Ronen> I was wondering if there are plans to make the ia64 kernel
  Ronen> include files C++ compatible. In particular the ::: in the
  Ronen> embedded assembly in system.h and atomic.h seems to prevent
  Ronen> these files, and the files that include them (e.g. fs.h) from
  Ronen> being included in C++ programs.

Umh, why are you including kernel headers?  That's a no-can-do, as
Linus has stated repeatedly.

Since the kernel is written in C, there is no point in adding C++
hacks.

	--david

