From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 07 Oct 2003 08:17:41 +0000
Subject: Re: current bk goes BUG on ia64 when dumping core; FIXED, PATCH
Message-Id: <marc-linux-ia64-106551480229104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106533868423168@msgid-missing>
In-Reply-To: <marc-linux-ia64-106533868423168@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Roland" = Roland McGrath <roland@redhat.com> writes:

>> The new version doesn't BUG.  I couldn't find the message you were
>> referring to, Roland ... However, gdb understands the core dump;
>> and objdump shows a .auxv section that looks the right size etc.

Roland> Thanks for testing this!  This change is not related to the
Roland> NT_AUXV note in fact (both just happened the same week).  What
Roland> you should be looking for is the readelf -l (objdump -p)
Roland> output from the core file, for the segment with vaddr
Roland> 0xa000000000010000 (GATE_ADDR).  Check that its size is
Roland> PAGE_SIZE.  You can also verify it in gdb while looking at the
Roland> core file by checking that e.g. "p (char *)
Roland> 0xa000000000010000" shows "ELF\177" and that "x/w
Roland> 0xa000000000010000+PAGE_SIZE-8" (substituting the right
Roland> PAGE_SIZE value) works (and shows you zeros).

All those tests pass.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
