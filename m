From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 25 Nov 2003 07:11:58 +0000
Subject: Re: [PATCH] check user access ok writing /proc/irq/<pid>/smp_affinity
Message-Id: <marc-linux-ia64-106974433828664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106973370622421@msgid-missing>
In-Reply-To: <marc-linux-ia64-106973370622421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Nov 2003 20:15:47 -0800, Paul Jackson <pj@sgi.com> said:

  Paul> David,
  Paul> Could you kindly apply the following patch?

  Paul> In arch/ia64/kernel/irq.c:irq_affinity_write_proc() there
  Paul> is an unchecked user access that examines writes to files
  Paul> /proc/irq/<pid>/smp_affinity for a leading character 'R',
  Paul> in order to trigger some interrupt redirect feature.

  Paul> You can oops the kernel easily, by issuing a write() system
  Paul> call to these files with a bogus address.

  Paul> Here's a patch against test10 to fix it:

I see the problem, but the patch is incomplete: even after an
access_ok()-check, you'll need to use __get_user() to access the
buffer.  Otherwise, the kernel will panic when accessing an unmapped
user-space address.  Can you update the patch and re-test?

Thanks,

	--david
