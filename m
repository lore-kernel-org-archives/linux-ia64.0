From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 31 Aug 2001 00:40:57 +0000
Subject: Re: [Linux-ia64] kernel bug in mmap
Message-Id: <marc-linux-ia64-105590698805109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805108@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805108@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 31 Aug 2001 01:05:56 +0100, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> Hi, Attempts to mmap an empty file result in the file being
  Richard> left busy, such that the file system cannot be unmounted.
  Richard> Fix below.

Thanks for the patch.  There seem to be several other error conditions
in do_mmap2() in which the fput() is skipped.  I'll fix those, too.

Thanks,

	--david


