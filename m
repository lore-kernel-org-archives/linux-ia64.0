From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 26 Sep 2001 06:48:32 +0000
Subject: [Linux-ia64] More information on perfmon in 2.4.10
Message-Id: <marc-linux-ia64-105590698805253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To all interested,

> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:
> 
> 	linux-2.4.10-ia64-010924.diff*
> 
> The major changes this time include:
> 
>  - update perfmon to v0.3 (Stephane Eranian)

I would like to add some comments to the updates of perfmon.

What is in 2.4.10 now includes the following new features:

	- optimized PMU context switch for per process monitoring.
  	  This kernel now incoporates a lazy management scheme. 
	  At this point it support only UP running systems. 
	  This covers SMP kernels running in UP mode (nosmp).

	- PFM_DESTROY_CONTEXT: a new command to destroy a perfmon context.
	  This allow a process to exec() another one that want to use
	  perfmon as well.

	- Beginning of system-wide monitoring support. This kernel contains
	  a code that I would consider more as a 'proof of concept' rather
	  than final code. For now support is limited to UP running kernels
	  (this covers SMP kernels running UP).	There can only be one such
	  session for the entire system and it is mutually exclusive with
	  per-process sessions.  You can create a system-wide session 
	  by using the PFM_FL_SYSTEM_WIDE when creating the context.


	- user level notification via the SIGPROF signal is now sent in the
	  perfmon overflow handler and not when the task blocks (if blocking
	  mode is selected). The allows for better code overlapping on SMP systems.

Bug fixes:
    This new kernel includes the important patches sent earlier to the
    list that covered the following bugs:

	- The counts reported by the API are incorrect if the 
	  monitored process was context-switched during its execution. 
	  More or less the counts would be double of what they should be.

	- The content of PMD14-PMD17 was not saved and restored on 
	  context-switch due to an error in the perfmon initialization code,
	  where the number of PMDs and PMCs reported by PAL got swapped.


Here are the new feature that did not make it in time for this release:
	- support for address range restrictions (IBR/DBR)
	- lazy PMU context switch in SMP mode
	
Important upcoming changes:

	- perfmonctl() will loose the flag argument as it is not incorporated 
	  into the argument of the command.

	- Given that the use of siginfo to convey detailed information about the
	  overflows mandates the use of a fixed signal number, the option
	  of choosing the signal to receive overflow notification will be 
	  abandoned. You indicate you want notification by simply providing 
	  a valid process ID and you will receive a SIGPROF when necessary.


I will release a new version of pfmon (pfmon-0.07) once those changes make
it to the official kernel as this version of pfmon already includes the above
changes and therefore will not work with 2.4.10 as it is today.

If you have further questions about pfmon and/or perfmon, please contact me.

-- 
-Stephane

