From: Richard Hirst <rhirst@linuxcare.com>
Date: Tue, 20 Aug 2002 11:22:30 +0000
Subject: Re: [Linux-ia64] Kernel dumps stacks while calling exported function from a loadable module
Message-Id: <marc-linux-ia64-105590701905959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905956@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905956@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 20, 2002 at 07:41:47PM +0800, Jeff Lee wrote:
> My kernel was from the RH installation CD.  I haven't touched it yet.
> 
> I used gcc3.1 for a reason: the 2.96 gcc causes the same problem; hence I tried gcc3.1 but that doesn't seem to matter,
> 
> Actually, I tried a little experiment.  I printed the address of dummy() out;  surprisingly, the reading of dummy() is different in the exporting module from the calling module (no wonder the kernel stacks).  But, any other global variables look fine.  
> 
> What so special about the kernel function symbols in IA 64?

A pointer to a function on ia64 is actually a pointer to a struct
containing the address of the function and the data pointer to use in
the function.

Richard


