From: "Jose Luu" <jluu@mainsoft.com>
Date: Tue, 16 Jan 2001 16:01:06 +0000
Subject: [Linux-ia64] Re: status of debugging ia32 executables on ia64
Message-Id: <marc-linux-ia64-105590693005051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks Don,

I am reporting full success with gdb 5.0 (taken as is from ia32 suse 7.0),
and I have been able to debug my problem.

I have had less success with strace which did not let the executable run
(killed by SIGSGV), and I also got in the log file:
IA32 syscal #29 issued, may be we should implement it. (what call is it ?)

Jose



