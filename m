From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Thu, 23 Oct 2003 09:31:53 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106690168512047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some machines may require special memory zones, e.g. for ia64
architectures you need to keep the "minimal state save" area
for the Processor Abstraction Layer in un-cached memory.
If you read the memory "in the usual way" then you access the
memory through the HW caches.
The ia64 architecture forbids to have both cached and un-cached
access to the same memory location (by any of the CPUs, DMAs),
otherwise you create a cache paradox => machine check.
Think twice before even trying a "dd if=/dev/mem"...

Zoltan Menyhart
