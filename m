From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Mar 2002 19:51:05 +0000
Subject: Re: [Linux-ia64] readv() return and errno
Message-Id: <marc-linux-ia64-105590701905297@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905285@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905285@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 13:17:26 -0800, "Jim Hollenback" <jholly@cup.hp.com> said:

  Jim> In doing some testing on the project I'm working on I came
  Jim> across something that is causing a bit of confusion on my part.

  Jim> According to readv(2) EINVAL is returned for an invalid
  Jim> argument.  The examples given were count might be greater than
  Jim> MAX_IOVEC or zero. The test case I am working with has count   Jim> 0 and I get return of 0 and errno 0 instead of the expected -1
  Jim> and erron EINVAL.

  Jim> Am I missing something?

It seems like the man page is describing the behavior defined in
Single UNIX spec:

 [EINVAL] The iovcnt argument was less than or equal to 0, or greater
	  than {IOV_MAX

However, the kernel code clearly doesn't match this description (it
returns no error for a zero-length iovec).  You might want to bring
this up on the linux-kernel list, as this is not ia64-specific
behavior.

	--david

