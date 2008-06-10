From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 10 Jun 2008 08:23:28 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0806100123j1734a82fgd6d6eee6146b8423@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <20080527040454.053C526FA9E@magilla.localdomain>
	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	 <20080527061209.9A24426FAA6@magilla.localdomain>
	 <1211869515.29836.2.camel@elijah.suse.cz>
	 <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
	 <48450864.6080707@suse.cz> <48455619.6040608@suse.cz>
	 <20080603210125.1724C26FC96@magilla.localdomain>
	 <1FE6DD409037234FAB833C420AA843EC017C44B2@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC017C44B2@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Roland McGrath <roland@redhat.com>, Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Jun 4, 2008 at 5:31 AM, Luck, Tony <tony.luck@intel.com> wrote:
>> What do you mean by "extra"?  There is a SIGTRAP sent after execve
>> completes when ptraced, even when PTRACE_SYSCALL is not being used.
>> So for an execve that succeeds under PTRACE_SYSCALL, there is a
>> ptrace_notify at syscall entry, then a SIGTRAP queued (i.e., not seen
>> by ptrace if blocked), then a ptrace_notify at syscall exit.  If
>> that's what's happening (including the blocked SIGTRAP not being seen
>> by the ptracer, i.e. strace), then there is no mystery (and no bug).
>
> This might not be the same bug ... but I do have a definite 100%
> reproducible bug (latest git kernel, old version of strace (4.5.15-1.el4.1))
>
> Run:
>
>        $ strace -o logit -f make

For this test case, utrace doesn't work too..
