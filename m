From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 17 May 2001 10:17:13 +0000
Subject: Re: [Linux-ia64] Re: 2.4.4 - cannot compile parport module
Message-Id: <marc-linux-ia64-105590693005600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005592@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005592@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 17 May 2001 11:16:06 +0200, 
Christian Groessler <cpg@aladdin.de> wrote:
>>> But now the compilation finished and I've got a new problem.
>>> When I reboot the new 2.4.4 kernel I cannot load any module, the error
>>> message is
>>>
>>>         arch_init_module: archdata->unw_start out of bounds.

Run

 insmod -V -m -v module_name
 objdump -x $(modprobe -l module_name.o)

and send me the output.  Pick a module that has no dependencies on
other modules.


