From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 18:47:44 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434395610143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 11:27:13 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

>  - use the dmesg command to lower the printing threshold below KERN_WARNING
>    ("dmesg -n4", IIRC)

Not terribly useful if all the unaligned messages made the one I'm
interested in get kicked out of the logs.

>  - use prctl --unalign=silent to turn off unaligned printing for a
>    particular task and its children

What about for the kernel?

No other port is so obstinate about printing out unaligned kernel
access messages, why does ia64 have to be so different?

Unaligned accesses are not only perfectly fine in the kernel, they
are in fact expected in certain circumstances.
