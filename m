From: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Date: Tue, 08 Jan 2002 19:32:41 +0000
Subject: [Linux-ia64] Re: can we make anonymous memory non-EXECUTABLE?
Message-Id: <marc-linux-ia64-105590698805778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805771@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805771@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger writes:

> I think that's fine.  If the consensus is that apps *should* use
> mprotect() to get executable permission (Linus implied as much) and
> it's an architecture specific choice as to whether this is enforced,
> I'm happy.  My belief is that we could make this change on ia64
> without undue burden on programmers.  If not, I'm sure I'll find out
> about it and I'm willing to take the responsibility.

If you turn off executable permission right now, you can add it
back at some future date.

If you leave the executable permission, we're stuck with it as
the ABI becomes set in stone.

So turn it off ASAP.


