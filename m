From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Sep 2003 02:00:31 +0000
Subject: Re: SHMLBA on linux-ia64
Message-Id: <marc-linux-ia64-106255454226473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106254921222388@msgid-missing>
In-Reply-To: <marc-linux-ia64-106254921222388@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 2 Sep 2003 17:33:15 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> Hi - The file /usr/include/sys/shm.h defines SHMLBA as
  Umut> __getpagesize() which is 16K.

Must be an old libc.  For example, with glibc v2.3.2, I see:

 $ fgrep 'e SHMLBA' /usr/include/bits/shm.h
 #define SHMLBA          (1024 * 1024)

  Umut> whereas in /usr/include/asm/shmparam.h thereis another define
  Umut> of SHMLBA as (1024*1024) and a comment saying on IA-64
  Umut> architecture due to some performance problems it is better to
  Umut> use this alignment.

Not "performance problem" but "_potential_ performance degradation".
On existing ia64 processors, you won't see a performance degradation,
but it is nevertheless recommend to align shared mappings to a 1MB
boundary because the architecture reserves the right that some future
CPU might run slower when there is a virtual alias that is not
congruent modulo 1MB.

	--david
