From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Jan 2001 18:31:41 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_PAGE_SIZE
Message-Id: <marc-linux-ia64-105590693005084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 18 Jan 2001 11:21:38 -0700, Don Dugger <n0ano@valinux.com> said:

  Don> This means IA32 processes are slower to start.

This needs to be qualified: in my experience, on a kernel with >4K
page size, IA32 processes start up slower _the first time_ they are
invoked.  Assuming sufficient memory, subsequent invocations of the
same program appear to be much faster than with 4KB pages.  Quite
unexpected.

	--david

