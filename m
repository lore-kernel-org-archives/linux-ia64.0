From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 26 Jun 2001 01:59:23 +0000
Subject: Re: [Linux-ia64] panic on ia64 ; need help
Message-Id: <marc-linux-ia64-105590693005765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005759@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005759@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 25 Jun 2001 13:32:30 -0600, 
"MEHTA,HIREN (A-SanJose,ex1)" <hiren_mehta@agilent.com> wrote:
>Today I got a panic on a ia64 machine and the kernel jumped into
>the kdb (with serial port attached). The following was the output
>from panic.
>
>I looked at the call trace and it shows the same return address
>4 times. I did run id command on each of the function pointer on
>the stack and I looked at the sources as well. It is for sure that
>we are not calling the same function from itself. Can somebody
>help in trying to understand on what it really means when you 
>see something like this (4 same return addresses) ? 
>
>This panic is coming from a driver loaded as a module. Does anyone
>know how to link the panic output with the symbols in module ?

The kdb 'bt' command will give you a decoded backtrace.

If you have a copy of /proc/ksyms after the module was loaded, you can
run the oops through ksymoops.  'man insmod', read 'KSYMOOPS
ASSISTANCE' for automatically saving /proc/ksyms as modules are loaded
and unloaded.

You did not say which kernel or ia64 patch you were using.  There were
errors in the unwind handling for ia64 modules that were not fixed
until 2.4.5-ia64-010530.  This could cause the stack unwind to give
invalid results, including duplicate addresses.


