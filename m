From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Date: Tue, 21 Jun 2011 06:56:07 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of
Message-Id: <20110621065542.GA13432@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<4DFE89E0.5020509@zytor.com> <20110620074124.GB24716@elte.hu>
	<4DFF6E58.8090306@zytor.com>
In-Reply-To: <4DFF6E58.8090306@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Jun 20, 2011 at 08:59:20AM -0700, H. Peter Anvin wrote:
> We should either fix /dev/mem to work according to its specification or
> rip it out.  The issue with test drivers is not spurious... I ran into
> this one myself a few weeks ago while trying to do a memory test (by
> limiting the amount of memory available to the kernel).  This is
> something that is typically done on factory floors, and it would be nice
> to be able to get those environments over to using Linux.

We came across a similar request from our manufacturing folks. They have a
memory stress tool that needs to test how much bandwidth is possible between
various cpus and memory modules. Essentially they want the tool to run on some
chosen CPU and want it to drive traffic to some chosen memory module.

/dev/mem would be handy for such test programs ..

- vatsa
