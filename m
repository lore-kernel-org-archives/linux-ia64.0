From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 27 Mar 2004 06:14:46 +0000
Subject: Re: latencies for uncommon instructions on I2
Message-Id: <20040327061446.GA13581@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040327005058.GA9160@cse.unsw.EDU.AU>
In-Reply-To: <20040327005058.GA9160@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Mar 27, 2004 at 11:50:58AM +1100, Matt Chapman wrote:
> Has anyone collated best case latency information for I2 similar to the tables
> in the last chapter of the I1 architecture manual?  The I2 architecture manual
> is somewhat more vague and doesn't quote latencies for many instructions.

Ah, I had an out of date version, revision 2 of that manual does come with an
additional table "Latencies for OS Related Instructions".  It only covers
producer/consumer latencies though, so it doesn't answer all of my questions.
The manual says:

   All of the computational functional units are fully pipelined, so each
   functional unit can accept one new instruction per clock cycle in the
   absence of other types of stalls. System instructions and access to system
   registers may be an exception.

Basically, what I want to know is - which instruction classes are exceptions?
i.e. if I issue a mov rr=, does it "tie up" my M2 unit for a certain number
of cycles?  If it's buffered, how deep is the buffer before it has to stall?
What about mov ar.k*=?

Of course I will try it out and profile, but if anyone can answer the above
for me I'd be grateful.

Matt

