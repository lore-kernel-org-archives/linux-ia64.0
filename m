From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Dec 2000 07:08:19 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Dec 2000 22:56:52 -0800, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Thu, 14 Dec 2000 17:44:29 +1100, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> I need to look at an arbitrary process and determine its
>  Keith> stack state accurately.  If you can think of an method which
>  Keith> does not require tracking the switch_stack (or current top of
>  Keith> stack, it is almost the same thing) for all processes, let me
>  Keith> know.  I looked at this for a couple of weeks without finding
>  Keith> a better solution.
>
>Since you need to stop the CPUs anyhow, why not just have the CPUs
>store their "current" values in a global array?

There is no guarantee that I can stop all the cpus.  Sometimes the
problem is so bad that the cpu will not accept the IPI.  This is
exactly the case when a debugger needs to be able to print the
processor on the unresponsive cpu, or at the very least to say what
state the process is in.  kdb can detect unresponsive cpus and will not
let you switch to them but you can still issue 'btp pid' to get some
data for the offending cpu.  And that needs the location of the last
switch_stack for the process.


