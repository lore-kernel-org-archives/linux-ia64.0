From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 24 Apr 2008 12:27:01 +0000
Subject: Re: ptrace problem with 2.6.25 on Itanium
Message-Id: <1209040021.22520.25.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
In-Reply-To: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2008-04-24 at 14:14 +0200, stephane eranian wrote:
> Petr,
> 
> Thanks for checking, I am pretty sure this is a problem introduced recently.
> The only thing related to this that I can think of is the TIF_RESTORE_RSE
> and the associated TIF_NOTIFY_RESUME.
> 
> When I try the same test on 2.6.25:

Yes, this is consistent with what I can see on 2.6.25-rc3 (which I still
had lying around on the test host):

glass:~/ptrace-wrong-notify # ./task_ptrace_attach ./forktest 10 10
creating 10 additional process(es)
10 iterations
pid006 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [3006]
pid006 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [3006]
pid005 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [3006]

and so on... Ok, I'm going to play with git now. ;]

Petr Tesarik
