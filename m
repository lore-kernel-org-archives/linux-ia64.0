From: "R. Lake" <rich@lakes.plus.com>
Date: Mon, 20 Oct 2003 23:42:09 +0000
Subject: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106669369711349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Further to my study of IA64 architecture, and to an extent the linux kernel,
I wonder if the gate page ought to default to little endian upon issue of a
signal. i.e. "rum 2" prior to any loads/stores? It would seem to me that in
the current state, if the process were preempted immediately after a memory
access (fundamentally) in big-endian mode the signal context would likely
execute in the wrong endianness and fail.  - It's my understanding that the
user mask is preserved in the context switch.

Regards,
Richard.


