From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 31 Aug 2005 21:31:48 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04472B74@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There are already a couple of syscall reservations in entry.S 
>for kexec and vserver. What makes these so special?

They have already gone into i386 (and others) ... so ia64 is playing
catch-up to provide the same functionality that exists on other
architectures.  Not to mention that I wasn't consulted, they just
appeared there one day out of -mm or linus.

>> New syscalls are not added very often, so this isn't really
>> much effort (compared with maintaining all the code to implement
>> the new syscall).
>
>Yes but its easier to simply replace the sys_ni_syscall with the function 
>call when it finally hits mainline. If the number stays the same then the user
>space source using this function calls do not have to be redone and work 
>on library maintenance can proceed concurrently.

Many people want to add new system calls, not all of them succeed.
Allocation of system call numbers can wait until there is general
agreement that the call is going to be accepted.

-Tony
