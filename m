From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 11 Jun 2001 22:38:29 +0000
Subject: Re: [Linux-ia64] Max size of shared memory segment.
Message-Id: <marc-linux-ia64-105590693005711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005710@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005710@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 11 Jun 2001 14:31:32 -0700, Michael Madore <mmadore@turbolinux.com> said:

  Mike> Hi, What is the maximum size a shared memory segment can have
  Mike> on linux IA64?

By default, it's 32MB but you can change that via
/proc/sys/kernel/shmmax.  There is no a priori limit for how big a
value you can install there, but on IA-64 Linux you'll be limited to
what fits in a single region.  With 16KB pages, that would be 16TB.

	--david

