From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 27 Mar 2004 00:50:58 +0000
Subject: latencies for uncommon instructions on I2
Message-Id: <20040327005058.GA9160@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone collated best case latency information for I2 similar to the tables
in the last chapter of the I1 architecture manual?  The I2 architecture manual
is somewhat more vague and doesn't quote latencies for many instructions.

I'm especially interested in latencies for:

- read and write to ar.k*
- flushrs with no dirty registers, loadrs 0, invala
- epc

Matt

