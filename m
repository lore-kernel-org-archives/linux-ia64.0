From: Kevin Buettner <kevinb@redhat.com>
Date: Wed, 17 Dec 2003 15:29:53 +0000
Subject: Re: Remote debug support in gdb for ia64 ?
Message-Id: <marc-linux-ia64-107167502006198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107163953102819@msgid-missing>
In-Reply-To: <marc-linux-ia64-107163953102819@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Dec 16,  9:38pm, Deepak Gupta wrote:

> I am trying to use GDB to remote debug  a Linux Kernel
> running on an IA64 Machine. I am running the GDB on an
> i386 Machine. 
> 
> Does GDB have remote debugging support for an IA64
> Machine. I could not find any file of the sort -
> ia64-stub.c. If GDB does have support, lpease be kind
> enough to let me know the corresponding file in the
> GDB Source Code.

Remote debugging of user space code (via gdbserver) used to work.
I haven't tried it in a very long time, so I don't know if it still
works or not.

There is no (example) IA-64 stub file included with the GDB
distribution.  You'll have to do this part yourself.

Kevin
